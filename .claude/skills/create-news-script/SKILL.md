---
name: create-news-script
description: Generates a video script from a selected news item. Produces editorial-tone narration matching target word count (~300 words = 2 min) with the mandatory hook/context/facts/analysis/outro structure.
---

# Create News Script

## Inputs
- `news_item_id` (Supabase UUID)
- channel tone (env)
- target seconds (env, default 120)

## LLM prompt template
```
You are writing a news script for an AI-avatar YouTube channel.
Tone: {{tone}}
Target: {{target_seconds}}s (~{{words}} words)

Article:
Title: {{title}}
Source: {{source}}
Body: {{body}}

Write a script with this exact structure:
1. HOOK (5-10s, attention without clickbait)
2. CONTEXT (20-30s, who/what/where/when)
3. KEY FACTS (50-70s, 3-5 substantive points)
4. ANALYSIS (20-30s, neutral implication)
5. OUTRO (5-10s, subscribe CTA)

Return only the script text, no markdown headers, no stage directions.
```

## Output
- INSERT `news_scripts` { news_item_id, content, word_count, estimated_seconds, llm_provider, llm_model, status='draft' }
- Trigger dashboard notification
