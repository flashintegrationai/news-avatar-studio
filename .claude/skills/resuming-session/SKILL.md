---
name: resuming-session
description: Reads project memory files at session start to restore context. Run at the beginning of every session before any non-trivial task. Loads session-state, resolved-issues, closed-decisions, tech-state, and patterns-observed.
---

# Resuming Session

## When to use
At the start of every Claude Code session, before responding to any non-trivial user request.

## Steps
1. Read `MEMORY.md` (already auto-loaded; confirm it's present)
2. Read `memory/session-state.md` → understand current work block + next steps + blockers
3. Read `memory/resolved-issues.md` → do NOT re-investigate items listed
4. Read `memory/closed-decisions.md` → do NOT relitigate items listed
5. Read `memory/tech-state.md` → know which integrations are up/down
6. If the user's request touches a domain covered by an agent, read that agent's `.claude/agent-memory/<agent>/MEMORY.md`

## Output
- One-sentence summary to the user: "Resumed: [current work block]. Next: [next step]."
- Flag any blocker that affects the user's current request
