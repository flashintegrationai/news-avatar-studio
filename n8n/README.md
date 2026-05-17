# n8n

Exported workflow JSONs for the `NEWS - *` folder.

## Structure
- `workflows/` — one `.json` per workflow, kebab-cased filenames
- `docs/workflows-overview.md` — description of each workflow

## Convention
- Workflow name: `NEWS - <Action>`
- Credentials prefix: `news-`
- Folder in n8n UI: `NEWS`

Never modify or import `NEXUS - *` workflows from this project.

## Re-import after VPS rebuild
1. Create folder `NEWS` in n8n
2. Create credentials (named `news-*`) in n8n UI
3. Import each JSON in `workflows/` via n8n Import → File
4. Verify webhook URLs match env vars
