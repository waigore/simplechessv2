---
name: implement-project-issue
description: |-
  After implementing an epic/task/defect in status:pending-implementation, post a
  deliverables summary (PRs/commits) and move to pending-verification.
  Use when implementation work for an issue is done and ready for verification.

  Examples:
    - user: "Mark #12 implemented; PR #40" → summary comment + gate status
    - user: "Implementation done for the HUD task" → same for that issue
---

# Implement project issue

Record implementation evidence for a typed issue in `status:pending-implementation`.

**Contract:** [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)

**Evidence writes:** [`docs/issues/body-writes.md`](../../../docs/issues/body-writes.md) — `--body-file`, guard, read-back.

**Status gate:** [`enforce-task-workflow-status`](../enforce-task-workflow-status/SKILL.md)

## Steps

1. **Load** issue `n` (requirements, deliverables, acceptance criteria).
2. **Assert** `status:pending-implementation`.
3. **Confirm** deliverables exist (PRs, commits, paths). Ask if missing.
4. **Comment** summarizing what was created or modified against the issue requirements; include PR/commit links.
5. **Gate** via `enforce-task-workflow-status`: `pending-implementation` → `pending-verification`.
6. **Report** URL, evidence comment, new status. Remind that verification must be a **separate** session (`verify-project-issue`).

## Rules

- This skill records evidence and status; it does not replace doing the implementation work.
- Do not run `verify-project-issue` or `accept-project-issue` in the same session after posting the implementation summary.
- Call `enforce-task-workflow-status` for the label change.
