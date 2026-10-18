# ADR-0006: Layered client game architecture

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Game architecture
- **Supersedes**: None
- **Informed by**: Instant play; Observability; Reliability; Save durability; Playtest `DBG.*` `TEL.*`; design loops and game-state; ADR-0001; ADR-0002; ADR-0003; ADR-0004

## Context

The Godot Web client (ADR-0001) runs everything on-device except Advice (ADR-0002); saves sit in origin `localStorage` (ADR-0003); full depth demands verifiable rules and seams (ADR-0004). No layer or ownership decision existed.

## Purpose

How is the client structured so moves stay synchronous, rules testable, and seams out of game code?

In scope: layers, dependency rules, state ownership. Out of scope: ADR-0002/0003/0004 details, `specs/technical/`.

## Decision

One app under `game/`, four layers:

- **L1 Presentation** — board, UI, touch, audio; L2 only.
- **L2 Session** — mode pick, Shared game, Puzzle stream, clocks; L3 and L4 only.
- **L3 Domain** — chess legality, end conditions, Elo, puzzle pick; no dependencies or outer-layer types.
- **L4 Edge** — persist, advice, assets, playtest seams; external I/O only.

Cross-layer calls use typed contracts (`CTR-*`); upward flow uses callbacks — never upward, bidirectional, or skip-layer imports. State fields have one owner: rules in L3, session in L2, saves via L4. The client never embeds Stockfish (ADR-0002).

## Reasoning

1. **Instant play**: in-process layers keep moves on-device; Advice behind L4 cannot block them.
2. **Observability / playtest Must tools**: seams and telemetry live in L4.
3. **Reliability**: single-writer state, downward-only imports — L3 headless-testable (ADR-0004).

Costs accepted: contract boilerplate; upward flows are events; the advice split adds an operational boundary.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Flat Godot scene tree | No ownership; seams tangle (driver 2) |
| Entity-component-system | Overkill for one board (driver 3) |
| Server-authoritative rules | Moves would wait on network (driver 1) |

## Non-functional requirements

### Quality expectations

| Category | Effect | How met or limited |
|----------|--------|--------------------|
| Performance | No effect | In-process (ADR-0001) |
| Load time / latency | No effect | ADR-0001, ADR-0005 |
| Reliability | Affects | Single-owner state; quality.md soak |
| Observability | Affects | Telemetry behind L4 ports only (quality.md) |
| Save durability | Affects | Saves via L4 persist port only (quality.md) |
| Accessibility | No effect | ADR-0001 |
| Localization | No effect | `GS.locale` is design state |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Not relevant — no third-party code |
| Maintainability | Engine upgrades touch L1/L4; rules stay in L3 |
| Testability | L3 pure and headless-testable (ADR-0004) |
| Portability | Web (ADR-0001); platform code in L4 only |
| Security and privacy | Only advice leaves device (ADR-0002) |

## Imposes

None.

## Validation

| Check | Method | When |
|-------|--------|------|
| Layer edges | Review rule: no upward/skip-layer/bidirectional imports | Every review |
| Domain headless tests | Automated: L3 runs Headless (ADR-0004) | Every build |
