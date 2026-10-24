---
name: create-gameplay-demo
description: |-
  Build a gameplay demo under demos/<slug>/ after scope-gameplay-demo passes:
  either a pure engine demo (core rules and feel, no UI) or a full gameplay
  demo with UI/UX. Builds only the confirmed scope as a reference artifact
  that cites its specs. Demo code is exempt from code review but not from
  spec first.
  Use when the user asks for a demo, prototype, vertical slice, or proof of a
  mechanic built from the specs.

  Examples:
    - user: "Build a demo of the core loop" → scope-gameplay-demo, then build an engine demo
    - user: "Gameplay demo with menus and HUD for stage 1" → gameplay type, UX in scope
    - user: "Demo task #21 passed review, build it" → scope check, then build
    - user: "Promote the movement demo into the game" → use require-demo-promotion first
---

# Create gameplay demo

Contract: [`docs/demos.md`](../../../docs/demos.md) and [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md). Demo README template: [`assets/demo-readme.md`](assets/demo-readme.md).

## Steps

### Scope

Run [`scope-gameplay-demo`](../scope-gameplay-demo/SKILL.md). Continue only when it passes. Do not restate its gate or scope rules.

### Build

1. **Branch** `task/<n>-demo-<slug>` and create `demos/<slug>/`. Copy the template to `demos/<slug>/README.md` and fill it.
2. **Produce assets** under the demo task for each listed asset not yet cataloged: run [`manage-asset`](../manage-asset/SKILL.md) or [`register-asset`](../register-asset/SKILL.md) as chosen in scope. Record each pipeline problem as a **pipeline finding**, and file it as a spec change with `author-spec` or a defect with `create-project-defect`. If the assets would push the demo PR past ~30 files, land them first in their own PR.
3. **Implement** only the included elements and listed assumptions, loading listed assets from the catalog's asset root by asset ID. At each place a rule is encoded, add a comment citing its qualified ID, or `assumption A<n>`. Do not touch code outside `demos/<slug>/`.
4. **Smoke run**: launch the demo and record how to run it and what you saw, including each included style element. Playtest per `specs/playtest/` only if the user asks.
5. **PR**: open per [`docs/pull-requests.md`](../../../docs/pull-requests.md). Authority and Test plan cite the included IDs, and any kind specs, Accepted ADRs, and asset review outcomes the scope uses. If a spec PR from scoping is unmerged, keep this PR as draft (or wait) until that PR merges; do not add `no-automerge`. Then run [`implement-project-issue`](../implement-project-issue/SKILL.md).

## Rules

- Spec first still applies: every behavior traces to an included ID or a listed assumption. Assumptions never decide a blocking gap.
- Included style and assets follow [`docs/demo-style-assets.md`](../../../docs/demo-style-assets.md) and the leaf skills. Do not invent a parallel bar.
- `docs/solid.md`, `docs/coding-conventions.md`, and structure continuity do not apply inside `demos/`; readable, working code is enough.
- Main code never imports from `demos/`. Reusing demo behavior starts with [`require-demo-promotion`](../require-demo-promotion/SKILL.md), then [`promote-gameplay-demo`](../promote-gameplay-demo/SKILL.md) for a non-empty keep list.
- Requirement notes are not authority; do not build from them.
- Do not grow scope during the build. A new need, including a new asset, goes back through [`scope-gameplay-demo`](../scope-gameplay-demo/SKILL.md).
