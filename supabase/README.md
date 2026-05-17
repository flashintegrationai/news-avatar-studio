# Supabase

Migrations and seed data for the `news_*` schema namespace.

## Structure
- `migrations/` — timestamped SQL files (created via `supabase migration new <name>`)
- `seed.sql` — initial news_sources (RSS feeds)

## Apply migrations
```bash
supabase link --project-ref <ref>   # one time
supabase db push                     # ASK USER BEFORE running on remote
```

## Generate types
```bash
supabase gen types typescript --project-id <ref> > ../apps/web/types/supabase.ts
```

See `../docs/database-schema.md` for the full schema reference.
