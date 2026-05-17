# News Avatar Studio

Fully automated YouTube news channel powered by AI avatar. **Controlled entirely from Telegram.**

## What it does

1. Ingests news from RSS feeds and NewsAPI (n8n cron)
2. Curates top stories with an LLM
3. Generates news scripts (~2 min editorial format)
4. 📲 Sends script to **Telegram** for approval (inline buttons: Approve / Edit / Reject)
5. Synthesizes voice with ElevenLabs
6. Renders avatar video with Hedra (Character-3)
7. Edits final video (intro/outro/subtitles) with FFmpeg
8. 📲 Sends final video to **Telegram** for approval + publish confirmation
9. Uploads to YouTube with auto-generated thumbnail and SEO metadata
10. 📲 Notifies on publish + daily metrics summary + error alerts

**Zero web UI — your phone is the dashboard.**

## Stack

- **Control**: Telegram Bot (inline keyboards + media messages)
- **Backend**: Supabase (shared VPS with nexus, schema-isolated)
- **Automation**: n8n (shared VPS, folder-isolated)
- **AI**: OpenAI/Claude (scripts), ElevenLabs (voice), Hedra (avatar), DALL-E 3 (thumbnails), Whisper (subs)
- **Publishing**: YouTube Data API v3

## Setup

1. Create a Telegram bot via [@BotFather](https://t.me/BotFather), save the token
2. Get your `chat_id` from `https://api.telegram.org/bot<TOKEN>/getUpdates` after sending a message
3. Copy `.env.example` → fill all values (Telegram, Hedra, ElevenLabs, YouTube, Supabase)
4. Apply Supabase migrations: `supabase db push`
5. Import n8n workflows from `n8n/workflows/` into the `NEWS` folder
6. Create n8n credentials prefixed `news-*`
7. Activate workflows

## Documentation

- [CLAUDE.md](./CLAUDE.md) — Master instructions for Claude Code
- [docs/architecture.md](./docs/architecture.md) — System architecture
- [docs/flow-map.md](./docs/flow-map.md) — Pipeline flow with Telegram approval points
- [docs/shared-infrastructure.md](./docs/shared-infrastructure.md) — Coexistence with nexus-crm
- [docs/database-schema.md](./docs/database-schema.md) — All `news_*` tables

## License

Private project — flashintegrationai
