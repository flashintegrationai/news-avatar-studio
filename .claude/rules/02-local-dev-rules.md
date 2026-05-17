# Rule 02 — Local Development Rules

## No local web app
There is no Next.js or frontend in this project. Telegram is the UI.

## Remote Services via Env Vars Only
| Service | Connection |
|---|---|
| Supabase | `SUPABASE_URL` + keys |
| n8n | `N8N_BASE_URL` + `N8N_API_KEY` |
| Telegram | `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` + `TELEGRAM_WEBHOOK_SECRET` |
| Hedra | `HEDRA_API_KEY` |
| ElevenLabs | `ELEVENLABS_API_KEY` |
| YouTube | OAuth refresh token |
| OpenAI / Anthropic | API keys |

## Do NOT Install Locally
- Docker — not needed
- n8n — runs on VPS
- Supabase — remote
- PostgreSQL — using remote Supabase
- FFmpeg — runs inside n8n on VPS (Execute Command node)

## Env File
- `cp .env.example .env.local`
- Never commit `.env.local`
- App-less project — env mainly serves migration tooling and local scripts

## Supabase Migrations
- Install Supabase CLI globally
- `supabase link --project-ref <ref>` (one time)
- `supabase migration new <name>`
- `supabase db push` (ASK USER BEFORE applying to remote)

## Editing workflows
- All workflows defined in `n8n/workflows/*.json`
- Use n8n MCP tools to create/update/validate
- Never edit the JSON by hand in production — always go through MCP `update_workflow` or n8n UI

## Local scripts
Place utilities in `scripts/` (e.g., one-shot data fixers, Telegram webhook re-registration).
