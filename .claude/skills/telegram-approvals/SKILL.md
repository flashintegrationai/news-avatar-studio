---
name: telegram-approvals
description: Handles incoming Telegram button callbacks for script and video approvals. Validates sender, parses callback_data, updates Supabase status, logs to news_approvals, and edits the original message to remove buttons.
---

# Telegram Approvals

## Trigger
n8n Webhook receives Telegram update at `NEWS_TELEGRAM_WEBHOOK_URL`.

## Webhook setup (one-time, via cURL or n8n)
```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/setWebhook" \
  -d "url=<NEWS_TELEGRAM_WEBHOOK_URL>" \
  -d "secret_token=<TELEGRAM_WEBHOOK_SECRET>"
```

## Incoming payload shape
```json
{
  "update_id": 123,
  "callback_query": {
    "id": "cb-id",
    "from": { "id": 12345, "first_name": "Operator" },
    "message": { "message_id": 999, "chat": { "id": -100... } },
    "data": "script:abc-123:approve"
  }
}
```

## Steps in the workflow
1. Validate header `X-Telegram-Bot-Api-Secret-Token` == `TELEGRAM_WEBHOOK_SECRET`
2. Validate `callback_query.from.id` ∈ `TELEGRAM_ALLOWED_USER_IDS`
3. Parse `callback_query.data` → `[entity, id, action]`
4. Route by `entity`:
   - `script`: UPDATE news_scripts SET status=... WHERE id=...
   - `video`: UPDATE news_videos SET status=... (and publish_confirmed_at if action='publish_now')
5. INSERT news_approvals { entity_type, entity_id, decision, user_id: from.id }
6. POST `editMessageReplyMarkup` to remove buttons (or `editMessageText` to show "✅ Approved")
7. POST `answerCallbackQuery` (acknowledges the tap so Telegram stops spinner)
8. If action triggers next pipeline stage (e.g., script approved → render), POST to next workflow webhook

## Action → status mapping

| Entity | Action | New status | Side effect |
|---|---|---|---|
| script | approve | approved | → trigger NEWS - Render Hedra |
| script | edit | needs_edit | → notify operator with edit form |
| script | reject | rejected | halt pipeline |
| video | publish_now | approved + publish_confirmed_at=now() | → trigger NEWS - Publish YouTube |
| video | schedule | approved (no confirm yet) | prompt for date/time |
| video | reject | rejected | halt pipeline |

## Forbidden
- Never trust unsigned callbacks (always validate secret_token)
- Never accept callbacks from non-whitelisted users (silently ignore + log)
- Never auto-publish without `publish_now` action explicitly tapped
