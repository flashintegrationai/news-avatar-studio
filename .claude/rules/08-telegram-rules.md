# Rule 08 — Telegram Rules

## Telegram is the only UI
There is no web dashboard. All operator interactions happen via Telegram bot.

## Bot credentials
- Token stored in `TELEGRAM_BOT_TOKEN` env var only
- Never in committed files, never in logs, never in API responses
- Rotate via @BotFather if compromised

## Authorization
- `TELEGRAM_ALLOWED_USER_IDS` env: comma-separated whitelist of user IDs that can approve actions
- Validate `callback_query.from.id` against this list on EVERY callback
- Silently drop unauthorized callbacks (don't reveal bot exists)

## Webhook validation
- Set `secret_token` when registering webhook
- Validate `X-Telegram-Bot-Api-Secret-Token` header on every incoming request
- Reject with 401 if mismatch

## Message format
- Use Markdown or MarkdownV2 parse_mode
- Escape user-supplied content (titles, scripts) — use Telegram MarkdownV2 escaping rules
- Keep messages under 4096 chars
- Use code blocks for script preview to preserve formatting

## Inline keyboard callback_data convention
Format: `<entity>:<uuid>:<action>`
- `script:abc-123:approve`
- `video:def-456:publish_now`

Max 64 bytes per callback_data (Telegram limit).

## Notification types and timing
- **Approval requests:** immediate (on status change)
- **Errors:** immediate
- **Publish success:** within 1 min of upload
- **Daily metrics:** 09:00 local time
- **Quota warnings:** when remaining < 20%

## What NOT to do
- Never send to chat_ids outside the whitelist
- Never auto-approve via any path (only button taps count)
- Never include the bot token in any logged message or response body
- Never poll updates with `getUpdates` once webhook is set (conflict)
- Never expose bot to public — always validate sender

## File size constraints
- `sendVideo`: ≤ 50 MB → use for short previews
- `sendDocument`: ≤ 2 GB → use for full final videos if needed
- Prefer signed Supabase Storage URLs over re-uploading large files
