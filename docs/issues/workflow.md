# Issue workflow status

Epic, Task, and Defect statuses live here. Feedback: [feedback.md](feedback.md). Do not invent parallel statuses.

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
| `status:pending-redefinition` | Comment cap hit; locked. Details: [workflow-comment-cap.md](workflow-comment-cap.md). |

Catalog: [`docs/labels.md`](../labels.md).

## Priority

Priority labels and create defaults: [`docs/labels.md`](../labels.md). Discovery order: [workflow-dispatch.md](workflow-dispatch.md). Feedback priority: [feedback.md](feedback.md).

## Transitions and evidence

Evidence is freeform prose; intent clear. Post as an issue comment (refinement also edits the body), then call `enforce-task-workflow-status`. Every write follows [body-writes.md](body-writes.md).

| From | Action / evidence | To |
|------|-------------------|-----|
| pending-review | Pass review (latest comment); body consistent; deliverables/AC align with parent or project vision; note new requirements | pending-implementation |
| pending-review | Fail review: problems + refinement direction. Cascade another issue only when [workflow-cascade.md](workflow-cascade.md) authorizes it | pending-refinement |
| pending-review | Gaps that cannot be inferred from project scope: clarification questions | pending-clarification |
| pending-refinement | Refined issue body + summary comment | pending-review |
| pending-clarification | PO clarification comment | pending-review, or pending-refinement if refine still needed |
| pending-implementation | Comment summarizing deliverables (PRs/commits) | pending-verification |
| pending-verification | Independent pass: deliverables, standards, tests; deterministic record when an axis applies (reuse while `game/` matches) | pending-acceptance |
| pending-verification | Fail: detail issues | pending-implementation |
| pending-acceptance | Accept: AC evidence; related PRs; cite deterministic rubric record; llm-judge record when an axis applies | accepted |
| pending-acceptance | Fail (game/interface): link created defect | pending-implementation |
| pending-acceptance | Spec/ambiguity blocks testing (no defect) | pending-clarification |
| pending-acceptance | Cannot test without PO input | pending-clarification |
| pending-review … pending-acceptance | Supersession comment naming the successor ([terminal-states.md](terminal-states.md)) | superseded |

No row leaves `accepted` or `superseded`: both terminal ([terminal-states.md](terminal-states.md)).

## Review scope

First pass: the whole issue, its parent, and its siblings. After each fail→refine, only the latest fail list and broken required sections can fail it. A later fail stays on that new list. A return from clarification is holistic again.

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

Create skills apply the type label. Dispatch agents: [workflow-dispatch.md](workflow-dispatch.md). `redefine-project-issue`: [workflow-comment-cap.md](workflow-comment-cap.md).
