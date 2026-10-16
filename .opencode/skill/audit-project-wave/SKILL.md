---
name: audit-project-wave
description: |-
  Audit a filed implementation wave (GitHub milestone) against its milestone
  description and its type:epic issues: find gaps, overlaps, contradictions, or
  mis-membership that jeopardize deliverable completeness or quality. Propose
  fixes (new epics, milestone moves, set-level restructure); confirm with the
  user before mutating. Use after plan-project-waves filing, when a wave looks
  incomplete, or before expanding leaf tasks.

  Examples:
    - user: "Audit wave 1" → load milestone + epics, report, propose package, wait
    - user: "Draft wave audit only" → --no-create, print findings + proposed package
    - user: "Fix the wave 2 epic set" → confirm then file/move/restructure
---

# Audit project wave (facade)

Canonical instructions: [`.agents/skills/audit-project-wave/SKILL.md`](../../../.agents/skills/audit-project-wave/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
