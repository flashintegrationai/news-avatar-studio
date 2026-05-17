# News Avatar Studio — Memory Index

Auto-loaded each session (first 200 lines). Index only — full content lives in `memory/` and `.claude/agent-memory/<agent>/`.

## Project memory (`memory/`)
- [Session State](memory/session-state.md) — current work block, next steps, blockers
- [Resolved Issues](memory/resolved-issues.md) — do NOT re-investigate without new evidence
- [Closed Decisions](memory/closed-decisions.md) — do NOT relitigate
- [Tech State](memory/tech-state.md) — integration status snapshot
- [Patterns Observed](memory/patterns-observed.md) — implicit knowledge from real work

## Per-agent memory (`.claude/agent-memory/<agent>/MEMORY.md`)
Each agent maintains an isolated knowledge store.

- project-architect, content-curator, script-writer, avatar-producer
- video-editor, youtube-publisher, telegram-bot-manager
- n8n-automation-engineer, supabase-engineer, qa-reviewer

## Rules of memory
- **Read** at session open (use `resuming-session` skill)
- **Update** at session close (Rule 09 protocol)
- **Never** store: code patterns (read code), git history (use `git log`), in-progress task state (use TaskCreate)
- **Always** store: resolved bugs + how, closed decisions + why, env-specific quirks, integration gotchas
