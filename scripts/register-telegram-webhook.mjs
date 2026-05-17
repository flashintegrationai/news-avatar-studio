#!/usr/bin/env node
/**
 * Register the Telegram bot webhook against the n8n "NEWS - Telegram Approvals" workflow.
 *
 * Usage:
 *   node scripts/register-telegram-webhook.mjs            # register
 *   node scripts/register-telegram-webhook.mjs --info     # show current webhook
 *   node scripts/register-telegram-webhook.mjs --delete   # unregister
 *
 * Required env (from .env.local):
 *   TELEGRAM_BOT_TOKEN
 *   TELEGRAM_WEBHOOK_SECRET
 *   NEWS_TELEGRAM_WEBHOOK_URL    (the n8n webhook URL for approvals)
 */

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

function loadEnvLocal() {
  try {
    const raw = readFileSync(resolve(process.cwd(), '.env.local'), 'utf8');
    for (const line of raw.split('\n')) {
      const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (!m) continue;
      const [, k, v] = m;
      if (!process.env[k]) process.env[k] = v.replace(/^["']|["']$/g, '');
    }
  } catch {
    // .env.local optional — caller may have exported vars already
  }
}

loadEnvLocal();

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const SECRET = process.env.TELEGRAM_WEBHOOK_SECRET;
const URL = process.env.NEWS_TELEGRAM_WEBHOOK_URL;

function die(msg) {
  console.error(`✗ ${msg}`);
  process.exit(1);
}

if (!TOKEN) die('TELEGRAM_BOT_TOKEN missing');

const api = (method) => `https://api.telegram.org/bot${TOKEN}/${method}`;

async function call(method, body) {
  const res = await fetch(api(method), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body ?? {}),
  });
  const json = await res.json();
  if (!json.ok) die(`${method} failed: ${json.description}`);
  return json.result;
}

const arg = process.argv[2];

if (arg === '--info') {
  const info = await call('getWebhookInfo');
  console.log(JSON.stringify(info, null, 2));
  process.exit(0);
}

if (arg === '--delete') {
  await call('deleteWebhook', { drop_pending_updates: true });
  console.log('✓ webhook deleted');
  process.exit(0);
}

if (!URL) die('NEWS_TELEGRAM_WEBHOOK_URL missing');
if (!SECRET) die('TELEGRAM_WEBHOOK_SECRET missing');
if (SECRET.length < 16) die('TELEGRAM_WEBHOOK_SECRET should be ≥16 chars');

await call('setWebhook', {
  url: URL,
  secret_token: SECRET,
  allowed_updates: ['callback_query', 'message'],
  drop_pending_updates: true,
  max_connections: 40,
});

const info = await call('getWebhookInfo');
console.log('✓ webhook registered');
console.log(JSON.stringify(info, null, 2));
