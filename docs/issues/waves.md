# Implementation waves

How agents slice a defined spec set into shippable waves. Skills: [`plan-project-waves`](../../.agents/skills/plan-project-waves/SKILL.md) (cut and file), [`audit-project-wave`](../../.agents/skills/audit-project-wave/SKILL.md) (audit filed epic set). Index: [README.md](README.md).

## Wave vs epic

| Concept | What it is |
|---------|------------|
| **Wave** | A GitHub **milestone** — a set of epics that ship as one coherent deliverable |
| **Epic** | One focused outcome: usually a **vertical** player-facing slice; sometimes a **foundation** epic |

A wave is not an issue type. Milestone title: `Wave N — <coherent outcome>`.

## Milestone description

Every wave milestone **must** have a description that states the wave’s **expected deliverable** — what “this wave ships” means in one short summary. That text is the authority for whether the epic set fits and suffices. `plan-project-waves` writes it when creating milestones; `audit-project-wave` fails or clarifies when it is missing or too vague to judge.

## Foundation

Wave 1 always includes **bootstrap** and the **asset pipeline** in full, plus any other framework substrate the wave-1 verticals need. Foundation epics/tasks are ordered first with native **blocked-by** so later epics reuse them. Prefer thin foundation that unlocks the wave; do not hide vertical play inside a catch-all “systems” epic.

## Vertical epics

Prefer self-contained vertical slices (design + UX + tech + assets for one outcome). No horizontal catch-alls (“all screens”, “all features”). Out-of-scope names sibling epics. Depth stays at most epic → task → task ([hierarchy.md](hierarchy.md)).

## Demo follow-on

Each **vertical** epic carries a **demo-ready ID set** in Notes (qualified spec IDs sufficient for [`create-gameplay-demo`](../../.agents/skills/create-gameplay-demo/SKILL.md) without new product decisions). Demo is a **follow-on** `type:task`, blocked by that epic’s implementation leaves — not built inside the epic. Foundation epics have no player demo task.

## Filing

- Confirm the wave map with the user before creating milestones or issues (`--no-create` / draft-only allowed).
- Create milestones for every planned wave (title + **expected-deliverable description**); file epics for those waves.
- File **leaf tasks only for the wave being expanded** (first run: wave 1). Later waves keep epic stubs until a later `plan-project-waves` run expands them.
- Issue bodies use [body-shapes.md](body-shapes.md) only; wave metadata lives in Notes / AC / Dependencies.

## Auditing a filed wave

Use [`audit-project-wave`](../../.agents/skills/audit-project-wave/SKILL.md) against the milestone description and its epics (epic-set level only). Confirm before filing new epics, moving epics across milestones, or set-level restructure. Per-epic body/child quality: [`review-project-issue`](../../.agents/skills/review-project-issue/SKILL.md).
