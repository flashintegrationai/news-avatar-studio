# NEWS AVATAR STUDIO — Master Instructions for Claude Code

## Project Identity

- **Project Name**: News Avatar Studio
- **Purpose**: Fully automated YouTube news channel powered by AI avatar
- **Control surface**: **Telegram bot** (no web dashboard)
- **Niche**: General news
- **Frequency**: 2-3 videos per week (~2 min each)
- **Trigger model**: Full auto from RSS feeds → human approval via Telegram at script + final video
- **Owner**: flashintegrationai

---

## Critical Rules

1. **Always read `.claude/rules/` before acting.** Start with `00-project-rules.md`, then read domain-specific rules.
2. **Use the resuming-session skill at session open.** Read `memory/session-state.md`, `memory/resolved-issues.md`, `memory/closed-decisions.md` before any non-trivial task.
3. **Use mixed agents (Claude + Codex).** Each agent declares `runtime` + `primary` + `fallback` in its frontmatter.
4. **Never publish to YouTube without explicit user approval.** Publication is the only irreversible step. Confirmation comes from a Telegram button tap, logged in `news_approvals`.
5. **Never modify the shared VPS.** Supabase and n8n run on the same Hostinger VPS as nexus-crm. Never SSH, restart containers, or modify configs without explicit permission.
6. **Never commit `.env.local`** — it contains real API keys (Hedra, ElevenLabs, YouTube OAuth, OpenAI, Telegram bot token).
7. **Never expose Telegram bot token or service-role keys in any committed file.** Server-side / n8n credentials only.
8. **Respect namespace isolation with nexus.** All Supabase tables prefixed `news_*`. All n8n workflows prefixed `NEWS - *`. All credentials prefixed `news-*`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Control surface | Telegram Bot (inline keyboards for approvals) |
| Database | Supabase (shared VPS, schema-isolated) |
| Auth | None client-facing (Telegram chat_id whitelist) |
| Automation | n8n (shared VPS, folder-isolated) |
| Script generation | OpenAI GPT-4o or Anthropic Claude |
| Voice synthesis | ElevenLabs API |
| Avatar/video | Hedra API (Character-3) |
| Subtitles | OpenAI Whisper |
| Thumbnails | DALL-E 3 |
| Editing | FFmpeg (on VPS) |
| Publishing | YouTube Data API v3 |
| Analytics | YouTube Analytics API |
| Hosting (app) | None — Telegram is the UI |
| Hosting (backend) | Hostinger VPS (shared with nexus) |

---

## Shared Infrastructure with Nexus

This project **shares** the Supabase instance and n8n instance with `nexus-crm` on the Hostinger VPS. Isolation is enforced by naming convention:

| Resource | Nexus | News Avatar |
|---|---|---|
| Supabase tables | `leads`, `quotes`, `jobs`, … | `news_items`, `news_scripts`, `news_videos`, … |
| n8n folder | `NEXUS - *` | `NEWS - *` |
| n8n credentials | `nexus-*` | `news-*` |
| Storage buckets | `estimate-images`, `job-photos` | `news-renders`, `news-final-videos`, `news-thumbnails` |

See `docs/shared-infrastructure.md` for full coexistence rules.

---

## Agents (Mixed Architecture)

A single set of agents — each runtime-flexible (Claude leads, Codex fallback).

| Agent | File |
|---|---|
| Project Architect | `.claude/agents/project-architect.md` |
| Content Curator | `.claude/agents/content-curator.md` |
| Script Writer | `.claude/agents/script-writer.md` |
| Avatar Producer | `.claude/agents/avatar-producer.md` |
| Video Editor | `.claude/agents/video-editor.md` |
| YouTube Publisher | `.claude/agents/youtube-publisher.md` |
| Telegram Bot Manager | `.claude/agents/telegram-bot-manager.md` |
| n8n Automation Engineer | `.claude/agents/n8n-automation-engineer.md` |
| Supabase Engineer | `.claude/agents/supabase-engineer.md` |
| QA Reviewer | `.claude/agents/qa-reviewer.md` |

