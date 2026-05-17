-- Migration: create_news_tables
-- Created:   2026-05-17
-- Purpose:   Initial schema for news-avatar-studio (8 tables, all news_* prefix)
-- Notes:     Shares the database with nexus-crm. NEVER touch nexus tables.
--            update_updated_at_column() may already exist from nexus — recreated idempotently.

-- ─── Helper: updated_at trigger function (idempotent) ──────────────────
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════
-- 1. news_sources — RSS feeds + NewsAPI queries
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_sources (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type            TEXT NOT NULL CHECK (type IN ('rss', 'newsapi')),
  name            TEXT NOT NULL,
  url             TEXT NOT NULL,
  query_params    JSONB,
  category        TEXT,
  poll_interval   INTERVAL NOT NULL DEFAULT '3 hours',
  is_active       BOOLEAN NOT NULL DEFAULT true,
  last_polled_at  TIMESTAMPTZ,
  last_error      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_news_sources_url ON public.news_sources(url);
CREATE INDEX IF NOT EXISTS idx_news_sources_active ON public.news_sources(is_active) WHERE is_active = true;

ALTER TABLE public.news_sources ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_sources: service role full access"
  ON public.news_sources FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "news_sources: authenticated read"
  ON public.news_sources FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_sources_updated_at
  BEFORE UPDATE ON public.news_sources
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 2. news_items — Raw ingested news
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id       UUID NOT NULL REFERENCES public.news_sources(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,
  url             TEXT NOT NULL,
  url_hash        TEXT NOT NULL,
  body            TEXT,
  author          TEXT,
  published_at    TIMESTAMPTZ,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'selected', 'skipped')),
  curator_score   NUMERIC(5,2),
  curator_reason  TEXT,
  skip_reason     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_news_items_url_hash ON public.news_items(url_hash);
