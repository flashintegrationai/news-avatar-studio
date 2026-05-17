---
name: curate-top-stories
description: Scores pending news items and selects top N for script generation. Uses LLM to evaluate freshness, relevance, uniqueness, and substance. Marks selected items and notifies the script workflow.
---

# Curate Top Stories

## When to use
Triggered by cron (daily) or manual run via dashboard.

## Steps
1. SELECT news_items WHERE status='pending' AND published_at > now() - interval '24 hours'
2. SELECT recent topics from news_publications (last 7 days) to avoid repetition
3. For each pending item, call LLM with scoring prompt
4. Pick top N (default 3)
5. UPDATE selected items: status='selected', curator_score, curator_reason
6. UPDATE non-selected: status='skipped', skip_reason
7. POST webhook to `NEWS - Generate Script` for each selected item
