---
name: generate-voice
description: Synthesizes voice audio from approved script via ElevenLabs API. Uploads MP3 to Supabase Storage and returns signed URL for downstream avatar render.
---

# Generate Voice

## Inputs
- `script_id`
- `voice_id` (from env or per-channel config)

## Steps
1. Read script content
2. POST `https://api.elevenlabs.io/v1/text-to-speech/{voice_id}`
   ```json
   {
     "text": "{{script}}",
     "model_id": "eleven_multilingual_v2",
     "voice_settings": { "stability": 0.5, "similarity_boost": 0.75 }
   }
   ```
3. Receive MP3 stream
4. Upload to Supabase Storage `news-renders/audio/{script_id}.mp3`
5. Generate 24h signed URL
6. Return signed URL + duration_seconds (from MP3 metadata)

## Error handling
- 429 (rate limit) → retry with exponential backoff (max 3)
- 401 → fail loud, key issue
- 5xx → retry 2x then fail
