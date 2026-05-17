# Flow Map

Step-by-step pipeline from RSS ingestion to YouTube publication, controlled entirely from Telegram.

---

```
[1] INGEST  (cron every 3h)
    Workflow: NEWS - Ingest Sources
    Reads:    news_sources WHERE is_active=true
    Writes:   INSERT news_items (dedupe via url_hash, continueOnFail on conflict)
              │
              ▼
[2] CURATE  (cron daily 08:00 + manual button)
    Workflow: NEWS - Curate Top Stories
    Reads:    news_items pending + last 7 days publications
    Writes:   UPDATE news_items SET status='selected'|'skipped'
    Calls:    NEWS - Generate Script (per selected item)
              │
              ▼
[3] SCRIPT  (event-triggered)
    Workflow: NEWS - Generate Script
    Action:   LLM call → structured script
    Writes:   INSERT news_scripts { status='draft' }
    Calls:    NEWS - Telegram Notify (script approval message)
              │
              ▼
    ┌─────────────────────────────────────────────────┐
    │  📲 TELEGRAM — GATE 1: SCRIPT APPROVAL          │
    │                                                 │
    │  Bot sends:                                     │
    │    📰 NEW SCRIPT                                │
    │    Title: ...                                   │
    │    Source: ...                                  │
    │    [code block with full script]                │
    │                                                 │
    │  Inline buttons:                                │
    │    [✅ Approve]  [✏️ Edit]  [❌ Reject]          │
    │                                                 │
    │  Operator taps → callback fires:                │
    │    NEWS - Telegram Approvals webhook            │
    │    ↳ validates secret_token + user_id           │
    │    ↳ parses "script:<id>:approve"               │
    │    ↳ UPDATE news_scripts SET status='approved'  │
    │    ↳ INSERT news_approvals                      │
    │    ↳ edits message (removes buttons)            │
    └─────────────────────────────────────────────────┘
              │ approved → triggers NEWS - Render Hedra
              ▼
[4] RENDER  (event-triggered)
    Workflow: NEWS - Render Hedra
    Action:   (a) ElevenLabs TTS → MP3 → Supabase Storage
              (b) Hedra POST /v1/characters with audio URL → job_id
              (c) Poll status until done
              (d) Download video → Supabase Storage news-renders/video/
    Writes:   INSERT news_renders { status='done', video_url }
              │
              ▼
[5] EDIT  (event-triggered)
    Workflow: NEWS - Finalize Video
    Action:   (a) Whisper → SRT subtitles
              (b) FFmpeg concat + subs + normalize
              (c) Upload final.mp4 to news-final-videos/
    Writes:   INSERT news_videos { status='pending_approval' }
    Calls:    NEWS - Telegram Notify (video approval message)
              │
              ▼
    ┌─────────────────────────────────────────────────┐
    │  📲 TELEGRAM — GATE 2: VIDEO APPROVAL            │
    │                                                 │
    │  Bot sends:                                     │
    │    🎬 VIDEO READY                                │
    │    [video file, ≤50MB] or [signed URL link]     │
    │    Duration: 2:08                               │
    │                                                 │
    │  Inline buttons:                                │
    │    [📺 Publish Now]  [📅 Schedule]  [❌ Reject]  │
    │                                                 │
    │  publish_now → sets publish_confirmed_at=now()  │
    │  schedule → prompts for date/time               │
    │  reject → status='rejected'                     │
    └─────────────────────────────────────────────────┘
              │ publish_now → triggers NEWS - Publish YouTube
              ▼
[6] PUBLISH  (event-triggered)
    Workflow: NEWS - Publish YouTube
    Pre:      Requires status='approved' AND publish_confirmed_at IS NOT NULL
    Action:   (a) LLM → SEO title (≤60), description, 5-15 tags
              (b) DALL-E 3 → thumbnail 1280x720
              (c) YouTube videos.insert (resumable upload)
              (d) thumbnails.set
    Writes:   INSERT news_publications { youtube_url, ... }
    Calls:    NEWS - Telegram Notify ("✅ Published! <url>")
              │
              ▼
[7] TRACK  (cron daily 09:00)
    Workflow: NEWS - Track Performance
    Action:   YouTube Analytics → metrics per recent video
    Writes:   UPDATE news_publications SET metrics_json
    Calls:    NEWS - Telegram Notify (daily summary)

[8] ERRORS  (any stage)
    Any workflow that fails → NEWS - Telegram Notify with 🚨 alert
```

---

## Telegram message catalog

| Trigger | Bot message | Buttons |
|---|---|---|
| Script `draft` created | `📰 NEW SCRIPT\nTitle\nSource\n<script>` | Approve / Edit / Reject |
| Video `pending_approval` | `🎬 VIDEO READY\n<video file>` | Publish Now / Schedule / Reject |
| Publication success | `✅ Published: <youtube_url>` | (none) |
| Pipeline error | `🚨 <stage>: <error>` | Retry / Dismiss |
| Daily metrics | `📊 Yesterday: views, watch time, top video` | (none) |
| Quota warning | `⚠️ <service> quota at <X>%` | (none) |

## Failure Handling per Stage

| Stage | Common failures | Recovery |
|---|---|---|
| Ingest | RSS down, NewsAPI rate limit | Telegram alert, mark source `last_error`, retry next cycle |
| Curate | LLM timeout | Retry once, fallback to recency-only score |
| Script | LLM produces too-long output | Auto-truncate + re-prompt once |
| Render | Hedra quota exhausted | Telegram alert, halt, queue for next day |
| Edit | FFmpeg crash | Telegram alert with stderr |
| Publish | YouTube quota or content rejection | Telegram alert, halt this video |
| Track | YouTube Analytics delay | Retry next day |
