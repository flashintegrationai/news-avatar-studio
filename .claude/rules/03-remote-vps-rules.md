# Rule 03 — Remote VPS Rules

## The VPS Is Off-Limits Without Explicit Permission

The Hostinger VPS hosts Supabase + n8n shared with nexus-crm. Claude must never take direct VPS actions without explicit user request.

## Prohibited (without permission)
- SSH into the VPS
- Restart any Docker container
- Modify `docker-compose.yml`
- Edit n8n workflows directly on the VPS UI (use MCP tools instead)
- Modify Nginx
- `supabase db reset` on remote
- Delete any data from production database
- Touch nexus-crm artifacts on the same VPS

## Allowed (via APIs)
- Calling n8n webhook URLs
- Reading/writing Supabase via JS client (RLS-scoped)
- Hedra / ElevenLabs / YouTube API calls
- `supabase db push` (after user confirmation)

## When User Asks for VPS Changes
Provide exact commands but do NOT execute. User reviews and runs.

## Why
Production data for two business projects lives on this VPS. Unauthorized changes can:
- Lose news data
- Disrupt nexus-crm operations
- Corrupt the database
