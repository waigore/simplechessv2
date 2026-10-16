---
name: plan-project-waves
description: |-
  Inventory a defined spec set, cut implementation waves as GitHub milestones,
  and file vertical epics plus leaf tasks for the wave being expanded (first
  run: wave 1), with foundation first and demo follow-on tasks per vertical
  epic. Proposes a genre-flexible slice axis; confirms with the user before
  filing. Use when planning implementation from specs, slicing a large game
  into shippable waves, or expanding the next wave into tasks.

  Examples:
    - user: "Plan implementation waves from the specs" → inventory, axis, wave map, confirm, file
    - user: "Draft the wave plan only" → --no-create, print milestones/epics/tasks
    - user: "Expand wave 2 into tasks" → inventory delta, leaf tasks under wave-2 epics
---

# Plan project waves

Cut shippable **waves** (milestones) and **vertical epics** from `specs/`, then file issues. Contract: [`docs/issues/waves.md`](../../../docs/issues/waves.md). Issue shapes: [`docs/issues/`](../../../docs/issues/). Do not redefine body headings.

**Delegates:** [`create-project-epic`](../create-project-epic/SKILL.md), [`create-project-task`](../create-project-task/SKILL.md). Milestones and `--milestone` via `gh`. Linking: [`../create-project-task/references/github-issue-linking.md`](../create-project-task/references/github-issue-linking.md).

## Slice axes (pick one per run; light mix OK)

| Axis | Typical when |
|------|----------------|
| Loop | Arcade / action; prove the core verb |
| Flow / journey | Narrative, meta-progression, onboarding spine |
| Mode / sub-game | Distinct play containers |
| Stage / content pack | Content-led once a spine exists |
| System + scenario | Strategy / sim / management |

## Steps

0. **Setup**: run [`ensure-project-setup`](../ensure-project-setup/SKILL.md) unless it already passed this session. Continue only on Pass.
1. **Gate**: [high-level stage](../capture-requirements/SKILL.md#high-level-stage) locked; Engine ADR **Accepted**. Enough design / UX / technical / assets to inventory the target wave. Blocking TBDs on IDs you would include → stop; offer [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) / [`author-spec`](../author-spec/SKILL.md). Requirement notes are not authority. Skip `specs/adr/archive/`.
2. **Inventory**: Index stable IDs (loops, `F-*`, `FL-*`, stages, sub-games; UX journeys/screens; aesthetics/assets as needed; Accepted ADRs; technical **Serves** links). Sketch dependencies only — not tasks yet.
3. **Propose slice axis** from the inventory; confirm with the user (structured choice when available).
4. **Cut waves**: Milestone title `Wave N — <coherent outcome>`; milestone **description** = short **expected deliverable** (authority for later [`audit-project-wave`](../audit-project-wave/SKILL.md)). **Wave 1** = full **bootstrap** + **asset pipeline** (+ other framework the wave-1 verticals need) **and** the smallest set of vertical epics that form one coherent first deliverable. Later waves extend along the axis. No horizontal catch-all epics.
5. **Self-containment** (each vertical epic): included qualified IDs; out-of-scope naming siblings; substrate consumed from foundation; **demo-ready ID set** (enough for [`create-gameplay-demo`](../create-gameplay-demo/SKILL.md) without new product decisions). Shrink or split if demo scope would need blockers. Foundation epics: no demo-ready set.
6. **Order**: Foundation first; wire `blocked-by`. Same-wave verticals may be parallel when they only need foundation. Demo follow-on blocked by that epic’s implementation leaves.
7. **Propose** one package: axis, milestones (title + expected-deliverable description), epic goals/scope/Notes fields, leaf tasks for the **wave being expanded** (first run: wave 1) with deliverables + AC citing spec IDs, demo follow-on tasks, blockers. Wait for confirmation. If `--no-create` / “draft only”: print the package and stop.
8. **File** (after confirm):
   - Create milestones for every planned wave (`gh`), each with title and expected-deliverable **description**.
   - Create epics for all planned waves (later waves = stubs, no children) via `create-project-epic`; put wave metadata in **Notes** (axis, wave name, included IDs, demo-ready set, “demo is follow-on task”).
   - For the expanded wave only: leaf tasks via `create-project-task` (depth ≤ 3); one demo follow-on task per **vertical** epic (AC: run `create-gameplay-demo` from the epic’s demo-ready set).
   - Assign issues to their milestone; wire sub-issues and blocked-by.
9. **Report**: milestone and issue URLs, dependency summary, when demo tasks are unblocked. Offer [`audit-project-wave`](../audit-project-wave/SKILL.md) once epics are filed if the user wants a coherence check.

**Expand later wave:** same steps; inventory delta; file leaf + demo tasks under that wave’s existing epics (create missing epics if needed). Do not re-break wave 1 unless asked.

## Rules

- Confirm before filing. Do not invent goal/scope/deliverables the user rejected.
- Prefer vertical player outcomes; foundation only for shared substrate.
- Bodies stay within [body-shapes.md](../../../docs/issues/body-shapes.md).
- Do not build demos or game code in this skill.

## Related

- Contract: `docs/issues/waves.md`
- Audit filed wave: `audit-project-wave`
- Demo: `create-gameplay-demo`
- Hierarchy: `docs/issues/hierarchy.md`
