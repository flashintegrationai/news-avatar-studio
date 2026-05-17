#!/usr/bin/env node
/**
 * One-time YouTube OAuth bootstrap.
 *
 * Opens the consent screen in your browser, captures the auth code on
 * a local loopback, and exchanges it for a refresh_token.
 *
 * Usage:
 *   node scripts/youtube-oauth.mjs
 *
 * Reads from .env.local:
 *   YOUTUBE_CLIENT_ID
 *   YOUTUBE_CLIENT_SECRET
 *
 * Prints the refresh_token; append it to .env.local manually.
 */

import http from 'node:http';
import { exec } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import crypto from 'node:crypto';

function loadEnvLocal() {
  try {
    const raw = readFileSync(resolve(process.cwd(), '.env.local'), 'utf8');
    for (const line of raw.split('\n')) {
      const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (!m) continue;
      const [, k, v] = m;
      if (!process.env[k]) process.env[k] = v.replace(/^["']|["']$/g, '');
    }
  } catch {}
}
loadEnvLocal();

const CLIENT_ID = process.env.YOUTUBE_CLIENT_ID;
const CLIENT_SECRET = process.env.YOUTUBE_CLIENT_SECRET;
if (!CLIENT_ID || !CLIENT_SECRET) {
  console.error('✗ YOUTUBE_CLIENT_ID / YOUTUBE_CLIENT_SECRET missing in .env.local');
  process.exit(1);
}

const PORT = 8765;
const REDIRECT_URI = `http://localhost:${PORT}/callback`;
const SCOPES = [
  'https://www.googleapis.com/auth/youtube.upload',
  'https://www.googleapis.com/auth/youtube.readonly',
  'https://www.googleapis.com/auth/yt-analytics.readonly',
].join(' ');

const STATE = crypto.randomBytes(16).toString('hex');
const authUrl = new URL('https://accounts.google.com/o/oauth2/v2/auth');
authUrl.searchParams.set('client_id', CLIENT_ID);
authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('scope', SCOPES);
authUrl.searchParams.set('access_type', 'offline');
authUrl.searchParams.set('prompt', 'consent');
authUrl.searchParams.set('state', STATE);

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  if (url.pathname !== '/callback') {
    res.writeHead(404); res.end(); return;
  }
  const code = url.searchParams.get('code');
  const state = url.searchParams.get('state');
  const error = url.searchParams.get('error');

  if (error) {
    res.writeHead(400, { 'Content-Type': 'text/html' });
    res.end(`<h1>OAuth error</h1><pre>${error}</pre>`);
    console.error('✗ OAuth error:', error);
    server.close(); process.exit(1);
  }
  if (state !== STATE) {
    res.writeHead(400); res.end('state mismatch');
    console.error('✗ State mismatch');
    server.close(); process.exit(1);
  }

  try {
    const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        code,
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        redirect_uri: REDIRECT_URI,
        grant_type: 'authorization_code',
      }),
    });
    const tokens = await tokenRes.json();
    if (!tokens.refresh_token) {
      res.writeHead(500, { 'Content-Type': 'text/html' });
      res.end(`<h1>No refresh_token in response</h1><pre>${JSON.stringify(tokens, null, 2)}</pre>`);
      console.error('✗ no refresh_token:', tokens);
      server.close(); process.exit(1);
    }

    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end('<h1>✓ Success</h1><p>Refresh token captured. You can close this tab and return to the terminal.</p>');

    console.log('\n========================================');
    console.log('✓ YOUTUBE_REFRESH_TOKEN=' + tokens.refresh_token);
    console.log('========================================');
    console.log('Append the line above to .env.local\n');
    server.close();
  } catch (e) {
    res.writeHead(500); res.end('Token exchange failed: ' + e.message);
    console.error(e); server.close(); process.exit(1);
  }
});

server.listen(PORT, () => {
  console.log(`Opening browser → ${authUrl}`);
  const cmd = process.platform === 'win32' ? `start "" "${authUrl}"`
            : process.platform === 'darwin' ? `open "${authUrl}"`
            : `xdg-open "${authUrl}"`;
  exec(cmd, (err) => {
    if (err) console.log('Could not auto-open. Visit the URL above manually.');
  });
  console.log(`Waiting on ${REDIRECT_URI} ...`);
});
