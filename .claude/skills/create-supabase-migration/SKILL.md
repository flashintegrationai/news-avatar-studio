---
name: create-supabase-migration
description: Creates a Supabase migration following project conventions. Enforces news_ prefix on all tables, RLS-on by default, and proper indexing. Never applies to remote without user confirmation.
---

# Create Supabase Migration

## Naming
- File: `supabase/migrations/{YYYYMMDDHHMMSS}_{descriptive_name}.sql`
- Tables: `news_*` (e.g., `news_items`, `news_scripts`)

## Template
```sql
-- Migration: {{name}}
-- Created: {{date}}

CREATE TABLE news_{{name}} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- columns
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE news_{{name}} ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role full access"
  ON news_{{name}} FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Authenticated read"
  ON news_{{name}} FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE INDEX idx_news_{{name}}_created_at ON news_{{name}}(created_at DESC);

CREATE TRIGGER update_news_{{name}}_updated_at
  BEFORE UPDATE ON news_{{name}}
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Steps
1. Write migration file locally
2. Lint SQL
3. Generate types preview (does not require apply): `supabase db diff`
4. ASK USER before applying to remote: `supabase db push`
5. After apply: regenerate types `supabase gen types typescript --project-id {{ref}} > apps/web/types/supabase.ts`

## Forbidden
- DROP TABLE without explicit user approval
- Disabling RLS
- Long-running schema changes during business hours without `CONCURRENTLY`
