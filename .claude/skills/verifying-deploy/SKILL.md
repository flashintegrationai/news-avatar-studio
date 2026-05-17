---
name: verifying-deploy
description: Verifies a deployment is healthy. Checks build success, migrations applied, env vars present, webhook reachability, and runs a smoke test of the pipeline.
---

# Verifying Deploy

## Checklist
1. **Build:** `npm run build` exits 0
2. **Migrations:** all migrations in `supabase/migrations/` applied to target env
3. **Env vars:** all required vars present (compare against `.env.example`)
4. **Webhooks reachable:** ping each `NEWS_*_WEBHOOK_URL`
5. **API auth valid:**
   - Supabase: `auth.getUser()` via service role
   - n8n: `GET /api/v1/workflows`
   - Hedra: `GET /v1/usage`
   - ElevenLabs: `GET /v1/user`
   - YouTube: `GET /youtube/v3/channels?mine=true`
6. **Smoke test:** trigger `NEWS - Ingest Sources` manually; verify `news_items` row created
7. **Dashboard reachable:** GET / returns 200

## Output
- Table of green/yellow/red status per check
- If any red: do NOT mark deploy as healthy, surface specific failure
