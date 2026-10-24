# Gameplay demos

A demo is a small, playable build that proves one thing about the game. It lives apart from the main code and is a **reference artifact**: it shows how the specs play, and records the design decisions it encodes. Scope it with [`scope-gameplay-demo`](../.agents/skills/scope-gameplay-demo/SKILL.md), then build it with [`create-gameplay-demo`](../.agents/skills/create-gameplay-demo/SKILL.md).

## Where

One folder per demo: `demos/<slug>/`, holding the code and a `README.md` copied from the [demo README template](../.agents/skills/create-gameplay-demo/assets/demo-readme.md). Demos land through PRs like any other task.

## Types

| Type | Proves |
|------|--------|
| Engine | Rules, game state, feel, camera; no UI screens. A debug overlay is allowed. |
| Gameplay | A playable slice with its screens and input |

Default to engine. Pick gameplay when the demo question is about UI, flow, or onboarding, or the user asks.

## Before building

[`scope-gameplay-demo`](../.agents/skills/scope-gameplay-demo/SKILL.md) applies this section. Do not add gates.

Always:

- [`ensure-project-setup`](../.agents/skills/ensure-project-setup/SKILL.md) has passed.
- The [high-level stage](../.agents/skills/capture-requirements/SKILL.md#high-level-stage) (vision, definition, quality) is locked in.
- The engine in `specs/definition/definition.md` is realized by an **Accepted** Engine ADR in `specs/adr/`.
- The user has confirmed the scope.
- The demo task is `status:pending-implementation` before building.

Any other gap blocks only when this demo must show or apply that decision. A cited TBD it does not show or apply stays open. Excluded specs may stay TBD.

Style and assets block only when the demo must show or play them ([Before building](demo-style-assets.md#before-building)).

## What is relaxed

- [SOLID](solid.md), [coding conventions](coding-conventions.md), and structure continuity do not apply. `review-code` skips `demos/`.
- Unit tests are optional.
- Playtesting per `specs/playtest/` is optional, on request.

## What is not relaxed

- **Spec first**: every behavior traces to an included spec element or a listed assumption.
- **Traceability**: the demo README lists included and excluded spec elements, the decisions encoded (each citing a spec element), and the assumptions made. Code comments cite the spec element or assumption where a rule is encoded.
- **Assumptions** cover only non-blocking gaps inside what the demo shows or applies (tuning, copy, layout). They are not decisions and do not authorize main code.

## Verification

`verify-project-issue` checks a demo against its task's scope and its README: every included element is shown, every decision cites a spec element that exists, and the run instructions work. Style and assets are checked per [Verification](demo-style-assets.md#verification). No code review.

## Promotion

Main-code work waits until the [promotion gate](demo-promotion.md) has passed. [`require-demo-promotion`](../.agents/skills/require-demo-promotion/SKILL.md) runs the act. [`promote-gameplay-demo`](../.agents/skills/promote-gameplay-demo/SKILL.md) reimplements a non-empty keep list.
