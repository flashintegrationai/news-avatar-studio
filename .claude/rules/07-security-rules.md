# Rule 07 — Security Rules

## Golden Rule: No Secrets In Committed Files
Before commit, verify no:
- API keys (Hedra, ElevenLabs, OpenAI, Anthropic, YouTube, Supabase service role)
- OAuth tokens
- Webhook secrets
- DB passwords / connection strings with credentials

Run `.claude/hooks/security-scan.sh` before commit.

## .env.local Never in Git
- Stays in `.gitignore` at all times
- If accidentally staged: `git rm --cached apps/web/.env.local` immediately + rotate keys

## SUPABASE_SERVICE_ROLE_KEY Is Sacred
Rules:
1. Only in Edge Functions or server-side Route Handlers
2. Never as a prop
3. Never logged
4. Never in a response body
5. Rotate immediately on suspected compromise

## YouTube OAuth Refresh Token
- Most sensitive credential (long-lived, allows uploads)
- Store in Supabase Vault if available, else env var only
- Never log, never expose in response body
- Rotate every 90 days

## Validate All Incoming Webhooks
| Source | Validation |
|---|---|
| n8n callbacks | `X-Webhook-Secret` header |
| Hedra status callbacks (if used) | Signature header per Hedra docs |
| YouTube notifications (PubSubHubbub) | Signature verification |

Return 401 on validation failure. Log to `news_audit_logs`.

## Input Sanitization
- Zod on all form submissions and API inputs
- Never `eval()` or `Function()` with user input
- Never `dangerouslySetInnerHTML` without sanitization
- Parameterized queries only (Supabase client handles)

## Audit Logging
Log to `news_audit_logs`:
- Every create/update/delete on `news_*` tables
- Every approval/rejection
- Every YouTube publish
- Every webhook validation failure

## Credential Rotation Policy
On suspected compromise:
1. Rotate in service dashboard
2. Update production env
3. Update `.env.local` locally
4. Audit `news_audit_logs` for unauthorized access
5. Notify owner
