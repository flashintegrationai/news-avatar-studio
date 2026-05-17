---
name: telegram-bot
description: Sends Telegram messages with optional inline keyboards, photo, video, or document attachments. Used by all workflows that need to notify or request approval from the operator.
---

# Telegram Bot

## When to use
Any workflow that needs to notify the operator or request a decision.

## Endpoints

| Method | URL | Use |
|---|---|---|
| `sendMessage` | `https://api.telegram.org/bot<TOKEN>/sendMessage` | Text + inline keyboard |
| `sendPhoto` | `https://api.telegram.org/bot<TOKEN>/sendPhoto` | Thumbnail preview |
| `sendVideo` | `https://api.telegram.org/bot<TOKEN>/sendVideo` | Final video preview (≤50 MB) |
| `sendDocument` | `https://api.telegram.org/bot<TOKEN>/sendDocument` | Larger video as file (≤2 GB) |
| `editMessageText` | same | Update message after action |
| `editMessageReplyMarkup` | same | Remove buttons after click |

## Inline keyboard payload
```json
{
  "chat_id": "{{ $env.TELEGRAM_CHAT_ID }}",
  "text": "📰 *New script for review*\n\n*Title:* ...\n*Source:* ...\n\n```\n<script text>\n```",
  "parse_mode": "Markdown",
  "reply_markup": {
    "inline_keyboard": [[
      { "text": "✅ Approve", "callback_data": "script:abc-123:approve" },
      { "text": "✏️ Edit", "callback_data": "script:abc-123:edit" },
      { "text": "❌ Reject", "callback_data": "script:abc-123:reject" }
    ]]
  }
}
```

## Constraints
- Text body max 4096 chars — truncate long scripts and link to full text
- Video file ≤ 50 MB via `sendVideo`; use `sendDocument` for larger
- Always set `chat_id` from env var, never hardcoded
- Always use `Markdown` or `MarkdownV2` parse_mode; escape special chars in user content

## Forbidden
- Never send to a chat_id not in `TELEGRAM_ALLOWED_USER_IDS`
- Never include the bot token in any logged message