Permissions are declared in `.claude/settings.json` and per-agent frontmatter.

---

## Skills

| Skill | File | Purpose |
|---|---|---|
| Resuming Session | `.claude/skills/resuming-session/SKILL.md` | Read memory at session open |
| Ingest News Sources | `.claude/skills/ingest-news-sources/SKILL.md` | Add/configure RSS or NewsAPI source |
| Curate Top Stories | `.claude/skills/curate-top-stories/SKILL.md` | Score and select daily top stories |
| Create News Script | `.claude/skills/create-news-script/SKILL.md` | LLM script generation |
| Render Avatar Video | `.claude/skills/render-avatar-video/SKILL.md` | Hedra API render + polling |
| Generate Voice | `.claude/skills/generate-voice/SKILL.md` | ElevenLabs synthesis |
| Edit Final Video | `.claude/skills/edit-final-video/SKILL.md` | FFmpeg pipeline (intro/outro/subs) |
| Publish To YouTube | `.claude/skills/publish-to-youtube/SKILL.md` | Upload + SEO + thumbnail |
| Telegram Bot | `.claude/skills/telegram-bot/SKILL.md` | Send messages with inline keyboards |
| Telegram Approvals | `.claude/skills/telegram-approvals/SKILL.md` | Handle button callbacks → Supabase updates |
| Create n8n Workflow | `.claude/skills/create-n8n-workflow/SKILL.md` | Reusable |
| Create Supabase Migration | `.claude/skills/create-supabase-migration/SKILL.md` | Reusable |
| Verifying Deploy | `.claude/skills/verifying-deploy/SKILL.md` | Reusable |
| Security Review | `.claude/skills/security-review/SKILL.md` | Reusable |

---

## Memory Architecture

- `MEMORY.md` (repo root) — auto-loaded index (first 200 lines)
- `memory/` — project memory (session-state, resolved-issues, closed-decisions, tech-state, patterns-observed)
- `.claude/agent-memory/<agent>/MEMORY.md` — isolated per-agent namespace (10 agents)

**Always** run the `resuming-session` skill at session open.

---

## Rule Files

| Rule File | Topic |
|---|---|
| `.claude/rules/00-project-rules.md` | General project behavior |
| `.claude/rules/01-content-rules.md` | Editorial tone, fact-checking, no clickbait |
| `.claude/rules/02-local-dev-rules.md` | Local development constraints |
| `.claude/rules/03-remote-vps-rules.md` | Shared VPS access rules |
| `.claude/rules/04-supabase-rules.md` | Supabase + namespace isolation |
| `.claude/rules/05-n8n-rules.md` | n8n + folder isolation |
| `.claude/rules/06-youtube-rules.md` | YouTube API quotas, copyright, branding |
| `.claude/rules/07-security-rules.md` | Secrets, API keys, OAuth tokens |
| `.claude/rules/08-telegram-rules.md` | Bot UX, chat_id whitelist, callback validation |
| `.claude/rules/09-session-protocol.md` | Memory protocol |

---

## Pipeline Summary

```
[RSS feeds] → [Curator LLM] → [Script LLM] → 📲 TELEGRAM: Approve script?
            → [ElevenLabs voice] → [Hedra avatar render]
            → [FFmpeg edit] → 📲 TELEGRAM: Approve video? Publish?
            → [YouTube upload + DALL-E thumbnail]
            → 📲 TELEGRAM: ✅ Published! URL
            → [Analytics tracking → daily Telegram summary]
```

Full flow: `docs/flow-map.md`

---

## Key Files

- `docs/architecture.md` — System diagram and component map
- `docs/flow-map.md` — Step-by-step pipeline with Telegram approval points
- `docs/shared-infrastructure.md` — Coexistence rules with nexus
- `docs/database-schema.md` — All `news_*` tables documented
- `.env.example` — Template for `.env.local` (includes Telegram vars)
