# Status transitions (reference)

Contract: [`docs/issues/workflow.md`](../../../../docs/issues/workflow.md). Do not invent statuses or transitions.

## Valid `status:*` labels

`status:pending-review`, `status:pending-refinement`, `status:pending-clarification`, `status:pending-implementation`, `status:pending-verification`, `status:pending-acceptance`, `status:accepted`, `status:superseded`

Exactly one of these on each `type:epic` / `type:task` / `type:defect` issue.

## Allowed transitions

| From | To | Typical evidence |
|------|-----|------------------|
| pending-review | pending-implementation | Pass review comment (latest) |
| pending-review | pending-refinement | Fail review comment |
| pending-review | pending-clarification | Clarification questions comment |
| pending-refinement | pending-review | Refined body + summary comment |
| pending-clarification | pending-review | PO clarification comment |
| pending-clarification | pending-refinement | PO comment saying refine needed |
| pending-implementation | pending-verification | Implementation deliverables comment |
| pending-verification | pending-acceptance | Pass verification comment |
| pending-verification | pending-implementation | Fail verification comment |
| pending-acceptance | accepted | Accept comment with test evidence |
| pending-acceptance | pending-implementation | Fail accept (+ defect link) |
| pending-acceptance | pending-clarification | Needs PO clarification |
| pending-review, pending-refinement, pending-clarification, pending-implementation, pending-verification, pending-acceptance | superseded | Supersession comment naming the successor |

`accepted` and `superseded` are terminal: no transition leaves either. Closure is planner-only for both ([terminal-states.md](../../../../docs/issues/terminal-states.md)); this gate never closes an issue.

## Label swap (`gh`)

1. Read current labels: `gh issue view <n> --json labels --jq '.labels[].name'`
2. Collect every existing `status:*` label.
3. Remove them: `gh issue edit <n> --remove-label "status:…" …` (all current status labels).
4. Add target: `gh issue edit <n> --add-label "status:<target>"`.

Never close the issue when applying `status:accepted` or `status:superseded` (closure is planner-only).

Label swaps change labels only; body and comment writes follow [`docs/issues/body-writes.md`](../../../../docs/issues/body-writes.md).

## Gate mode inputs

Action skills pass: issue number, expected `from` status (short name without `status:` prefix or full label), desired `to` status. Abort if current status ≠ `from` (after normalizing). Apply swap only when the transition is in the table above.

## Fail-review cascade

When `review-project-issue` names related issues as impacted, each named issue may be moved to `status:pending-refinement` regardless of its current status (swap all `status:*` → `pending-refinement`). Do not use this exception for any other action.
