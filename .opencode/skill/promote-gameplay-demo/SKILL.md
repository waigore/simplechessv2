---
name: promote-gameplay-demo
description: |-
  Promote behavior from a gameplay demo under demos/<slug>/ into the main
  code. Re-checks the demo's decisions against current specs, writes the
  assumptions it relies on into specs with user confirmation, covers the code
  in the technical design, then reimplements it in the main tree under SOLID,
  the coding conventions, and the normal test bar. The demo stays unchanged as the reference.
  Use when the user asks to promote, port, or reuse demo code in the game.

  Examples:
    - user: "Promote the movement demo into the game" → whole demo scope, task, specs, rewrite
    - user: "Promote only jumping from demos/movement" → only the elements for jumping
    - user: "Promotion task #30 passed review, build it" → implement phase only
---

# Promote gameplay demo (facade)

Canonical instructions: [`.agents/skills/promote-gameplay-demo/SKILL.md`](../../../.agents/skills/promote-gameplay-demo/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
