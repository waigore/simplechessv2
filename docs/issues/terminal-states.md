# Terminal states and closing

Contract: [workflow.md](workflow.md). The two terminal statuses, what each one means, and who may close an issue.

## `accepted`

A verified issue whose acceptance evidence is recorded: it delivered, and it stays **open** (the `workflow.md` transition says "keep open"). Nothing leaves it.

## `superseded`

A finished non-delivering issue: superseded by, duplicate of, or retired in favour of another issue or an Accepted ADR. Its body or a linked supersession comment names the successor and links the review, refinement, or record that surfaced it.

Reach it from `pending-review`, `pending-refinement`, `pending-clarification`, `pending-implementation`, `pending-verification`, or `pending-acceptance` with a supersession comment that names the successor (an issue or an Accepted ADR) and links the review, refinement, or record that surfaced it. Nothing leaves it either.

## Closing

The transition table never closes an issue, so closure is a separate act:

- Only the issue's **owner** closes it — a human, or the orchestrator acting on a human's instruction.
- Only an issue holding `status:superseded` may be closed. An `accepted` issue stays open.
- No skill closes an issue. Every skill, `enforce-task-workflow-status` included, stops at the label.

A retirement therefore has a legal end state: gate to `status:superseded` with the successor named, then the owner closes it. First consumer: #561, which retires the duplicate #507 in favour of #335.
