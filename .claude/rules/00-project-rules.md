# Rule 00 — General Project Rules

## Always Do First
1. Read `CLAUDE.md`
2. Run the `resuming-session` skill
3. Read the relevant rule files for your task domain

## Agent Usage
- Use the specialized agents in `.claude/agents/` for domain-specific tasks
- Each agent declares `runtime: mixed` — can be executed by Claude or Codex
- Respect each agent's permissions block

## Skill Usage
- Before creating a new pattern, check if a skill exists in `.claude/skills/`
- Skills ensure consistency

## Implementation Style
- Prefer safe, incremental implementation
- After each major step, summarize what changed and what's next
- Never make assumptions about editorial/business logic — ask if unclear

## Code Quality
- All Supabase queries respect RLS
- All Telegram callbacks validate sender + secret token
- Code comments explain *why*, not *what*

## Shared Infrastructure
- This project shares Supabase + n8n with nexus-crm
- All tables: `news_*` prefix
- All n8n workflows: `NEWS - *` prefix
- All n8n credentials: `news-*` prefix
- Never touch `nexus`/`leads`/`quotes` artifacts
