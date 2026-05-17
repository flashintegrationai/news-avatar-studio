---
name: approval-flow
description: Handles human approval transitions for scripts and videos. Logs approver, timestamp, and decision to news_approvals. Triggers the next pipeline stage on approve, halts on reject.
---

# Approval Flow

## Two approval gates
1. **Script approval** — `news_scripts.status: draft → approved | rejected | needs_edit`
2. **Video approval** — `news_videos.status: pending_approval → approved | rejected | needs_edit`

## On `approve`
- UPDATE table row status='approved', approved_by, approved_at
- INSERT `news_approvals` { entity_type, entity_id, decision='approve', user_id, timestamp }
- Trigger next stage webhook:
  - Script approved → `NEWS - Render Hedra`
  - Video approved → set `publish_confirmed_at` (still requires explicit publish click)

## On `reject`
- UPDATE status='rejected', rejection_reason
- INSERT `news_approvals` { decision='reject', reason }
- Halt pipeline for this item
- Surface to dashboard with reason

## On `needs_edit`
- UPDATE status='needs_edit', edit_notes
- Notify writer/editor agent with notes
- Re-enter approval queue after edit
