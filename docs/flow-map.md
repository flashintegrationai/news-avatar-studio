# Flow Map

Step-by-step pipeline from RSS ingestion to YouTube publication, including the two human approval gates.

---

```
[1] INGEST  (cron every 3h)
    Workflow: NEWS - Ingest Sources
    Trigger:  Schedule node
    Reads:    news_sources WHERE is_active=true
    Action:   Fetch RSS / NewsAPI → dedupe by URL hash
    Writes:   INSERT news_items { source_id, title, url, body, published_at, status='pending' }
              │
              ▼
[2] CURATE  (cron daily 08:00 + manual button)
    Workflow: NEWS - Curate Top Stories
    Trigger:  Schedule node + Webhook node
    Reads:    news_items WHERE status='pending' AND published_at > now() - '24h'
              news_publications WHERE published_at > now() - '7 days' (for topic-fatigue check)
    Action:   LLM scores each pending item → picks top N (default 3)
    Writes:   UPDATE news_items SET status='selected'|'skipped', curator_score, curator_reason
    Calls:    POST {NEWS_SCRIPT_WEBHOOK_URL} for each selected item
              │
              ▼
[3] SCRIPT  (event-triggered)
    Workflow: NEWS - Generate Script
    Trigger:  Webhook from [2]
    Reads:    news_items.body + channel tone config
    Action:   LLM call with structured prompt (Hook/Context/Facts/Analysis/Outro)
    Writes:   INSERT news_scripts { news_item_id, content, word_count, est_seconds, status='draft' }
    Notifies: Supabase Realtime → dashboard updates /scripts/queue
              │
              ▼
    ┌────────────────────────────────────────┐
    │  🟡 GATE 1: SCRIPT APPROVAL            │
    │  Dashboard: /scripts/queue             │
    │  Actions:                              │
    │    ✓ Approve  → status='approved'     │
    │    ✗ Reject   → status='rejected'     │
    │    ✎ Edit     → modify content, save  │
    │  Logged in news_approvals              │
    └────────────────────────────────────────┘
              │ approved
              ▼
[4] RENDER  (event-triggered)
    Workflow: NEWS - Render Hedra
    Trigger:  Webhook (fired when scripts.status='approved')
    Reads:    news_scripts.content + character_id + voice_id (env)
    Action:   (a) ElevenLabs TTS → MP3
              (b) Upload MP3 to Supabase Storage (news-renders/audio/)
              (c) POST Hedra /v1/characters with audio URL → job_id
              (d) Poll status every 30s (timeout 20 min)
              (e) Download video → upload to news-renders/video/
    Writes:   INSERT news_renders { script_id, hedra_job_id, audio_url, video_url, status='done' }
              │
              ▼
[5] EDIT  (event-triggered)
    Workflow: NEWS - Finalize Video
    Trigger:  Webhook (renders.status='done')
    Reads:    news_renders.video_url
    Action:   (a) Whisper → SRT subtitles
              (b) FFmpeg concat: intro + avatar + outro
              (c) Burn subtitles, normalize audio to -16 LUFS
              (d) Upload final.mp4 to news-final-videos/
    Writes:   INSERT news_videos { render_id, final_url, subtitle_url, duration, status='pending_approval' }
    Notifies: Realtime → /videos/queue
              │
              ▼
    ┌────────────────────────────────────────┐
    │  🟡 GATE 2: VIDEO APPROVAL             │
    │  Dashboard: /videos/queue              │
    │  Preview player inline                 │
    │  Actions:                              │
    │    ✓ Approve  → status='approved'     │
    │    ✗ Reject   → status='rejected'     │
    │    📅 Schedule → set publish_at        │
    │  Approval sets approved_at, by_user_id │
    │  Logged in news_approvals              │
    └────────────────────────────────────────┘
              │ approved (still NOT published)
              ▼
    ┌────────────────────────────────────────┐
    │  🔴 EXPLICIT PUBLISH CONFIRMATION      │
    │  User clicks "Publish Now" button      │
    │  Sets news_videos.publish_confirmed_at │
    └────────────────────────────────────────┘
              │
              ▼
[6] PUBLISH  (event-triggered)
    Workflow: NEWS - Publish YouTube
    Trigger:  Webhook (videos.publish_confirmed_at IS NOT NULL)
    Reads:    news_videos + news_scripts + news_items
    Action:   (a) LLM → SEO title (≤60 chars), description, 5-15 tags
              (b) DALL-E 3 → thumbnail 1280x720
              (c) Upload to news-thumbnails/
              (d) YouTube Data API v3 videos.insert (resumable upload)
              (e) thumbnails.set
    Writes:   INSERT news_publications { video_id, youtube_video_id, youtube_url, title, description, tags, published_at }
    Notifies: Realtime → dashboard shows public URL
              │
              ▼
[7] TRACK  (cron daily 09:00)
    Workflow: NEWS - Track Performance
    Trigger:  Schedule
    Reads:    news_publications WHERE published_at > now() - '30 days'
    Action:   YouTube Analytics API → views, watch time, retention, CTR
    Writes:   UPDATE news_publications SET metrics_json, last_metrics_at
```

---

## Where you SEE each step

| Stage | UI location | Backend evidence |
|---|---|---|
| Ingest | `/sources` (counts) | `news_items` rows |
| Curate | `/curation/history` | `news_items.status` + curator fields |
| Script | `/scripts/queue` ⏸ | `news_scripts` rows |
| Render | Inline progress on `/scripts/queue` | `news_renders` polling |
| Edit | Inline progress on `/videos/queue` | `news_videos` |
| Approve | `/videos/queue` ⏸ + `/scripts/queue` ⏸ | `news_approvals` log |
| Publish | `/publications` | `news_publications` + YouTube link |
| Track | `/publications/analytics` | metrics on publications |

## Failure Handling per Stage

| Stage | Common failures | Recovery |
|---|---|---|
| Ingest | RSS down, NewsAPI rate limit | Mark source `last_error`, retry next cycle |
| Curate | LLM timeout | Retry once, fallback to score-by-recency |
| Script | LLM produces too-long output | Auto-truncate + re-prompt once |
| Render | Hedra quota exhausted | Halt, notify user, queue for next day |
| Edit | FFmpeg crash | Log full stderr, surface to user |
| Publish | YouTube quota, content rejection | Halt this video, do not auto-retry |
| Track | YouTube Analytics delay | Retry next day |
