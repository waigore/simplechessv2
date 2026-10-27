# Issue workflow status

Applies to Epic, Task, and Defect. Source of truth for status labels and transitions; invent no parallel statuses.

## Labels

Exactly **one** `status:*` label per typed issue. Skills swap via `enforce-task-workflow-status`. `accepted` and `superseded` are terminal.

| Label | Meaning |
|-------|---------|
| `status:pending-review` | Awaiting review (default on create) |
| `status:pending-refinement` | Reviewed; refinements needed |
| `status:pending-clarification` | Needs product-owner clarification |
| `status:pending-implementation` | Passed review; ready or in progress |
| `status:pending-verification` | Implemented; awaiting verification |
| `status:pending-acceptance` | Verified; awaiting acceptance testing |
| `status:accepted` | Accepted; leave open until planner closes ([terminal-states.md](terminal-states.md)) |
| `status:superseded` | Superseded; leave open until planner closes; name successor ([terminal-states.md](terminal-states.md)) |
| `status:pending-redefinition` | Comment cap hit; locked ([workflow-comment-cap.md](workflow-comment-cap.md)) |

Catalog and priority: [`docs/labels.md`](../labels.md) (unlabeled = normal; create skips `priority:normal`). Comment cap: [workflow-comment-cap.md](workflow-comment-cap.md). Discovery: [workflow-dispatch.md](workflow-dispatch.md).

## Transitions and evidence

Evidence is freeform prose; intent must be clear. Post as an issue comment (refinement also edits the body), then call `enforce-task-workflow-status`.

Every write follows [body-writes.md](body-writes.md): compose to a file, write through `.github/scripts/gh_issue.py` (guard and read-back built in); a failed read-back is a lost body, not evidence.

| From | Action / evidence | To |
|------|-------------------|-----|
| pending-review | Pass review (latest comment); body consistent; deliverables/AC align with parent or vision; note new requirements | pending-implementation |
| pending-review | Fail review: problems + refinement direction. Cascade only when [workflow-cascade.md](workflow-cascade.md) authorizes it | pending-refinement (self; others only when cascade authorized) |
| pending-review | Gaps that cannot be inferred from project scope: clarification questions | pending-clarification |
| pending-refinement | Refined issue body + summary comment | pending-review |
| pending-clarification | PO clarification comment | pending-review, or pending-refinement if refine still needed |
| pending-implementation | Comment summarizing deliverables (PRs/commits) | pending-verification |
| pending-verification | Independent pass: each deliverable checked; standards followed; tests adequate | pending-acceptance |
| pending-verification | Fail: detail issues | pending-implementation |
| pending-acceptance | Accept: repo-locatable test evidence per AC; related PRs | accepted (leave open; planner may close) |
| pending-acceptance | Fail (game/interface): link created defect | pending-implementation |
| pending-acceptance | Spec/ambiguity blocks testing (no defect) | pending-clarification |
| pending-acceptance | Cannot test without PO input | pending-clarification |
| pending-review … pending-acceptance | Supersession comment naming the successor ([terminal-states.md](terminal-states.md)) | superseded |

Reviews are holistic against the issue and parent/sibling relationships, including after prior refinements.

No row leaves `accepted` or `superseded`: both terminal ([terminal-states.md](terminal-states.md)).

Fail-review cascades: [workflow-cascade.md](workflow-cascade.md).

## Skills

| Skill | Role |
|-------|------|
| `enforce-task-workflow-status` | Gate transitions; audit/repair labels |
| `review-project-issue` | Review pass / fail / clarify |
| `refine-project-issue` | Body refine → pending-review |
| `clarify-project-issue` | Record PO clarification |
| `implement-project-issue` | Implementation summary → pending-verification |
| `verify-project-issue` | Independent verify pass / fail |
| `accept-project-issue` | Accept / fail / clarify |

Create skills apply type + `status:pending-review`; priority unlabeled unless human requested high or critical. Dispatch: [workflow-dispatch.md](workflow-dispatch.md). `redefine-project-issue`: [workflow-comment-cap.md](workflow-comment-cap.md).
