# SOP — Invoke Codex Agent from Claude Code

**Doc ID:** SOP-NEWS-001
**Version:** 1.0
**Owner:** project-architect
**Last updated:** 2026-05-17
**Related skill:** `.claude/skills/invoke-codex-agent/SKILL.md`

---

## 1. Purpose

Define the standard procedure for delegating implementation work from Claude Code (the orchestrator) to Codex CLI (the implementer) inside this project, ensuring consistent, auditable, and safe handoffs.

## 2. Scope

Applies to all work performed inside `C:\Users\alber\Documents\news-avatar-studio`. Excludes one-off conversational tasks and any task that touches credentials, the shared VPS, production publishing, or destructive operations — those remain Claude-only.

## 3. Roles & responsibilities

| Role | Responsibility |
|---|---|
| Claude Code | Orchestrator. Decides whether to delegate, writes the spec, validates results, performs MCP-integrated steps. |
| Codex CLI | Implementer. Reads spec, writes files in the project tree, returns. Does not perform MCP or VPS operations. |
| User | Authorizes risky steps. Must run `codex login` once before first delegation. |

## 4. Preconditions

Before invoking Codex:
1. `codex --version` succeeds.
2. `~/.codex/auth.json` exists (run `codex login` if not).
3. Project directory is trusted in `~/.codex/config.toml`, or pass `-c projects.'<path>'.trust_level=trusted`.
4. Claude has already:
   - Read `memory/session-state.md`, `memory/resolved-issues.md`, `memory/closed-decisions.md`
   - Read all relevant rule files in `.claude/rules/`
   - Identified the agent file in `.claude/agents/` that matches the task domain

## 5. Procedure

### Step 1 — Decide
Apply the decision checklist from the skill `invoke-codex-agent/SKILL.md` § "When to use" / "When NOT to use". If ANY check fails, Claude executes the task directly.

### Step 2 — Write the spec
Spec MUST contain (in this order):
1. Goal (one sentence)
2. Inputs (exact file paths, env vars Codex may read, credentials Codex must NOT touch)
3. Output (exact file path(s) to write)
4. Acceptance criteria (testable)
5. Out of scope
6. Stop condition

### Step 3 — Invoke
Use the Bash tool to call Codex. Choose mode:

| Mode | Command | When |
|---|---|---|
| Inline | `codex exec "<prompt>"` | Spec ≤ ~2KB |
| Heredoc | `codex exec "$(cat <<'EOF' ... EOF)"` | Multi-line spec |
| Piped | `cat spec.md \| codex exec -` | Spec is a file |
| Background | Bash with `run_in_background=true` | Long task (>2 min) |

For Windows shell, use PowerShell heredoc (`@'...'@`) — see CLAUDE.md.

### Step 4 — Validate
Claude MUST run, after Codex returns:
1. `git status` — confirm only expected files changed.
2. Open each new/changed file and read it.
3. Run the task-specific validation:
   - n8n workflow JSON → POST to `/api/v1/workflows` with `?dryRun=true`-style checks or open in n8n UI
   - SQL migration → `supabase migration repair` / dry run
   - JS/TS → `node -c <file>` syntactic, then `npm run lint` if configured
4. Run any rule from `.claude/rules/` that applies (security scan, secret check).

### Step 5 — Integration step (Claude only)
Whatever requires MCP or credentials Claude executes directly:
- Push workflow to n8n via REST API (`POST /api/v1/workflows`)
- Apply Supabase migration via MCP tool with user confirmation
- Activate workflow via REST
- Commit (only on explicit user request)

### Step 6 — Memory update
Append to `memory/session-state.md`:
- What was delegated
- Codex commit / file list
- Validation results
- Next step

## 6. Spec template (copy-paste)

```
GOAL: <one sentence>

INPUTS:
- Read: <list of files Codex must read>
- Reference patterns in: <existing files to mirror>
- Env vars Codex may read: <list> (NEVER: secrets, .env.local)

OUTPUT:
- Write exactly: <file path>
- Mode: create | edit (specify existing-string anchors if edit)

ACCEPTANCE:
- [ ] <testable check>
- [ ] <testable check>

OUT OF SCOPE:
- <thing Codex must NOT do>

STOP WHEN:
- <observable condition>

DO NOT TOUCH:
- .env.local
- supabase/migrations/<applied>
- any file under /etc/ on a VPS (Codex must never SSH)
```

## 7. Quality gates (must all pass before marking task done)

1. ✅ All files Codex wrote exist where specified.
2. ✅ No file outside the OUTPUT list was modified.
3. ✅ No secrets in any committed file (`grep -nE 'sk_|sbp_|eyJhbGc' <changed files>` returns nothing).
4. ✅ All acceptance criteria checked by Claude.
5. ✅ `memory/session-state.md` updated.

## 8. Failure handling

| Symptom | Action |
|---|---|
| Codex writes unexpected files | Revert with `git restore`, refine prompt, re-invoke once |
| Codex output lacks acceptance criteria | Fix inline with Claude — do not re-invoke unless gap is large |
| Two re-invocations fail | Stop. Claude executes directly. Note in `memory/resolved-issues.md` why Codex failed for this category of task. |
| Codex CLI errors (auth, sandbox) | Surface to user; do not retry blindly |

## 9. Forbidden actions for Codex

- Writing `.env.local`, `.env`, or any file containing secrets
- Calling `supabase db push`, `git push`, `git reset --hard`
- SSH into the VPS
- Modifying `.claude/settings.json`, `.gitignore`, or hooks
- Publishing to YouTube
- Sending Telegram messages (those go through n8n workflows under Claude's control)

## 10. Audit

Every delegation must be reflected in:
- `memory/session-state.md` (what happened)
- Git commit message (if delegated work is committed) — prefix subject with `[codex]`

## 11. Revision history

| Version | Date | Change | Author |
|---|---|---|---|
| 1.0 | 2026-05-17 | Initial version | Claude (orchestrator) |
