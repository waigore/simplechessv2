# Background dispatch agents

Automation entrypoints for unattended runs of the [issue workflow](workflow.md). Humans keep calling `*-project-issue` directly. Each agent handles **one** issue per run — do not drain the queue.

| Agent | Status filter | Delegates to |
|-------|---------------|--------------|
| `issue-workflow-review-agent` | `status:pending-review` | `review-project-issue` |
| `issue-workflow-refine-agent` | `status:pending-refinement` | `refine-project-issue` |
| `issue-workflow-clarify-agent` | `status:pending-clarification` | `clarify-project-issue` |
| `issue-workflow-implement-agent` | `status:pending-implementation` | do the work, then `implement-project-issue` |
| `issue-workflow-verify-agent` | `status:pending-verification` | `verify-project-issue` |
| `issue-workflow-accept-agent` | `status:pending-acceptance` | `accept-project-issue` |

No agent for `status:accepted` (terminal).

## Resolve the target issue

1. If `#n` is provided, use it (the underlying skill asserts the expected status).
2. Otherwise discover candidates: open issues with a type label (`type:epic`, `type:task`, or `type:defect`) and the agent's status filter.
3. Pick **one** by judgement (not a rigid sort). Prefer unblocked issues; prefer leaf tasks over parent epics when both are eligible; prefer older or more foundational work when ties remain; skip issues that clearly need human-only input you do not have (e.g. PO clarification with no answer in context).
4. Read and run the mapped `*-project-issue` skill for that issue. Do not invent parallel statuses, evidence formats, or transition rules. Independence still applies: do not verify or accept in the same session that posted the implementation summary.
