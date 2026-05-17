# Rule 05 — n8n Rules

## Folder Isolation (CRITICAL)
- All workflows in folder `NEWS`
- All workflow names prefixed `NEWS - `
- All credentials prefixed `news-`
- Never touch `NEXUS - *` workflows or `nexus-*` credentials

## Trigger via Webhook POST Only
- CRM never runs n8n locally
- Never call n8n internal APIs without the API key pattern

## Webhook URL Pattern
```ts
// Correct
const url = `${process.env.N8N_WEBHOOK_BASE_URL}/news/ingest`

// Wrong — never hardcode
const url = 'https://n8n.example.com/webhook/news/ingest'
```

## Always Authenticate
```ts
await fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Webhook-Secret': process.env.N8N_WEBHOOK_SECRET!
  },
  body: JSON.stringify(payload)
})
```

## Validate Incoming Callbacks
```ts
if (req.headers.get('X-Webhook-Secret') !== process.env.N8N_WEBHOOK_SECRET) {
  return new Response('Unauthorized', { status: 401 })
}
```

## Workflow JSON Files
- Always export to `n8n/workflows/{kebab-name}.json` after publish
- Document in `n8n/docs/workflows-overview.md`

## MCP Workflow
1. `validate_workflow` before create/update
2. `test_workflow` with pinned test data
3. `create_workflow_from_code` (staged)
4. User confirms → `publish_workflow`

## Forbidden
- Hardcoded URLs/secrets in workflow JSON
- Publishing without `validate_workflow` passing
- Publishing without user approval
