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
       │         ┌────────────┐ ┌─────────┐                  │
       │         │  Finalize  │→│ Publish │                  │
       │         └────────────┘ └─────────┘                  │
       └────┬───────────────────────────────────────┬────────┘
            │                                       │
            ▼                                       ▼
       ┌─────────────────┐                  ┌──────────────────┐
       │ Supabase shared │                  │  External APIs   │
       │  (news_* tables)│                  │  Hedra, 11Labs,  │
       │  + Storage      │                  │  OpenAI, YouTube │
       └────────┬────────┘                  └──────────────────┘
                │
                ▼
       ┌─────────────────────────────┐
       │   Next.js Dashboard (web)   │
       │  - /scripts/queue           │  ⏸ Script approval
       │  - /videos/queue            │  ⏸ Video approval
       │  - /publications            │   History
       │  - /sources                 │   Source management
       └─────────────────────────────┘
                       ▲
                       │
                    [Owner]
```

## Components

### Frontend (apps/web)
Next.js 14 dashboard for approval queues, history, and configuration.

### Backend (Supabase, shared VPS)
- Postgres with `news_*` table namespace
- RLS-enforced multi-tenancy with nexus
- Storage buckets: `news-renders`, `news-final-videos`, `news-thumbnails`
- Realtime for live dashboard updates

### Automation (n8n, shared VPS)
- All workflows in folder `NEWS`
- All credentials prefixed `news-`
- Triggers: cron (ingest, curate, analytics), event (status changes), manual (republish)

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

See `flow-map.md` for the step-by-step pipeline with approval points.

## Security Boundaries

- All client-side code uses `NEXT_PUBLIC_SUPABASE_ANON_KEY` (RLS-bound)
- Service-role key only in Edge Functions / server route handlers
- YouTube OAuth refresh token never reaches client
- Webhook endpoints validate `X-Webhook-Secret`

## Shared Infrastructure with Nexus

See `shared-infrastructure.md`.
