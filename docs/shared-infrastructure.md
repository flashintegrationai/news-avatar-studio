# Shared Infrastructure with nexus-crm

This project shares the Hostinger VPS (Supabase + n8n) with `nexus-crm`. Isolation is enforced by naming convention and RLS.

## What is shared

| Resource | Instance | Isolation method |
|---|---|---|
| Supabase Postgres | Same DB | Table prefix `news_*` |
| Supabase Storage | Same project | Bucket names `news-*` |
| Supabase Auth | Same project | Optional: same user accounts, different RLS scopes |
| n8n | Same instance | Folder `NEWS` + workflow prefix `NEWS - ` + credential prefix `news-` |

## What is NOT shared

| Resource | Reason |
|---|---|
| External API credentials | Each project uses its own Hedra/ElevenLabs/YouTube/etc. keys |
| Domain names | nexus.example.com vs news.example.com |
| GitHub repos | Separate repos |
| Memory files | Each project has its own `memory/` and `.claude/agent-memory/` |

## Naming Convention (CRITICAL)

### Supabase tables
- News: `news_sources`, `news_items`, `news_scripts`, `news_renders`, `news_videos`, `news_publications`, `news_approvals`, `news_audit_logs`
- Nexus: `leads`, `quotes`, `jobs`, `customers`, `conversations`, `messages`, etc.

Never mix. A migration that touches a non-prefixed table from this project is a bug.

### n8n workflows
- News: `NEWS - Ingest Sources`, `NEWS - Curate Top Stories`, etc.
- Nexus: `NEXUS - Book Appointment`, `NEXUS - Lead Created`, etc.

### n8n credentials
- News: `news-supabase`, `news-elevenlabs`, `news-hedra`, `news-youtube`, `news-openai`
- Nexus: `nexus-supabase`, `nexus-meta`, `nexus-resend`, etc.

### Storage buckets
- News: `news-renders`, `news-final-videos`, `news-thumbnails`
- Nexus: `estimate-images`, `job-photos`

## RLS Policies

Every `news_*` table requires:

```sql
ALTER TABLE news_<name> ENABLE ROW LEVEL SECURITY;

-- Service role (server-side, n8n, edge functions)
CREATE POLICY "Service role full access" ON news_<name>
  FOR ALL USING (auth.role() = 'service_role');

-- Authenticated users (dashboard operators)
CREATE POLICY "Authenticated read" ON news_<name>
  FOR SELECT USING (auth.role() = 'authenticated');
```

Optionally, you can scope by user role (admin/editor/viewer) using a custom claim.

## Conflict avoidance

| Risk | Mitigation |
|---|---|
| Migration name collision | Both projects use timestamp prefixes; names are unique enough |
| n8n credential name collision | Strict `news-` / `nexus-` prefix |
| Storage bucket collision | Project-prefixed bucket names |
| API rate limits shared | Each project uses different external API keys → no cross-contention |
| Database connection pool | Monitor pool usage on Supabase dashboard; upgrade plan if needed |
| n8n executor concurrency | Coordinate cron schedules to avoid simultaneous peak load |

## Cross-project communication

Currently: **none**.

If ever needed (e.g., a nexus lead generates a video idea), use Supabase as the integration layer — never call across n8n folders directly.

## Migration / Decoupling Plan

If at some point this project needs to be split off:
1. Dump `news_*` tables (`pg_dump -t 'news_*'`)
2. Create new Supabase project
3. Restore dump
4. Update `.env.local` URLs/keys
5. Export `NEWS - *` workflows from n8n
6. Import into new n8n instance
7. Migrate storage buckets

Estimated effort: ~1 day. Decoupling is intentionally low-friction.
