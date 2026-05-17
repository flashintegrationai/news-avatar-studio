# Rule 09 — Session Continuity Protocol

## Purpose
Prevent Claude and agents from re-investigating resolved issues, re-reporting fixed bugs, or starting sessions from scratch.

---

## Session Open — MANDATORY
1. Read `memory/session-state.md` — current work block, next steps, blockers
2. Read `memory/resolved-issues.md` — do NOT re-investigate without new evidence
3. Read `memory/closed-decisions.md` — do NOT relitigate
4. If user request touches an area covered by an agent, read that agent's memory too

Use the `resuming-session` skill.

---

## Session Close — MANDATORY after productive work

### `memory/session-state.md`
- Update `Last updated` date
- Update `Current Work Block`
- Update `Next Steps` with precise, actionable items (file paths, function names)
- Update `Active Blockers`

### `memory/resolved-issues.md`
- Add any bug fixed this session
- Include: what was wrong, what fixed it, commit/file, evidence to reopen

### `memory/closed-decisions.md`
- Add any architectural/business decision finalized

### `memory/tech-state.md`
- Update integration status if any changed

---

## What NEVER Goes in Memory
- Code patterns — read the code
- Git history — use `git log`
- Who-changed-what — use `git blame`
- In-progress task state for THIS session — use TaskCreate
- Anything in `CLAUDE.md` or rule files

---

## Agent Responsibility
All agents check `resolved-issues.md` before investigation and `closed-decisions.md` before proposing changes. Agents do not update memory directly — they surface findings to Claude.

---

## Core Rule
**A new session that starts without reading memory is a broken session.**
**A session that ends without updating memory is a broken session.**
