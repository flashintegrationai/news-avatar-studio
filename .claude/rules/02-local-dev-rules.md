# Rule 02 — Local Development Rules

## Development Is Local
- Next.js app runs at `http://localhost:3000`
- No local backend infrastructure to manage

## Remote Services via Env Vars Only
| Service | Connection |
|---|---|
| Supabase | `NEXT_PUBLIC_SUPABASE_URL` + keys |
| n8n | `N8N_BASE_URL` + `N8N_API_KEY` |
| Hedra | `HEDRA_API_KEY` |
| ElevenLabs | `ELEVENLABS_API_KEY` |
| YouTube | OAuth refresh token |

## Do NOT Install Locally
- Docker — not needed
- n8n — runs on VPS
- Supabase — remote
- PostgreSQL — using remote Supabase
- FFmpeg — locally for testing OK, production runs on VPS

## Env File
- `cp .env.example apps/web/.env.local`
- Never commit `.env.local`
- App fails fast on missing required vars

## Running
```bash
cd apps/web
npm install
npm run dev
```

## Supabase Migrations
- Install Supabase CLI globally
- `supabase link --project-ref <ref>` (one time)
- `supabase migration new <name>`
- `supabase db push` (ASK USER BEFORE applying to remote)
