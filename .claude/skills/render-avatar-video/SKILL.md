---
name: render-avatar-video
description: Renders a talking-avatar video via Hedra Character-3 API using the synthesized audio and configured character. Polls render status, downloads result, and stores it in Supabase Storage.
---

# Render Avatar Video

## Inputs
- `script_id`
- `audio_url` (signed Supabase URL from generate-voice)
- `character_id` (env: HEDRA_CHARACTER_ID)

## Steps
1. POST `https://api.hedra.com/v1/characters`
   ```json
   {
     "character_id": "{{character_id}}",
     "audio_source": { "url": "{{audio_url}}" },
     "aspect_ratio": "16:9"
   }
   ```
2. Receive `job_id`
3. INSERT `news_renders` { script_id, hedra_job_id, status='processing', started_at }
4. Poll `GET /v1/projects/{job_id}` every 30s (timeout 20 min)
5. On status='complete': download `video_url` → upload to Supabase Storage `news-renders/video/{render_id}.mp4`
6. UPDATE `news_renders` { status='done', video_url, completed_at }
7. Notify `video-editor` agent via webhook

## Quotas
- Verify remaining credits before render: `GET /v1/usage`
- If credits < estimated cost: fail with clear message to user

## Retries
- 2 retries on timeout/5xx
- 0 retries on 4xx (config issue)
