---
name: create-gameplay-demo
description: |-
  Scope and build a gameplay demo under demos/<slug>/: either a pure engine
  demo (core rules and feel, no UI) or a full gameplay demo with UI/UX. Scopes
  aggressively to the fewest spec elements that answer one demo question,
  clarifies blocking gaps with the user and writes the answers back to specs,
  then builds the demo as a reference artifact that cites its specs. Every
  demo expresses the aesthetics and uses only cataloged pipeline assets, as a
  proof of concept for both. Demo code is exempt from code review but not
  from spec first.
  Use when the user asks for a demo, prototype, vertical slice, or proof of a
  mechanic built from the specs.

  Examples:
    - user: "Build a demo of the core loop" → scope, confirm, task, build engine demo
    - user: "Gameplay demo with menus and HUD for stage 1" → gameplay type, UX in scope
    - user: "Demo task #21 passed review, build it" → build phase only
    - user: "Promote the movement demo into the game" → use promote-gameplay-demo instead
---

# Create gameplay demo (facade)

Canonical instructions: [`.agents/skills/create-gameplay-demo/SKILL.md`](../../../.agents/skills/create-gameplay-demo/SKILL.md).

Read that file and its `assets/` as needed, then run the workflow there. Do not invent a parallel process.
