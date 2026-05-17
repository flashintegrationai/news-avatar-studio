# Tech State

Integration status snapshot. Update when any service status changes.

**Last updated:** 2026-05-17

## Services

| Service | Status | Notes |
|---|---|---|
| Supabase (shared VPS) | 🟡 Pending | Need to apply `news_*` migrations |
| n8n (shared VPS) | 🟡 Pending | Folder `NEWS - *` to be created |
| OpenAI / Anthropic | 🟡 Pending | Need API key |
| ElevenLabs | 🔴 Not provisioned | Need account + voice_id |
| Hedra | 🔴 Not provisioned | Need account + character_id |
| YouTube Data API v3 | 🔴 Not provisioned | Need OAuth client + refresh token |
| DALL-E 3 (thumbnails) | 🟡 Pending | Via OpenAI key |
| Whisper (subs) | 🟡 Pending | Via OpenAI key |
| FFmpeg | 🟢 Available on VPS | Verify version |
| GitHub | 🟢 Connected | github.com/flashintegrationai/news-avatar-studio |

## Legend

- 🟢 Working
- 🟡 Configured but not verified end-to-end
- 🔴 Not provisioned / blocking
