---
name: plan-project-waves
description: |-
  Inventory a defined spec set, cut implementation waves as GitHub milestones,
  and file vertical epics plus leaf tasks for the wave being expanded (first
  run: wave 1), with foundation first. At least one demo, then its promotion
  act, blocks main-code leaves. Proposes a genre-flexible slice axis; confirms with the user before
  filing. Use when planning implementation from specs, slicing a large game
  into shippable waves, or expanding the next wave into tasks.

  Examples:
    - user: "Plan implementation waves from the specs" → inventory, axis, wave map, confirm, file
    - user: "Draft the wave plan only" → --no-create, print milestones/epics/tasks
    - user: "Expand wave 2 into tasks" → inventory delta, leaf tasks under wave-2 epics
---

# Plan project waves (facade)

Canonical instructions: [`.agents/skills/plan-project-waves/SKILL.md`](../../../.agents/skills/plan-project-waves/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
