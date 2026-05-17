# Database Schema

All tables prefixed `news_*` and live in the shared Supabase Postgres with `nexus-crm`.

## Tables

### `news_sources`
Configured RSS feeds and NewsAPI queries.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| type | text | `rss` \| `newsapi` |
| name | text | Human-readable label |
| url | text | RSS URL or NewsAPI endpoint |
| query_params | jsonb | For NewsAPI: q, sources, language, etc. |
| category | text | freeform tag |
| poll_interval | text | e.g. `3 hours` |
| is_active | bool | default true |
| last_polled_at | timestamptz | |
| last_error | text | nullable |
| created_at | timestamptz | default now() |
| updated_at | timestamptz | default now() |

### `news_items`
Raw ingested news items.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| source_id | uuid FK → news_sources | |
| title | text | |
| url | text UNIQUE | dedupe key |
| url_hash | text UNIQUE | sha256(url) for index |
| body | text | full article text or summary |
| author | text | nullable |
| published_at | timestamptz | from source |
| status | text | `pending` \| `selected` \| `skipped` |
| curator_score | numeric | 0-100 |
| curator_reason | text | LLM rationale |
| skip_reason | text | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### `news_scripts`
Generated video scripts.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| news_item_id | uuid FK → news_items | |
| content | text | the script |
| word_count | int | |
| estimated_seconds | int | |
| llm_provider | text | `openai` \| `anthropic` |
| llm_model | text | e.g. `gpt-4o` |
| status | text | `draft` \| `approved` \| `rejected` \| `needs_edit` |
| approved_by | uuid FK → auth.users | |
| approved_at | timestamptz | |
| rejection_reason | text | nullable |
| edit_notes | text | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### `news_renders`
Hedra render jobs.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| script_id | uuid FK → news_scripts | |
| hedra_job_id | text | from Hedra API |
| audio_url | text | ElevenLabs MP3 in storage |
| video_url | text | Hedra output in storage |
| status | text | `processing` \| `done` \| `failed` |
| error_message | text | nullable |
| started_at | timestamptz | |
| completed_at | timestamptz | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### `news_videos`
Final edited videos.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| render_id | uuid FK → news_renders | |
| final_url | text | edited MP4 in storage |
| subtitle_url | text | SRT in storage |
| duration_seconds | int | |
| status | text | `pending_approval` \| `approved` \| `rejected` \| `needs_edit` |
| approved_by | uuid | |
| approved_at | timestamptz | |
| publish_confirmed_at | timestamptz | nullable — required for publish |
| rejection_reason | text | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### `news_publications`
YouTube uploads and performance metrics.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| video_id | uuid FK → news_videos | |
| youtube_video_id | text UNIQUE | |
| youtube_url | text | |
| title | text | |
| description | text | |
| tags | text[] | |
| thumbnail_url | text | |
| scheduled_for | timestamptz | nullable |
| published_at | timestamptz | |
| status | text | `published` \| `scheduled` \| `failed` \| `quota_blocked` |
| metrics_json | jsonb | views, watch_time, retention, ctr |
| last_metrics_at | timestamptz | |
| error_message | text | nullable |
| created_at | timestamptz | |
| updated_at | timestamptz | |

### `news_approvals`
Audit log of approval decisions.

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| entity_type | text | `script` \| `video` |
| entity_id | uuid | |
| decision | text | `approve` \| `reject` \| `needs_edit` |
| reason | text | nullable |
| user_id | uuid FK → auth.users | |
| created_at | timestamptz | |

### `news_audit_logs`
All mutations across `news_*` tables (no DELETE policy — append-only).

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | |
| table_name | text | |
| record_id | uuid | |
| operation | text | `INSERT` \| `UPDATE` \| `DELETE` |
| changed_fields | jsonb | |
| user_id | uuid | nullable |
| source | text | `dashboard` \| `n8n` \| `system` |
| created_at | timestamptz | |

## Indexes

- `news_items(url_hash)` UNIQUE
- `news_items(status, published_at DESC)` — curation queries
- `news_scripts(status, created_at DESC)` — approval queue
- `news_videos(status, created_at DESC)` — approval queue
- `news_publications(published_at DESC)` — recent publications
- `news_audit_logs(table_name, record_id, created_at DESC)` — audit lookups

## Relationships

```
news_sources 1─* news_items 1─1 news_scripts 1─1 news_renders 1─1 news_videos 1─1 news_publications
```

Approval log relates polymorphically via `entity_type` + `entity_id`.
