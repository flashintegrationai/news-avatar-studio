# Architecture

## High-Level Diagram

```
                 ┌──────────────────────────────────┐
                 │      News Sources (external)     │
                 │  RSS feeds + NewsAPI + Webhooks  │
                 └────────────────┬─────────────────┘
                                  │
                                  ▼
       ┌─────────────────────────────────────────────────────┐
       │           n8n (shared VPS — folder NEWS)            │
       │  ┌───────────┐ ┌──────────┐ ┌────────┐ ┌─────────┐  │
       │  │  Ingest   │→│  Curate  │→│ Script │→│  Render │  │
       │  └───────────┘ └──────────┘ └────────┘ └─────────┘  │
       │         ┌────────────┐ ┌─────────┐ ┌───────────┐    │
       │         │  Finalize  │→│ Publish │ │  Approvals│    │
       │         └────────────┘ └─────────┘ │  (webhook)│    │
       │                                    └───────────┘    │
       └────┬─────────────────┬─────────────────┬────────────┘
            │                 │                 │
            ▼                 ▼                 ▼
       ┌──────────────┐ ┌──────────────┐ ┌────────────────┐
       │  Supabase    │ │ External API │ │  Telegram Bot  │
       │ (news_* + 8  │ │  Hedra, 11L, │ │  ⬅⬆ outgoing   │
       │  buckets)    │ │ OpenAI, YT   │ │  ⬇⬅ callbacks  │
       └──────────────┘ └──────────────┘ └───────┬────────┘
                                                 │
                                                 ▼
                                            ┌─────────┐
                                            │ Operator│
                                            │ (phone) │
                                            └─────────┘
```

## Components

### Telegram Bot (UI surface)
The only operator interface. Sends:
- Approval requests with inline keyboards (script, video)
- Publication confirmations
- Error alerts
- Daily analytics summaries
- Quota warnings

Receives:
- Button taps (callback_query)
- Free-form messages for editing scripts (optional future feature)

### Backend (Supabase, shared VPS)
- Postgres with `news_*` table namespace
- RLS-enforced multi-tenancy with nexus
- Storage buckets: `news-renders`, `news-final-videos`, `news-thumbnails`
- No Realtime subscriptions (Telegram replaces that need)

### Automation (n8n, shared VPS)
- All workflows in folder `NEWS`
- All credentials prefixed `news-`
- Triggers: cron (ingest, curate, analytics), event (status changes), Telegram webhook (callbacks)

### External APIs
- **OpenAI / Anthropic** — script generation + curation scoring + thumbnail (DALL-E) + subtitles (Whisper)
- **ElevenLabs** — voice synthesis
- **Hedra** — Character-3 avatar render
- **YouTube Data API v3** — upload + metadata + thumbnail
- **YouTube Analytics API** — performance tracking
- **NewsAPI** (optional) — news source

### FFmpeg (on VPS)
Runs inside n8n via Execute Command node. Concat + subtitles + audio normalization.

## Data Flow

See `flow-map.md` for the step-by-step pipeline with Telegram approval points.

## Security Boundaries

- Telegram bot token only in `news-telegram` credential and `TELEGRAM_BOT_TOKEN` env
- Service-role Supabase key only in n8n credentials / Edge Functions
- YouTube OAuth refresh token in `news-youtube` credential only
- Telegram callbacks validated by `secret_token` header + sender ID whitelist
- Webhook endpoints (n8n) validate `X-Webhook-Secret`

## Shared Infrastructure with Nexus

See `shared-infrastructure.md`.
