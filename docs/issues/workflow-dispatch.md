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

No agent for `status:accepted` (terminal). `status:superseded` is terminal too: dispatch skips it and no agent applies it ([terminal-states.md](terminal-states.md)).

## Resolve the target issue

1. If `#n` is provided, use it (the underlying skill asserts the expected status). In an agent-orc prompt, `Assigned issue: N` is `#n` when N is a number. `Assigned issue: none` means this step did not receive an issue.
2. Otherwise discover candidates: open issues with a type label (`type:epic`, `type:task`, or `type:defect`) and the agent's status filter.
3. Pick **one** using **priority first, then judgement**:
   1. **Priority tier** (hard): `priority:critical`, then `priority:high`, then `priority:normal` / unlabeled (unlabeled counts as normal). If more than one `priority:*` is present, use the highest tier and leave hygiene to `enforce-task-workflow-status`.
   2. **Within the same tier**, pick by judgement (not a rigid sort): prefer high-impact work — bottlenecks that unblock others (judge fan-out and how much dependents matter — not a raw count), foundational work, and other issues that move the project most. Prefer issues that are themselves unblocked and ready to advance; prefer leaf tasks over parent epics when both are eligible; age can break near-ties. Skip issues that clearly need human-only input you do not have (e.g. PO clarification with no answer in context).
4. Read and run the mapped `*-project-issue` skill for that issue. Do not invent parallel statuses, evidence formats, or transition rules.

Agents must not set or change `priority:*` labels (humans only), except hygiene via `enforce-task-workflow-status` when duplicates exist.

Trivial `[orc-e2e]` probe issues may use a minimal PR or doc touch as the implement deliverable.

Priority catalog: [`docs/labels.md`](../labels.md). agent-orc claim order: [`.orc/scripts/list-status-issues.sh`](../../.orc/scripts/list-status-issues.sh) and [`agent-orc/docs/config.md`](../../agent-orc/docs/config.md).
