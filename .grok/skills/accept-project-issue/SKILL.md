---
name: accept-project-issue
description: |-
  Accept, fail, or escalate clarification for an epic/task/defect in
  status:pending-acceptance using test evidence against acceptance criteria.
  Use when running acceptance testing after verification.

  Examples:
    - user: "Accept #12 with evidence in docs/playtest/evidence/..." → accept comment, status:accepted, leave open
    - user: "Acceptance failed; file defect" → create defect, link, → pending-implementation
    - user: "Need PO input to finish acceptance on #12" → pending-clarification
---

# Accept project issue (facade)

Canonical instructions: [`.agents/skills/accept-project-issue/SKILL.md`](../../../.agents/skills/accept-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
