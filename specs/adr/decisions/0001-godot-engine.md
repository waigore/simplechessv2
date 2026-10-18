# ADR-0001: Godot 4.7.2 engine

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Engine
- **Supersedes**: None
- **Informed by**: Definition Engine (Godot); Web/touch; Instant play; Clear board; Cafe calm; Performance; Load time; Reliability; Accessibility; Localization; Shared game; Puzzle stream; 2D view

## Context

Definition names Godot for a 2D browser game with touch and on-device move presentation. Version and scripting were unset.

## Purpose

Which Godot build and scripting language ship the Web game?

In scope: version, scripting, Web export, input. Out of scope: Stockfish, persistence, scene layout.

## Decision

**Godot 4.7.2** (stable) with **GDScript**. Ship **Web/HTML5** export. Touch primary. Piece motion, board, and local rules run in the client; a local move must not wait on the network. Advice is ADR-0002.

## Reasoning

1. Definition chose Godot for Web 2D and on-device presentation.
2. 4.7.2 was latest stable (not 4.8 beta).
3. GDScript fits a small 2D Web project.
4. Instant play over waiting on servers for moves.

Costs accepted: Web export size/performance limits of a browser runtime.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| None — engine set in the definition | Only version/scripting were open |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | Client move/render path: 60 fps; hitch ≤1 frame |
| Load time / latency | Affects | Cold open to playable board ≤3 s via Web export |
| Reliability | Affects | One Web sitting without engine-forced exit |
| Observability | No effect | Logging not chosen here |
| Save durability | No effect | ADR-0003 |
| Accessibility | Affects | Shape-readable pieces; readable UI text |
| Localization | Affects | Client loads `en`, `zh-Hant`, `ja` |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | MIT engine; no fee |
| Maintainability | 4.7.x line; upgrade via new ADR |
| Testability | Editor + export checks; Web headless limited |
| Portability | Web primary only |
| Security and privacy | No accounts here; Advice is ADR-0002 |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Web export touch board | Spike on 4.7.2 HTML5 | Before acceptance |
| Move hitch ≤1 frame | quality.md frame-time | Every release |
| Cold open ≤3 s | quality.md timed open | Every release |
| Sitting without forced exit | quality.md sitting soak | Every release |
| Piece shape and color-blind readability | quality.md readability checks | Every release |
| Locale spot-check | quality.md locale spot-check | Every release |
