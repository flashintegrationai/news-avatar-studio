# Tech State

Integration status snapshot. Update when any service status changes.

**Last updated:** 2026-05-17

## Services

| Service | Status | Notes |
|---|---|---|
| Supabase (shared VPS) | 🟢 Working | 8 `news_*` tables applied 2026-05-17 (project ekcnriprnytzeqznbrmf) |
| n8n (shared VPS) | 🟡 Pending | Folder `NEWS` + credentials `news-*` to be created in n8n UI |
| Telegram Bot | 🟡 User-provisioned | User has token. Needs chat_id discovery + webhook registration |
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
