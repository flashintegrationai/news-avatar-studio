# Closed Decisions

Architectural and business decisions finalized. Do NOT relitigate without new evidence.

Format per entry:
- **Decision** — what was decided
- **Date** — when
- **Why** — rationale
- **Reopen if** — what would justify revisiting

---

## 2026-05-17 — Mixed Claude+Codex agent architecture
- **Decision:** Single set of agents, each with `runtime: mixed` and `primary` + `fallback` fields
- **Why:** Avoid duplication of agent definitions; simpler maintenance; both runtimes can execute the same role
- **Reopen if:** Codex and Claude diverge so much that shared definitions become harmful

## 2026-05-17 — Shared infrastructure with nexus-crm
- **Decision:** Reuse the same Hostinger VPS Supabase + n8n instances. Isolate by `news_*` table prefix and `NEWS - *` workflow folder
- **Why:** Cost savings, single ops surface, mature instances already running
- **Reopen if:** Performance contention between projects, or compliance requires separation

## 2026-05-17 — Hedra + ElevenLabs over HeyGen
- **Decision:** Use Hedra (Character-3) + ElevenLabs voice (~$15/mo) instead of HeyGen
- **Why:** ~6x cheaper than HeyGen Team plan, comparable or better realism in 2026
- **Reopen if:** Hedra API reliability drops or quality regresses below acceptable threshold

## 2026-05-17 — Full-auto trigger from RSS with 2 approval gates
- **Decision:** System ingests, curates, generates script. Human approves script. System renders + edits. Human approves video. System publishes.
- **Why:** Balances automation with editorial control. Avoids irreversible mistakes on YouTube.
- **Reopen if:** Approval bottleneck slows publishing below 2/week target

## 2026-05-17 — Public GitHub repo
- **Decision:** Repo `news-avatar-studio` is public on github.com/flashintegrationai
- **Why:** Owner preference; no proprietary business logic exposed
- **Reopen if:** Secrets leak or proprietary editorial systems are added
