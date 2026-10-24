---
name: promote-poc
description: |-
  Reimplement one PoC's confirmed keep/adapt list in the main tree. The list
  comes from reconcile-poc. Writes assumptions into specs, covers the code in
  the technical design, then reimplements under SOLID, coding conventions, and
  the normal test bar. The PoC stays unchanged as reference.
  Use after that act has passed, or when a promotion task is ready to build.

  Examples:
    - user: "Promote the movement PoC into the game" → reconcile-poc, then reimplement
    - user: "Promotion task #30 passed review, build it" → implement phase only
---

# Promote PoC (facade)

Canonical instructions: [`.agents/skills/promote-poc/SKILL.md`](../../../.agents/skills/promote-poc/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
