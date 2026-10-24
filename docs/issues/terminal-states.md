# Terminal states and closing

Contract: [workflow.md](workflow.md). The two terminal statuses, what each one means, and who may close an issue.

## `accepted`

A verified issue whose acceptance evidence is recorded: it delivered. Acceptance skills leave it **open**; nothing leaves the status. [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) may close it later (leaves first, then parents when children are closed/catered for).

## `superseded`

A finished non-delivering issue: superseded by, duplicate of, or retired in favour of another issue or an Accepted ADR. Its body or a linked supersession comment names the successor and links the review, refinement, or record that surfaced it.

Reach it from `pending-review`, `pending-refinement`, `pending-clarification`, `pending-implementation`, `pending-verification`, or `pending-acceptance` with a supersession comment that names the successor (an issue or an Accepted ADR) and links the review, refinement, or record that surfaced it. Skills leave it **open**; nothing leaves the status. Planner may close it the same way as `accepted`.

## Closing

The transition table never closes an issue, so closure is a separate act:

- Only [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) closes typed issues, and only when they hold `status:accepted` or `status:superseded`.
- No other skill closes an issue. Every skill, `enforce-task-workflow-status` included, stops at the label.

A retirement therefore has a legal end state: gate to `status:superseded` with the successor named; planner closes it on a later pass. First consumer: #561, which retires the duplicate #507 in favour of #335.
