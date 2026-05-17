---
name: security-review
description: Reviews changes for security risks. Scans for committed secrets, exposed service-role keys, missing RLS, unsigned webhooks, and unsafe input handling. Required before any merge to main.
---

# Security Review

## Pre-merge checklist
1. **No secrets in committed files** — grep for `sk-`, `eyJ`, `ghp_`, `AKIA`, common API key prefixes
2. **No SERVICE_ROLE_KEY in client code** — grep `apps/web/components/` and `apps/web/app/` for `SERVICE_ROLE`
3. **No NEXT_PUBLIC_ prefix on sensitive vars**
4. **RLS enabled on all new `news_*` tables**
5. **Webhook endpoints validate `X-Webhook-Secret` header**
6. **Zod validation on all form inputs and API request bodies**
7. **YouTube OAuth refresh token stored encrypted (Supabase Vault or env only)**
8. **No `dangerouslySetInnerHTML` without sanitization**
9. **No `eval()` or `Function()` with user input**

## Output
- Pass / Fail
- If fail: list each finding with file:line + remediation
- Update `memory/resolved-issues.md` if a security bug was found and fixed
