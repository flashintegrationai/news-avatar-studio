---
name: publish-to-youtube
description: Uploads approved video to YouTube via Data API v3 with SEO metadata and DALL-E thumbnail. Requires both approval state AND explicit user confirmation. Records the publication and returns the public URL.
---

# Publish to YouTube

## Pre-conditions (BOTH required)
1. `news_videos.status = 'approved'`
2. User clicked "Publish Now" in dashboard (sets `news_videos.publish_confirmed_at`)

If either is missing → ABORT, do not call YouTube API.

## Steps
1. Generate SEO title (LLM, ≤60 chars)
2. Generate description (LLM, with hook in first 2 lines, source attribution, CTAs)
3. Generate 5-15 tags (LLM)
4. Generate thumbnail:
   - DALL-E 3: `1792x1024` (closest to 16:9, will resize)
   - Resize to `1280x720` via Sharp/FFmpeg
   - Upload to `news-thumbnails/{video_id}.jpg`
5. YouTube `videos.insert`:
   ```
   POST https://www.googleapis.com/upload/youtube/v3/videos?part=snippet,status
   Authorization: Bearer {{access_token}}
   ```
6. Wait for upload to complete (resumable upload)
7. `thumbnails.set` with thumbnail file
8. INSERT `news_publications` { video_id, youtube_video_id, youtube_url, title, description, tags, published_at }
9. Notify user with public URL

## Failure handling
- Quota exceeded → mark video as `quota_blocked`, queue for next day
- Auth expired → refresh token, retry once
- Content rejected by YouTube → mark `youtube_rejected`, surface reason to user
- Network error → 3 retries with exponential backoff
