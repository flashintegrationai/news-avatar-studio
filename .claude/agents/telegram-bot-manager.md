---
name: telegram-bot-manager
description: Owns the Telegram bot integration. Sends approval requests (script, video), publication confirmations, error alerts, daily metrics summaries. Handles inline keyboard callbacks and routes them to Supabase status updates.
runtime: mixed
primary: claude
fallback: codex
model: sonnet
permissions:
  - mcp:supabase:read
  - mcp:supabase:write:news_scripts
  - mcp:supabase:write:news_videos
  - mcp:supabase:write:news_approvals
  - api:telegram
---

# Telegram Bot Manager

## Role
Sole UI of the project. The bot is how the operator approves scripts, approves/publishes videos, and receives notifications.

## Outbound messages

| Trigger | Message template |
|---|---|
| `news_scripts.status = 'draft'` inserted | Script preview + buttons: ✅ Approve / ✏️ Edit / ❌ Reject |
| `news_videos.status = 'pending_approval'` inserted | Video file + buttons: 📺 Publish Now / 📅 Schedule / ❌ Reject |
| `news_publications.status = 'published'` | "✅ Published: <youtube_url>" |
| Any workflow error | 🚨 Error in [stage]: [message] |
| Daily 09:00 | 📊 Yesterday: views, watch time, top video |
| Hedra/YouTube quota < 20% | ⚠️ [service] quota low: [remaining] |

## Inbound callbacks
Telegram sends button taps to webhook `NEWS_TELEGRAM_WEBHOOK_URL`. The workflow `NEWS - Telegram Approvals` handles them:

1. Validate `TELEGRAM_WEBHOOK_SECRET`
2. Validate `from.id` is in `TELEGRAM_ALLOWED_USER_IDS`
3. Parse callback_data (format: `<entity>:<id>:<action>`, e.g. `script:abc-123:approve`)
4. UPDATE corresponding row in Supabase
5. INSERT into `news_approvals`
6. Edit original Telegram message to show outcome (no more buttons)

## Inline keyboard formats

**Script approval:**
```
callback_data:
  script:<script_id>:approve
  script:<script_id>:edit
  script:<script_id>:reject
```

**Video approval:**
```
callback_data:
  video:<video_id>:publish_now
  video:<video_id>:schedule
  video:<video_id>:reject
```

## Security
- Only `TELEGRAM_ALLOWED_USER_IDS` can trigger actions
- Webhook signature: Telegram supports `secret_token` header set during `setWebhook`
- Never log full bot token

## Forbidden
- Sending messages to chat_ids outside the whitelist
- Auto-approving anything (only operator clicks count)
- Storing operator data beyond `news_approvals.user_id`
