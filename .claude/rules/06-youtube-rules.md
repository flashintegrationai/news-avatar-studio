# Rule 06 — YouTube Rules

## Publication Is Irreversible
A published video is public immediately (or scheduled). Mistakes are costly. Therefore:
- ALWAYS require user click of "Publish Now" in dashboard
- NEVER publish without `news_videos.publish_confirmed_at` set
- NEVER bypass the approval flow

## YouTube API Quota
- Daily quota: 10,000 units default
- `videos.insert` = 1,600 units (~6 uploads/day max)
- `videos.update` = 50 units
- Monitor: `quota_used_today` in `news_publications` metadata
- If quota < 2,000 units remaining: defer non-critical operations

## Required Metadata
- `categoryId`: 25 (News & Politics) by default
- `defaultLanguage`: from `CHANNEL_LANGUAGE` env (default 'en')
- `madeForKids`: false
- `privacyStatus`: `public` (or `private` for scheduled)

## Title Rules
- ≤60 chars (or it truncates in feed)
- Match content (no bait)
- Avoid all-caps
- Include 1-2 high-intent keywords

## Description Rules
- First 2 lines visible without "show more" → put hook there
- Include source attribution (URL)
- Include channel CTAs (subscribe, socials)
- Include relevant timestamps for multi-segment videos

## Tags
- 5-15 tags
- Mix of broad ("news", "2026") and specific (topic keywords)
- No misleading tags (YouTube penalizes)

## Thumbnails
- 1280x720 (or 1920x1080, same aspect)
- < 2 MB
- JPG/PNG
- High contrast, readable on mobile
- Avoid YouTube-banned imagery

## Copyright
- Never use copyrighted music without license
- Never quote >50 consecutive words from a copyrighted article
- B-roll from licensed sources only (Pexels, Pixabay, owned)

## On Strike/Rejection
- Halt all publishing
- Surface to user immediately
- Do not auto-retry
- Document in `memory/resolved-issues.md` after resolution
