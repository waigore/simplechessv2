# ADR-0004: Dual playtest environments

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*`; Observability; ADR-0001

## Context

Playtest requires Design protocols on Headless only and UX on Headless and Graphical. ADR-0001 ships Godot Web but does not define those session kinds or Must playtest tools.

## Purpose

How do agent playtest sessions run Headless and Graphical against the same Godot project?

In scope: session kinds, runner boundary, Must tools, playtest-build debug seams. Out of scope: protocol steps, evidence layout, wire schemas (technical).

## Decision

The Godot **4.7.2** project (ADR-0001) exposes **two playtest session kinds**:

1. **Headless** — Godot **`--headless`** (no display) for all Design protocols and UX Headless runs (`ENV.1`).
2. **Graphical** — **Web/HTML5** (or editor with display) for UX Graphical runs and screenshots (`ENV.2`).

**Must** debug UI (`DBG.1–4`) and telemetry (`TEL.1–5`) work in both. Debug UI and story-ID overlay ship in **playtest builds only**, not the public release Web export. Seams live in `specs/technical/verification.md` when authored.

## Reasoning

1. Playtest Must rows require both environments and drive paths.
2. Godot `--headless` fits CI Design runs without a display.
3. Graphical Web matches the shipped client for UX screenshots.
4. Debug seams stay out of release to protect Cafe calm.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Browser-only headless | Weaker Design CI without native `--headless` |
| Rewrite ADR-0001 | Accepted ADRs are immutable |
| Debug UI in public Web | Release ≠ playtest |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | Playtest I/O must not redefine the 60 fps player path |
| Load time / latency | No effect | Playtest builds are not the cold-open bar |
| Reliability | Affects | Headless/Graphical sessions complete without forced exit |
| Observability | Affects | `TEL.*` and story IDs visible for agent playtests |
| Save durability | No effect | ADR-0003 |
| Accessibility | No effect | — |
| Localization | No effect | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Godot MIT; no extra fee |
| Maintainability | Two profiles; upgrade with Godot line |
| Testability | Native headless + Web graphical; Must tools in both |
| Portability | Web primary; headless for CI hosts |
| Security and privacy | Debug seams not in public release |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Headless Design protocol | Spike: `--headless` + one Design protocol | Before acceptance |
| Graphical UX screenshots | Spike: Web + one UX protocol evidence | Before acceptance |
| Observability story IDs | quality.md playtest check | Every release |
