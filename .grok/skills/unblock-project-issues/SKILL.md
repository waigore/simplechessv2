---
name: unblock-project-issues
description: |-
  Clear a native blocked-by link when the blocker is status:accepted or closed
  and the default branch shows that issue's deliverables. Use when unblocking
  issues, checking whether a blocker is done in the repo, or at the start of a
  project-planner-agent pass. Does not add dependencies or close issues.

  Examples:
    - user: "Unblock issues whose blockers are done" → judge every open edge against the default branch
    - user: "Can #40 proceed?" → judge #40's blockers only
    - called by project-planner-agent at the start of a pass
---

# Unblock project issues (facade)

Canonical instructions: [`.agents/skills/unblock-project-issues/SKILL.md`](../../../.agents/skills/unblock-project-issues/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
