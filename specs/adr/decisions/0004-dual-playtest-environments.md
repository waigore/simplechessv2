# ADR-0004: Dual playtest environments

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*`; Observability; Cafe calm; ADR-0001

## Context

Playtest requires Design protocols on Headless only and UX on Headless and Graphical; ADR-0001 defines neither session kinds nor Must tools.

## Purpose

How do agent playtest sessions run Headless and Graphical against the same Godot project?

In scope: session kinds, runner boundary, Must tools, playtest-build debug seams. Out of scope: protocol steps, evidence layout, wire schemas (technical).

## Decision

The Godot **4.7.2** project (ADR-0001) exposes **two playtest session kinds**:

1. **Headless** — Godot **`--headless`** (no display) for all Design protocols and UX Headless runs (`ENV.1`).
2. **Graphical** — **Web/HTML5** for UX Graphical runs and screenshots (`ENV.2`). A graphical run uses the shipped client, not an editor-with-display session.

**Must** debug UI (`DBG.1–4`) and telemetry (`TEL.1–5`) work in both. Debug UI and story-ID overlay ship in **playtest builds only**, not the public release Web export. Seams: `specs/technical/verification.md`.

## Reasoning

1. Playtest Must rows require both environments and drive paths.
2. Godot `--headless` fits CI Design runs without a display.
3. Graphical Web matches the shipped client for UX screenshots.
4. Debug seams stay out of release to protect Cafe calm.

Costs accepted: two build profiles to maintain.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Browser-only headless | Weaker Design CI without native `--headless` (driver 2) |
| Editor with display for Graphical | Not the shipped client, so screenshots would misrepresent UX (driver 3); ADR-0001 also limits Web headless |
| Rewrite ADR-0001 | Out of scope: ADR-0001 already fixes the engine, and the Must rows need session kinds and Must tools, which it leaves undefined (driver 1) |
| Debug UI in public Web | Adds debug chrome to play sessions (driver 4) |

## Non-functional requirements

Quality, engineering, and validation rows: [non-functional requirements](0004-dual-playtest-environments/non-functional.md).

### Quality expectations

Performance, Reliability, and Observability are Affects; the rest are No effect. Detail is in the split.

### Engineering qualities

Two build profiles from one project. Detail is in the split.

## Imposes

None.

## Validation

| Check | Method | When |
|-------|--------|------|
| Headless Design protocol | Spike: `--headless` + one Design protocol | Before acceptance |
| Graphical UX screenshots | Spike: Web + one UX protocol evidence | Before acceptance |
| Performance, Reliability, Observability rows | quality.md checks listed in the split | Every release |
