# Workflows Overview

All workflows live in the n8n folder `NEWS` and use credentials prefixed `news-`.

| Workflow | Trigger | Purpose | Status |
|---|---|---|---|
| `NEWS - Ingest Sources` | Cron 3h | Fetch RSS/NewsAPI, dedupe, write to `news_items` | 🔴 To build |
| `NEWS - Curate Top Stories` | Cron daily 08:00 + manual | Score pending news, select top N | 🔴 To build |
| `NEWS - Generate Script` | Webhook | LLM script from selected news item | 🔴 To build |
| `NEWS - Render Hedra` | Webhook (script approved) | ElevenLabs + Hedra render | 🔴 To build |
| `NEWS - Finalize Video` | Webhook (render done) | Whisper subs + FFmpeg edit | 🔴 To build |
| `NEWS - Publish YouTube` | Webhook (video approved + confirmed) | Upload + thumbnail + metadata | 🔴 To build |
| `NEWS - Track Performance` | Cron daily 09:00 | YouTube Analytics → publications metrics | 🔴 To build |

## Legend
- 🟢 In production
- 🟡 Built, not yet active
- 🔴 To build
