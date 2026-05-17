# Rule 08 — UI Rules

## Component Library: shadcn/ui
Primary building block. Do not import other component libraries without approval.

## Styling: Tailwind Only
- No custom CSS unless necessary
- No inline `style={{}}` except dynamic values
- Use `cn()` helper for conditional classes

## Visual Style: Editorial Command Center
- Professional, clean
- Dark mode friendly
- Information-dense (operator sees queue + history + status at once)
- Brand color: configurable per channel

## Mobile Responsive
- Primary use: desktop
- Secondary: tablet (for on-the-go approvals)
- Tailwind responsive prefixes mandatory

## Quick Action Priority
The dashboard must make these fast:
1. **Approve script** — single click from queue card
2. **Reject + reason** — quick modal
3. **Preview video** — inline player on card
4. **Publish Now** — explicit button (NOT auto)
5. **Reschedule** — date/time picker

## Data Loading
Always handle:
- Loading: skeleton
- Empty: helpful message + CTA
- Error: user-friendly + retry

## Forms
- React Hook Form + Zod
- Inline validation errors
- Disabled submit while submitting
- Success feedback
- Auto-focus first input on modal open

## Typography
- System font or Inter
- Page titles: `text-2xl font-bold`
- Section headers: `text-lg font-semibold`
- Card titles: `text-base font-medium`
- Metadata: `text-sm text-muted-foreground`

## Icons
- `lucide-react` only
