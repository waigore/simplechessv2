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

# Create gameplay demo

Contract: [`docs/demos.md`](../../../docs/demos.md) and [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md). Demo README template: [`assets/demo-readme.md`](assets/demo-readme.md).

## Demo types

- **Engine**: proves rules, game state, feel, and camera in the chosen engine. No UI screens; a debug overlay is allowed. Reads design, view, aesthetics, and asset specs.
- **Gameplay**: a playable slice with the screens, navigation, and input it needs. Also reads UX specs.

Both types express the aesthetics and show only cataloged assets, agent-made or human-made. Neither uses uncataloged placeholder art or sound.

Default to **engine**. Pick **gameplay** only when the demo question is about UI, flow, or onboarding, or the user asks for it.

## Steps

### Scope

0. **Setup**: run [`ensure-project-setup`](../ensure-project-setup/SKILL.md) unless it already passed in this session. Continue only on Pass.
1. **Gate**: the [high-level stage](../capture-requirements/SKILL.md#high-level-stage) is locked in, and the engine in `specs/definition/definition.md` is realized by an **Accepted** Engine ADR in `specs/adr/`. Also satisfy [Before building](../../../docs/demo-style-assets.md#before-building). Otherwise stop, say what is missing, and offer `capture-requirements` or `audit-spec-tbd`.
2. **Load**: vision qualities; definition scope, objectives, platforms, depth; the design hub and the loops, features, and stages it indexes; the view hub; the aesthetics hub and the elements it indexes; the asset hub, `tools.md`, and the kind specs; for gameplay demos, the UX hub; Accepted ADRs. Skip `specs/adr/archive/` and requirement notes.
3. **Scope aggressively**:
   - Write the **demo question**: the one thing the demo must prove (e.g. "is the core loop fun for 2 minutes?").
   - Include only the spec elements, as qualified IDs (`F-movement.R3`), that the question needs. Prefer one loop, the features its steps need, and one stage or test arena.
   - Include the aesthetics elements those elements are seen or heard through (pillars, palette sets, form, motion, sound; interface style for gameplay demos).
   - List the **assets** the demo needs per [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md): for each, agent-made via [`manage-asset`](../manage-asset/SKILL.md) or person-supplied via [`register-asset`](../register-asset/SKILL.md) (ask which), kind/coverage when required, and whether it is already cataloged.
   - List everything else as excluded with a one-line reason. When in doubt, exclude.
4. **Find gaps** in the included elements: `TBD`, `<!-- fill in -->`, missing specs, contradictions. Classify **blocking** vs **non-blocking** per [`docs/demos.md`](../../../docs/demos.md) and the [style and asset gate](../../../docs/demo-style-assets.md#before-building). Non-blocking gaps become demo **assumptions**. Art and sound are never assumptions.
5. **Propose and confirm** in one summary: question, type, included IDs, assets to produce or reuse, excluded areas, blockers, assumptions. Wait for confirmation.
6. **Resolve blockers**: for confirmed product answers, run [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md) scoped to those paths when they are TBDs, or [`author-spec`](../author-spec/SKILL.md) / [`capture-requirements`](../capture-requirements/SKILL.md) for missing specs. A missing tool ADR is authored and must be Accepted before the build. Open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). Never encode an unconfirmed answer.
7. **Track**: use the given task, or create one with `create-project-task` whose body carries the confirmed scope, including the asset list. Building waits until the task is `status:pending-implementation`; if it is not, stop and report the next workflow step.

### Build

8. **Branch** `task/<n>-demo-<slug>` and create `demos/<slug>/`. Copy the template to `demos/<slug>/README.md` and fill it.
9. **Produce assets** under the demo task for each listed asset not yet cataloged: run [`manage-asset`](../manage-asset/SKILL.md) or [`register-asset`](../register-asset/SKILL.md) as chosen in scope. Record each pipeline problem as a **pipeline finding**, and file it as a spec change with `author-spec` or a defect with `create-project-defect`. If the assets would push the demo PR past ~30 files, land them first in their own PR.
10. **Implement** only the included elements and listed assumptions, loading assets from the catalog's asset root by asset ID. At each place a rule is encoded, add a comment citing its qualified ID, or `assumption A<n>`. Do not touch code outside `demos/<slug>/`.
11. **Smoke run**: launch the demo and record how to run it and what you saw, including that each included style element shows. Playtest per `specs/playtest/` only if the user asks.
12. **PR**: open per [`docs/pull-requests.md`](../../../docs/pull-requests.md). Authority and Test plan cite the included IDs, kind specs, Accepted ADRs, and asset review outcomes from the leaf skills. If a spec PR from step 6 is unmerged, keep this PR as draft (or wait) until that PR merges; do not add `no-automerge`. Then run [`implement-project-issue`](../implement-project-issue/SKILL.md).

## Rules

- Spec first still applies: every behavior traces to an included ID or a listed assumption. Assumptions never decide a blocking gap.
- Asset and catalog rules live in the leaf skills and [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md); do not invent a parallel bar.
- `docs/solid.md`, `docs/coding-conventions.md`, and structure continuity do not apply inside `demos/`; readable, working code is enough.
- Main code never imports from `demos/`. Reusing demo behavior in the main code is a separate task run with [`promote-gameplay-demo`](../promote-gameplay-demo/SKILL.md).
- Requirement notes are not authority; do not build from them.
- Do not grow scope during the build. A new need, including a new asset, goes back through steps 4–6.
