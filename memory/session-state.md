# Session State

**Last updated:** 2026-05-17

## Current Work Block

Bootstrap of the news-avatar-studio repository. Created base structure, memory architecture, .claude/ configuration, agents, skills, rules, and documentation.

## Next Steps

1. ~~Supabase migrations~~ ✅ Done 2026-05-17 (8 news_* tables applied via MCP)
2. Scaffold the Next.js app in `apps/web/`
3. Create the first n8n workflow JSON: `NEWS - Ingest Sources` (cron + RSS parse + Supabase insert)
4. Provision Hedra account + Character-3 character ID (USER)
5. Provision ElevenLabs account + voice ID (USER)
6. Provision YouTube Data API OAuth credentials (USER)
7. Build the approval dashboard pages: `/scripts/queue` and `/videos/queue`
8. Seed `news_sources` with initial RSS feeds (Reuters, AP, BBC)

## Active Blockers

- No Hedra account yet — need API key + character_id before render workflow can be built
- No ElevenLabs account yet — need API key + voice_id
- No YouTube Data API OAuth set up yet — need client_id, secret, refresh_token

## Recent Decisions

- Mixed Claude+Codex agent architecture (single agent set, runtime-flexible)
- Shared VPS (Supabase + n8n) with nexus-crm, isolated by `news_*` table prefix and `NEWS - *` workflow prefix
- Full-auto trigger from RSS, with human approval at script and final video
- Stack: Hedra + ElevenLabs (~$15/mo) + OpenAI/Claude for scripts + FFmpeg edit
- Repo created public at github.com/flashintegrationai/news-avatar-studio
