# Playtesting

Authoring rules: [`.agents/specs/rules/playtest/playtest.md`](../../.agents/specs/rules/playtest/playtest.md).

## Purpose

AI-agent playtesting proves the running build against game design and UX. It is not a unit or integration test plan (see `specs/technical/verification.md`). View stories are out of scope.

## Levels

| Level | Proves | Cites | Environment |
|-------|--------|-------|-------------|
| Design | Game behaves and feels as designed | Design story / element IDs | **Headless only** |
| UX | Actors can operate the interface as specified | UX story / journey IDs | **Headless and Graphical** (both required) |

## Environments

| Environment | Display | Used for |
|-------------|---------|----------|
| Headless | No graphics display | All Design protocols; all UX protocols |
| Graphical | Full rendered session | All UX protocols (in addition to Headless) |

## Coverage

- **Mode**: `full`
- **Critical IDs**: see [`coverage.md`](coverage.md)

## Gate

Required at `status:pending-acceptance` (`accept-project-issue`) when the issue's deliverables change playable behavior (game or code). Not required for spec-only, docs-only, or other non-playable deliverables.

When required: every in-scope **Design** protocol must pass on **Headless**; every in-scope **UX** protocol must pass on **Headless and Graphical**. Acceptance fails if either environment is missing for a required UX protocol, or if Headless is missing for a required Design protocol.

## Evidence

Root: [`docs/playtest/evidence/`](../../docs/playtest/evidence/). Each required run records story IDs, pass/fail, notes, and logs. Screenshots come from a graphical re-run of the same build and are required before acceptance, unless the protocol says none. A headless run may omit them without a defect. Schema: [`evidence.md`](evidence.md).

## Architecture constraints

| Kind | Capability | Playtest need |
|------|------------|---------------|
| Must | Debug UI | Agent can inspect and control play state while running protocols |
| Must | Telemetry events | Agent can correlate observations to story IDs and outcomes |
| Must | Headless session | Design and UX protocols run with no graphics display |
| Must | Graphical session | UX protocols run in a full rendered environment |
| Situational | Seed, replay, state dump, timing, telemetry read, legibility viewport — see [`tools.md`](tools.md) and [`tools-situational.md`](tools-situational.md) | When a protocol requires them |

ADRs and technical design (including verification seams) must satisfy Must rows. Situational rows apply only when a protocol needs them. Detail: [`tools.md`](tools.md), [`tools-situational.md`](tools-situational.md).

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`coverage.md`](coverage.md), [`tools.md`](tools.md), [`tools-situational.md`](tools-situational.md), [`procedures.md`](procedures.md), [`evidence.md`](evidence.md).

**Design protocols** (Headless only):

- [`design/shared-game.md`](design/shared-game.md)
- [`design/puzzle-stream.md`](design/puzzle-stream.md)
- [`design/move-advice.md`](design/move-advice.md)
- [`design/mode-and-config.md`](design/mode-and-config.md)
- [`design/end-conditions.md`](design/end-conditions.md)
- [`design/game-state.md`](design/game-state.md)
- [`design/pieces-common.md`](design/pieces-common.md)
- [`design/pieces-king.md`](design/pieces-king.md)
- [`design/pieces-officers.md`](design/pieces-officers.md)
- [`design/pieces-pawn.md`](design/pieces-pawn.md)
- [`design/difficulty.md`](design/difficulty.md)
- [`design/progression.md`](design/progression.md)

**UX protocols** (Headless + Graphical):

- [`ux/shared-session.md`](ux/shared-session.md)
- [`ux/puzzle-session.md`](ux/puzzle-session.md)
- [`ux/mode-pick.md`](ux/mode-pick.md)
- [`ux/shared-setup.md`](ux/shared-setup.md)
- [`ux/shared-play.md`](ux/shared-play.md)
- [`ux/shared-result.md`](ux/shared-result.md)
- [`ux/puzzle-play.md`](ux/puzzle-play.md)
- [`ux/controls.md`](ux/controls.md)
- [`ux/navigation.md`](ux/navigation.md)
- [`ux/exceptions.md`](ux/exceptions.md)
- [`ux/localization.md`](ux/localization.md)