CREATE INDEX IF NOT EXISTS idx_news_items_status_published ON public.news_items(status, published_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_items_source ON public.news_items(source_id, created_at DESC);

ALTER TABLE public.news_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_items: service role full access"
  ON public.news_items FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_items: authenticated read"
  ON public.news_items FOR SELECT USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_items_updated_at
  BEFORE UPDATE ON public.news_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 3. news_scripts — Generated video scripts
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_scripts (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  news_item_id        UUID NOT NULL REFERENCES public.news_items(id) ON DELETE CASCADE,
  content             TEXT NOT NULL,
  word_count          INTEGER,
  estimated_seconds   INTEGER,
  llm_provider        TEXT,
  llm_model           TEXT,
  status              TEXT NOT NULL DEFAULT 'draft'
                        CHECK (status IN ('draft', 'approved', 'rejected', 'needs_edit')),
  approved_by         UUID REFERENCES auth.users(id),
  approved_at         TIMESTAMPTZ,
  rejection_reason    TEXT,
  edit_notes          TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_news_scripts_status ON public.news_scripts(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_scripts_news_item ON public.news_scripts(news_item_id);

ALTER TABLE public.news_scripts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_scripts: service role full access"
  ON public.news_scripts FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_scripts: authenticated read"
  ON public.news_scripts FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "news_scripts: authenticated update (approval)"
  ON public.news_scripts FOR UPDATE USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_scripts_updated_at
  BEFORE UPDATE ON public.news_scripts
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 4. news_renders — Hedra render jobs
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_renders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  script_id       UUID NOT NULL REFERENCES public.news_scripts(id) ON DELETE CASCADE,
  hedra_job_id    TEXT,
  audio_url       TEXT,
  video_url       TEXT,
  status          TEXT NOT NULL DEFAULT 'processing'
                    CHECK (status IN ('processing', 'done', 'failed')),
  error_message   TEXT,
  started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_news_renders_status ON public.news_renders(status, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_renders_script ON public.news_renders(script_id);

ALTER TABLE public.news_renders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_renders: service role full access"
  ON public.news_renders FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_renders: authenticated read"
  ON public.news_renders FOR SELECT USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_renders_updated_at
  BEFORE UPDATE ON public.news_renders
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 5. news_videos — Final edited videos
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_videos (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  render_id               UUID NOT NULL REFERENCES public.news_renders(id) ON DELETE CASCADE,
  final_url               TEXT NOT NULL,
  subtitle_url            TEXT,
  duration_seconds        INTEGER,
  status                  TEXT NOT NULL DEFAULT 'pending_approval'
                            CHECK (status IN ('pending_approval', 'approved', 'rejected', 'needs_edit')),
  approved_by             UUID REFERENCES auth.users(id),
  approved_at             TIMESTAMPTZ,
  publish_confirmed_at    TIMESTAMPTZ,
  rejection_reason        TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_news_videos_status ON public.news_videos(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_videos_render ON public.news_videos(render_id);

ALTER TABLE public.news_videos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_videos: service role full access"
  ON public.news_videos FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_videos: authenticated read"
  ON public.news_videos FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "news_videos: authenticated update (approval)"
  ON public.news_videos FOR UPDATE USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_videos_updated_at
  BEFORE UPDATE ON public.news_videos
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 6. news_publications — YouTube uploads + metrics
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_publications (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id            UUID NOT NULL REFERENCES public.news_videos(id) ON DELETE CASCADE,
  youtube_video_id    TEXT,
  youtube_url         TEXT,
  title               TEXT NOT NULL,
  description         TEXT,
  tags                TEXT[],
  thumbnail_url       TEXT,
  scheduled_for       TIMESTAMPTZ,
  published_at        TIMESTAMPTZ,
  status              TEXT NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'published', 'scheduled', 'failed', 'quota_blocked')),
  metrics_json        JSONB,
  last_metrics_at     TIMESTAMPTZ,
  error_message       TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_news_publications_yt_id ON public.news_publications(youtube_video_id)
  WHERE youtube_video_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_news_publications_published_at ON public.news_publications(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_publications_video ON public.news_publications(video_id);

ALTER TABLE public.news_publications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_publications: service role full access"
  ON public.news_publications FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_publications: authenticated read"
  ON public.news_publications FOR SELECT USING (auth.role() = 'authenticated');

CREATE TRIGGER trg_news_publications_updated_at
  BEFORE UPDATE ON public.news_publications
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════════
-- 7. news_approvals — Audit log of approve/reject decisions
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_approvals (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type  TEXT NOT NULL CHECK (entity_type IN ('script', 'video')),
  entity_id    UUID NOT NULL,
  decision     TEXT NOT NULL CHECK (decision IN ('approve', 'reject', 'needs_edit')),
  reason       TEXT,
  user_id      UUID REFERENCES auth.users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_news_approvals_entity ON public.news_approvals(entity_type, entity_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_approvals_user ON public.news_approvals(user_id, created_at DESC);

ALTER TABLE public.news_approvals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_approvals: service role full access"
  ON public.news_approvals FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_approvals: authenticated read"
  ON public.news_approvals FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "news_approvals: authenticated insert (own)"
  ON public.news_approvals FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid());

-- ═══════════════════════════════════════════════════════════════════════
-- 8. news_audit_logs — Append-only mutation log
-- ═══════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS public.news_audit_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name      TEXT NOT NULL,
  record_id       UUID NOT NULL,
  operation       TEXT NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  changed_fields  JSONB,
  user_id         UUID,
  source          TEXT NOT NULL DEFAULT 'system'
                    CHECK (source IN ('dashboard', 'n8n', 'system')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_news_audit_logs_lookup
  ON public.news_audit_logs(table_name, record_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_news_audit_logs_recent
  ON public.news_audit_logs(created_at DESC);

ALTER TABLE public.news_audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "news_audit_logs: service role full access"
  ON public.news_audit_logs FOR ALL USING (auth.role() = 'service_role');
CREATE POLICY "news_audit_logs: authenticated read"
  ON public.news_audit_logs FOR SELECT USING (auth.role() = 'authenticated');
-- No INSERT/UPDATE/DELETE for non-service-role → append-only via service role only

-- ═══════════════════════════════════════════════════════════════════════
-- Done. 8 tables, RLS enabled, indexes in place.
-- ═══════════════════════════════════════════════════════════════════════
