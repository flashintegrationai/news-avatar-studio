---
name: ingest-news-sources
description: Adds or configures a news source (RSS feed or NewsAPI query). Validates the feed, deduplicates against existing sources, and inserts into news_sources with appropriate scheduling.
---

# Ingest News Sources

## When to use
User wants to add a new RSS feed or NewsAPI query to the ingestion pipeline.

## Inputs
- Source type: `rss` | `newsapi`
- URL (for RSS) or query params (for NewsAPI)
- Category/topic tag
- Polling interval (default 3h)

## Steps
1. Validate URL/query (fetch sample, check it returns valid items)
2. Check `news_sources` for duplicate by URL hash
3. INSERT into `news_sources` { type, url, query_params, category, poll_interval, is_active, created_at }
4. If polling interval differs from cron, alert user to update `NEWS - Ingest Sources` workflow cron
5. Test by triggering one immediate ingest
