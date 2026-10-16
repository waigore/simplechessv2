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

# Audit project wave

High-level audit of a **filed** wave: milestone description (expected deliverable) vs its epics. Contract: [`docs/issues/waves.md`](../../../docs/issues/waves.md). Issue shapes: [`docs/issues/`](../../../docs/issues/). Do not redefine body headings.

**Delegates (after confirm):** [`create-project-epic`](../create-project-epic/SKILL.md) for new epics; `gh` for milestone description edits and issue ↔ milestone assignment. Leaf tasks and per-epic review stay with [`plan-project-waves`](../plan-project-waves/SKILL.md) and [`review-project-issue`](../review-project-issue/SKILL.md).

## Steps

1. **Resolve the wave**: milestone title or number (default: ask). Load milestone title + **description**, and every open/closed `type:epic` assigned to it (`gh`).
2. **Gate — milestone description**: It must state the wave’s **expected deliverable** (one coherent outcome). If missing or too vague to judge fit → **Clarify** (propose a description from epic goals + specs; do not invent product scope). Stop mutations until the user confirms a description; then set it on the milestone before continuing, or abort if they want draft-only.
3. **Inventory (light)**: From `specs/`, list stable IDs that the milestone description implies (loops, `F-*`, `FL-*`, journeys/screens, foundation needs, Accepted ADRs as needed). Skip `specs/adr/archive/`. Blocking TBDs on IDs the deliverable needs → note and offer [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md); do not invent decisions.
4. **Audit epic set** (epics as units only — do not open leaf AC quality):
   - **Completeness**: Does the union of epic goals/in-scope cover the milestone description? Missing capability that fits no existing epic → propose a **new epic**.
   - **Fit**: Does each epic clearly contribute to the milestone description? Misplaced → propose **move** to another milestone (or out of this wave).
   - **Overlap / contradiction**: Double-claimed IDs or conflicting in/out-of-scope across epics → propose scope split or Notes/scope edits (set-level only).
   - **Foundation (wave 1)**: Bootstrap + asset pipeline (+ substrate verticals need) present and thin; play not buried in a catch-all systems epic.
   - **Vertical packaging**: Each vertical has demo-ready ID set in Notes and a demo follow-on *task* exists or is noted as missing (existence only). Foundation epics must not carry a player demo task.
   - **Anti-patterns**: Horizontal catch-alls; out-of-scope that does not name a sibling/other wave when known; cross-wave hard deps that break this wave’s stated deliverable.
5. **Propose package**: Verdict (**Pass** / **Fail** / **Clarify**), findings, and mutations (description text, new epic Goal/Scope/Notes drafts, milestone moves, set-level scope/Notes edits). **Confirm before any mutation.** If `--no-create` / “draft only”: print and stop.
6. **Apply** (after confirm only): update milestone description; create epics via `create-project-epic` and assign to the milestone; move epics with `gh`; apply agreed set-level body edits. Do not file leaf tasks or demo builds here.
7. **Report**: milestone URL, verdict, what changed, remaining risks, and whether [`review-project-issue`](../review-project-issue/SKILL.md) should run on new/changed epics.

## Report shape

```markdown
**Wave audit: <milestone title> — <Pass | Fail | Clarify>**

Expected deliverable (milestone description): <summary or "MISSING">

Findings:
- <gap | overlap | contradiction | mis-membership | packaging | foundation> — <epic #n or set> — <why it jeopardizes the deliverable>

Proposed package (confirm before apply):
- Milestone description: <edit or none>
- New epics: <titles / goals or none>
- Moves: <#n → milestone or none>
- Set-level epic edits: <#n — what or none>

Out of scope this skill: <leaf tasks / AC polish / code>
```

## Rules

- Confirm before every mutation. Do not invent goal/scope the user rejected.
- Stay at epic-set level; do not rewrite task deliverables or AC.
- Prefer vertical outcomes; foundation only for shared substrate.
- Bodies stay within [body-shapes.md](../../../docs/issues/body-shapes.md).
- Requirement notes under `docs/requirements/` are not authority.

## Related

- Contract: `docs/issues/waves.md`
- Plan: `plan-project-waves`
- Epic review: `review-project-issue`
