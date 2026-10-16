# Issue workflow status

Applies equally to Epic, Task, and Defect. Source of truth for status labels and transitions. Skills must follow this — do not invent parallel statuses. Background dispatch: [workflow-dispatch.md](workflow-dispatch.md).

## Labels

Exactly **one** `status:*` label per typed issue. Skills swap via `enforce-task-workflow-status`.

| Label | Meaning |
|-------|---------|
| `status:pending-review` | Awaiting review (default on create) |
| `status:pending-refinement` | Reviewed; refinements needed |
| `status:pending-clarification` | Needs product-owner clarification |
| `status:pending-implementation` | Passed review; ready or in progress |
| `status:pending-verification` | Implemented; awaiting verification |
| `status:pending-acceptance` | Verified; awaiting acceptance testing |
| `status:accepted` | Accepted; **leave open** (do not close) |

Catalog: [`docs/labels.md`](../labels.md).

## Transitions and evidence

Evidence is freeform prose; intent must be clear. Post evidence as an issue comment (except refinement, which also edits the body). Then call `enforce-task-workflow-status` to apply the next label.

| From | Action / evidence | To |
|------|-------------------|-----|
| pending-review | Pass review (latest comment); body consistent; deliverables/AC align with parent or project vision; note new requirements | pending-implementation |
| pending-review | Fail review: problems + refinement direction; name impacted related issues | pending-refinement (self + named related) |
| pending-review | Gaps that cannot be inferred from project scope: clarification questions | pending-clarification |
| pending-refinement | Refined issue body + summary comment | pending-review |
| pending-clarification | PO clarification comment | pending-review, or pending-refinement if refine still needed |
| pending-implementation | Comment summarizing deliverables (PRs/commits) | pending-verification |
| pending-verification | Independent pass: checked each deliverable; standards followed; adequate tests | pending-acceptance |
| pending-verification | Fail: detail issues | pending-implementation |
| pending-acceptance | Accept: repo-locatable test evidence per AC; related PRs | accepted (keep open) |
| pending-acceptance | Fail: link created defect | pending-implementation |
| pending-acceptance | Cannot test without PO input | pending-clarification |

Reviews are holistic against the whole issue and its parent/sibling relationships, including after prior refinements.

## Cascade (fail review)

Move only the reviewed issue plus issues the fail comment **explicitly names** as impacted. Do not auto-cascade the whole tree.

## Independence

Verification and acceptance must not be done in the same session that posted the implementation summary. Prefer a different comment author than that summary when detectable.

## Skills

| Skill | Role |
|-------|------|
| `enforce-task-workflow-status` | Gate transitions; audit/repair status labels |
| `review-project-issue` | Review pass / fail / clarify |
| `refine-project-issue` | Body refine → pending-review |
| `clarify-project-issue` | Record PO clarification |
| `implement-project-issue` | Implementation summary → pending-verification |
| `verify-project-issue` | Independent verify pass / fail |
| `accept-project-issue` | Accept / fail / clarify |

Create skills always apply `status:pending-review` with the type label. Dispatch agents: [workflow-dispatch.md](workflow-dispatch.md).
