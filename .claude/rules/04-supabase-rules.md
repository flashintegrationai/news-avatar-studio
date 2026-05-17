# Rule 04 — Supabase Rules

## Namespace Isolation (CRITICAL)
- All tables: `news_*` prefix
- Never touch nexus tables (`leads`, `quotes`, `jobs`, `customers`, etc.)
- Never disable RLS on any table

## Key Separation
| Key | Use | Safe for frontend? |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Client + server (with RLS) | YES |
| `SUPABASE_SERVICE_ROLE_KEY` | Server only | **NEVER** |

Service role bypasses all RLS — leaking it = full DB compromise.

## RLS Required
1. `ALTER TABLE news_<name> ENABLE ROW LEVEL SECURITY;`
2. At least one policy (default-deny without policies)
3. Test policies for the intended role

## Migrations
- File: `supabase/migrations/{timestamp}_{name}.sql`
- Applied via `supabase db push` (after user confirmation)
- Never raw SQL on prod except emergency with user approval

## Client Patterns
All access happens server-side (n8n nodes and Edge Functions). There is no browser client. Use the n8n Supabase node with the `news-supabase` credential.

## Realtime
Not used. Notifications go through the Telegram bot instead of Realtime subscriptions.

## Storage Buckets (all private, signed URLs only)
- `news-renders` — Hedra render outputs (audio + video)
- `news-final-videos` — Edited final videos
- `news-thumbnails` — DALL-E thumbnails
- Generate signed URLs server-side (service role)

## Error Handling
Always check `error` from Supabase calls. Never silently swallow.
