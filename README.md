# News Avatar Studio

Fully automated YouTube news channel powered by AI avatar.

## What it does

1. Ingests news from RSS feeds and NewsAPI
2. Curates top stories with an LLM
3. Generates news scripts (2-min editorial format)
4. Synthesizes voice with ElevenLabs
5. Renders avatar video with Hedra (Character-3)
6. Edits final video (intro/outro/subtitles) with FFmpeg
7. Uploads to YouTube with auto-generated thumbnail and SEO metadata
8. Tracks performance via YouTube Analytics

Human approval required at two checkpoints: **script** and **final video**.

## Stack

- **Frontend**: Next.js 14 + Tailwind + shadcn/ui
- **Backend**: Supabase (shared VPS with nexus, schema-isolated)
- **Automation**: n8n (shared VPS, folder-isolated)
- **AI**: OpenAI/Claude (scripts), ElevenLabs (voice), Hedra (avatar), DALL-E 3 (thumbnails), Whisper (subs)
- **Publishing**: YouTube Data API v3

## Local development

```bash
cp .env.example apps/web/.env.local
# Fill in real API keys
cd apps/web && npm install && npm run dev
```

## Documentation

- [CLAUDE.md](./CLAUDE.md) — Master instructions for Claude Code
- [docs/architecture.md](./docs/architecture.md) — System architecture
- [docs/flow-map.md](./docs/flow-map.md) — Pipeline flow with approval points
- [docs/shared-infrastructure.md](./docs/shared-infrastructure.md) — Coexistence with nexus-crm
- [docs/database-schema.md](./docs/database-schema.md) — All `news_*` tables

## License

Private project — flashintegrationai
