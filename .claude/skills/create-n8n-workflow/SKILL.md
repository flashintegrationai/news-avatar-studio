---
name: create-n8n-workflow
description: Creates a new n8n workflow following project conventions. Uses MCP n8n tools (get_sdk_reference, search_nodes, get_node_types, validate_workflow) and enforces the NEWS - prefix and news- credential naming.
---

# Create n8n Workflow

## Naming
- Workflow name: `NEWS - {{Action}}` (e.g., `NEWS - Ingest Sources`)
- Credentials: `news-{{service}}` (e.g., `news-supabase`, `news-elevenlabs`)
- Folder: `NEWS`

## Steps
1. `get_sdk_reference` with sections you need (`guidelines`, `design`)
2. `search_nodes` for each service touched
3. `get_node_types` with ALL node IDs (including discriminators)
4. Write workflow code following SDK patterns
5. `validate_workflow` — fix all errors before proceeding
6. `prepare_test_pin_data` for trigger nodes
7. `test_workflow` end-to-end
8. `create_workflow_from_code` (DO NOT publish yet)
9. Export JSON to `n8n/workflows/{kebab-name}.json`
10. Document in `n8n/docs/workflows-overview.md`

## Forbidden
- Hardcoding URLs, keys, or secrets in workflow JSON
- Using `nexus-*` credentials
- Publishing without `validate_workflow` passing
- Publishing without user approval
