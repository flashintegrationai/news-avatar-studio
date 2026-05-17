---
name: invoke-codex-agent
description: Delegate a unit of work to Codex CLI from inside Claude Code. Use when Claude needs a long-running implementation, parallel work, or wants Codex to author a workflow/migration/script while Claude keeps orchestrating. Codex runs as a subprocess via Bash — there is no native delegation; this skill documents the contract.
---

# Invoke Codex Agent

## When to use
Trigger this skill when **all** are true:
- The task is implementation-heavy (writing files, generating code, refactoring) — not conversation.
- Claude can specify the goal + acceptance criteria in <300 words.
- The task does NOT require live MCP integration that only Claude has (e.g. Supabase MCP, project-specific Claude tools). Codex has its own MCP config.
- Either: (a) the task is big enough that Claude would burn through context, OR (b) the user explicitly asked to use Codex, OR (c) running it in parallel saves wall time.

## When NOT to use
- Quick edits, single-file changes Claude can do directly.
- Tasks that need real-time verification with MCP tools Claude has (Supabase, GitHub MCP).
- Anything that touches credentials, the VPS, or production data — Claude must drive these.
- Conversational/exploratory work.

## Roles (per `.claude/agents/*.md` frontmatter)
Each agent declares `primary: claude, fallback: codex`. **Primary** is the default driver; **fallback** is whom to delegate to when offloading. Concretely:
- Claude (primary): architecture, review, MCP-integrated work, code with cross-file reasoning.
- Codex (fallback): bulk file generation, scaffolding, schema/workflow JSON authoring, repetitive edits.

## How to invoke

### One-shot (non-interactive)
```bash
codex exec "$(cat <<'EOF'
<your prompt with goal + acceptance criteria + relevant file paths>
EOF
)"
```

### Piped input (when handing over a spec/diff)
```bash
cat docs/sops/build-workflow.md | codex exec -
```

### Configuration overrides
```bash
codex exec -c model_reasoning_effort=high "..."
codex exec -c projects.'c:\users\alber\documents\news-avatar-studio'.trust_level=trusted "..."
```

## Prompt template
Always include:
1. **Goal** (one sentence)
2. **Inputs** (file paths to read, env vars available, credentials NOT to touch)
3. **Output** (exact file path(s) Codex must write)
4. **Acceptance** (testable criteria — e.g. "JSON validates against schema X", "passes `node -e require()`", "follows pattern in `n8n/workflows/news-ingest-sources.json`")
5. **Out of scope** (what Codex must NOT do)
6. **Stop condition** (when to return control)

## After Codex returns
Claude MUST:
1. Read the files Codex wrote.
2. Run validation (lint, schema check, n8n API validation if applicable).
3. If failed: either fix inline OR re-invoke Codex with the failure as new context. Do not loop more than 2 times.
4. Run the integration step that only Claude can (deploy via Supabase MCP, push workflow via n8n REST API, etc).
5. Update `memory/session-state.md` with what Codex produced.

## Failure modes & mitigations
| Failure | Mitigation |
|---|---|
| Codex CLI not logged in | Run `codex login` (USER action, not Claude) |
| Project dir not trusted | `codex exec -c projects.'<path>'.trust_level=trusted ...` |
| Output exceeds Bash timeout | Use `run_in_background=true` in Bash tool; read output file on completion |
| Codex hallucinates file paths | Always pre-list paths in the prompt — never let Codex discover paths from scratch |
| Codex MCP gaps | Hand Codex the data Claude pulled via MCP, in the prompt body — do not expect Codex to query MCP itself |

## Forbidden
- Never let Codex write `.env.local` or any file containing secrets.
- Never let Codex make destructive git or VPS operations.
- Never delegate publish steps (YouTube upload, Supabase migrations on prod) — those are Claude's by Rule 06 + Rule 03.

## Reference
- Codex CLI: https://github.com/openai/codex
- Project SOP: `docs/sops/invoke-codex.md`
- Agent definitions: `.claude/agents/*.md`
