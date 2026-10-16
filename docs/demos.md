# Gameplay demos

A demo is a small, playable build that proves one thing about the game. It lives apart from the main code and is a **reference artifact**: it shows how the specs play, and records the design decisions it encodes. It is also a proof of concept for the game's style and its asset pipeline. Build one with the [`create-gameplay-demo`](../.agents/skills/create-gameplay-demo/SKILL.md) skill.

## Where

One folder per demo: `demos/<slug>/`, holding the code and a `README.md` copied from the [demo README template](../.agents/skills/create-gameplay-demo/assets/demo-readme.md). Demos land through PRs like any other task.

## Types

| Type | Proves | Reads |
|------|--------|-------|
| Engine | Rules, game state, feel, camera; no UI | Design, view, aesthetics, assets, ADRs |
| Gameplay | A playable slice with its screens and input | Design, view, aesthetics, UX, assets, ADRs |

## Before building

- The high-level stage (vision, definition, quality) is locked in.
- The Engine ADR is Accepted.
- The style and asset specs the demo needs are ready ([Before building](demo-style-assets.md#before-building)).
- Every blocking gap in scope is decided by the user and written to `specs/`.

## Style and assets

Both types express the style in `specs/aesthetics/` and show only cataloged assets per `specs/assets/`, each reviewed or exempted by a person. No uncataloged placeholders. The README records pipeline findings. Contract: [demo-style-assets.md](demo-style-assets.md).

## What is relaxed

- [SOLID](solid.md), [coding conventions](coding-conventions.md), and structure continuity do not apply. `review-code` skips `demos/`.
- Unit tests are optional.
- Playtesting per `specs/playtest/` is optional, on request.

## What is not relaxed

- **Spec first**: every behavior traces to an included spec element or a listed assumption.
- **Traceability**: the demo README lists included and excluded spec elements, the decisions encoded (each citing a spec element), and the assumptions made. Code comments cite the spec element or assumption where a rule is encoded.
- **Assumptions** cover only non-blocking gaps (tuning, copy, layout details). Missing style or asset specs are blocking. Assumptions are not decisions and do not authorize main code.

## Verification

`verify-project-issue` checks a demo against its task's scope and its README: every included element is shown, every decision cites a spec element that exists, and the run instructions work. Style and assets are checked per [Verification](demo-style-assets.md#verification). No code review.

## Promotion

Main code never imports from `demos/`. Promotion reimplements demo behavior in the main tree, with the demo as reference; it is not a file move. Run it with the [`promote-gameplay-demo`](../.agents/skills/promote-gameplay-demo/SKILL.md) skill, as its own task. Promotion:

1. re-checks each decision against current specs; where they differ, the spec wins;
2. writes every assumption it relies on into `specs/`, confirmed by the user;
3. adds the technical design the code needs per `specs/technical/` rules;
4. approves every draft asset it uses per the asset hub's approval rule;
5. passes `review-code` and the normal test bar.

A subset of a demo's included elements may be promoted. The demo folder stays as it was.
