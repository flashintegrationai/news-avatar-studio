---
name: edit-final-video
description: Assembles the publish-ready video using FFmpeg. Concatenates intro + avatar render + outro, burns Whisper-generated subtitles, normalizes audio, and exports MP4 at YouTube-optimized settings.
---

# Edit Final Video

## Inputs
- `render_id`
- intro/outro paths (env)

## Steps
1. Download avatar render from Supabase Storage
2. Generate subtitles:
   - POST OpenAI Whisper `/v1/audio/transcriptions` with `response_format=srt`
   - Save SRT alongside video
3. FFmpeg concat with subtitles:
   ```bash
   ffmpeg -i intro.mp4 -i avatar.mp4 -i outro.mp4 \
     -filter_complex "[0:v][0:a][1:v][1:a][2:v][2:a]concat=n=3:v=1:a=1[v][a]" \
     -map "[v]" -map "[a]" \
     -vf "subtitles=avatar.srt:force_style='Fontsize=24,PrimaryColour=&H00FFFFFF&,OutlineColour=&H00000000&,Outline=2'" \
     -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
     -c:v libx264 -preset medium -crf 22 -pix_fmt yuv420p \
     -c:a aac -b:a 192k -ar 48000 \
     -movflags +faststart \
     final.mp4
   ```
4. Upload to `news-final-videos/{video_id}.mp4`
5. INSERT `news_videos` { render_id, final_url, subtitle_url, duration_seconds, status='pending_approval' }

## Quality gates
- Duration within ±15s of script estimate
- Final size < 2 GB (YouTube limit per upload)
- Audio peak < -1 dB
