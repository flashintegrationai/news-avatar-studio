# Rule 01 — Content Rules

## Editorial Standards
- **Tone:** neutral by default (configurable via `CHANNEL_TONE`)
- **No clickbait** — title must reflect actual content
- **No first-person opinion** unless `CHANNEL_TONE=conversational`
- **Source-grounded only** — every factual claim must trace to the source article
- **No hallucinated quotes** — never invent statements attributed to real people

## Length
- Target: ~2 minutes per video (280-320 words)
- Max: 3 minutes (450 words)
- Min: 90 seconds (220 words)

## Structure (mandatory)
1. Hook (5-10s)
2. Context (20-30s)
3. Key facts (50-70s, 3-5 points)
4. Analysis (20-30s, neutral)
5. Outro (5-10s)

## Forbidden Topics
- Defamatory content about identifiable individuals
- Unverified breaking news (require 2+ sources)
- Graphic violence or sexual content
- Medical/financial advice presented as fact
- Election-result claims before official certification

## Attribution
- Always credit source(s) in description
- Read source aloud only when `READ_SOURCES_ALOUD=true`
- Never quote >50 consecutive words from a copyrighted article

## Brand Voice
- Professional, calm, informative
- Avoid sensational language ("BREAKING!", "SHOCKING!", "you won't believe")
- Avoid jargon without explanation
