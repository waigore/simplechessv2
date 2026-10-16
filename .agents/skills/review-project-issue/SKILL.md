---
name: review-project-issue
description: |-
  Review an epic/task/defect in status:pending-review; post pass, fail, or
  clarification evidence and advance status via enforce-task-workflow-status.
  Use when the user asks to review an issue, approve it for implementation, request
  refinements, or escalate clarification to the product owner.

  Examples:
    - user: "Review #12" → holistic review, comment, gate status
    - user: "Fail review on #8; also impacts #9" → fail + cascade named related
    - user: "Needs clarification on #3" → questions comment → pending-clarification
---

# Review project issue

Review a typed issue currently in `status:pending-review`.

**Contract:** [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)

**Status gate:** [`enforce-task-workflow-status`](../enforce-task-workflow-status/SKILL.md) and [`status-transitions.md`](../enforce-task-workflow-status/references/status-transitions.md)

## Steps

1. **Load** issue `n`: title, body, labels, parent/sub-issues/siblings as available (`gh issue view`, linking docs under `create-project-task/references/` if needed).
2. **Assert** `status:pending-review` via enforce gate readiness (abort if wrong status).
3. **Review holistically** against the whole issue and parent/sibling relationships (including after prior refinements):
   - Body internally consistent; no major gaps/ambiguities/underspecifications
   - Deliverables and acceptance criteria align with parent goal/scope, or project vision if root-level
   - Acknowledge when the issue is a **new requirement**
   - **If `type:epic`** (addendum — epic granularity; wave-set coherence is [`audit-project-wave`](../audit-project-wave/SKILL.md)):
     - Goal is an observable outcome, not a task list; Scope has explicit in/out; out-of-scope names sibling epics or other waves when known
     - In-scope qualified IDs (from Notes/Scope) are owned by child tasks when children exist (coverage/ownership — not path-level AC polish)
     - Not a horizontal catch-all; foundation stays substrate-only
     - Vertical: demo-ready ID set in Notes looks sufficient for `create-gameplay-demo` without new product decisions; a demo follow-on task exists or its absence is called out. Foundation: no player demo task
4. **Decide** one outcome:
   - **Pass** — post a clear pass review comment (must be the latest comment when transitioning). Gate: `pending-review` → `pending-implementation`.
   - **Fail** — post problems + refinement direction; **explicitly name** impacted related issues. Gate this issue: `pending-review` → `pending-refinement`. For each named related issue, comment briefly (point at this fail) and apply fail-review cascade to `pending-refinement` per the transitions reference.
   - **Clarify** — summarize questions that cannot be inferred from project scope. Gate: `pending-review` → `pending-clarification`.
5. **Report** URL, outcome, new status(es), and related issues touched.

## Rules

- Do not redefine the state machine; link the workflow doc.
- Fail cascade only for issues **named** in the fail comment.
- Evidence is freeform; intent must be clear.
- Call `enforce-task-workflow-status` for every label change.
