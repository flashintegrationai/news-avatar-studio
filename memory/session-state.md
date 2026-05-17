# Session State

**Last updated:** 2026-05-17

## Current Work Block

Pivoted control surface to Telegram-only (no web dashboard). Refactored structure: added `telegram-bot-manager` agent, `telegram-bot` + `telegram-approvals` skills, replaced `08-ui-rules.md` with `08-telegram-rules.md`, deleted `apps/` directory, updated CLAUDE.md/README/env.example/docs.

`NEWS - Ingest Sources` workflow code is validated but not yet created in n8n (deferred until Telegram refactor commits).

## Next Steps

1. ✅ Supabase migration applied (8 news_* tables)
2. ✅ Telegram-only refactor committed
3. Create n8n credential `news-supabase` in n8n UI (USER, needs service role key)
4. Create n8n credential `news-telegram` in n8n UI (USER, needs bot token)
5. Create the workflow `NEWS - Ingest Sources` in n8n (validated code ready)
6. Seed `news_sources` with initial RSS feeds (Reuters, AP, BBC)
7. Build workflow `NEWS - Telegram Approvals` (webhook handler)
8. Build workflow `NEWS - Telegram Notify` (helper for sending messages)
9. Build workflow `NEWS - Generate Script` (LLM with Telegram notify on draft)
10. Register Telegram webhook with `setWebhook` (one-time, requires `TELEGRAM_WEBHOOK_SECRET`)
11. Provision Hedra account + Character-3 character ID (USER)
12. Provision ElevenLabs account + voice ID (USER)
13. Provision YouTube Data API OAuth credentials (USER)

## Active Blockers

- No Hedra account yet — need API key + character_id before render workflow can be built
- No ElevenLabs account yet — need API key + voice_id
- No YouTube Data API OAuth set up yet — need client_id, secret, refresh_token
- n8n credentials `news-supabase` and `news-telegram` not yet created in n8n UI

## Recent Decisions

- Telegram-only control surface (see `memory/closed-decisions.md` 2026-05-17 entry)
- Mixed Claude+Codex agent architecture
- Shared VPS with nexus-crm, isolated by `news_*` / `NEWS - *` / `news-*` naming
- Stack: Hedra + ElevenLabs + OpenAI/Claude + FFmpeg
