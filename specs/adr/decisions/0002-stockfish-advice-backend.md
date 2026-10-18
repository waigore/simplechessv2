# ADR-0002: Stockfish advice via backend

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; definition async time-capped Stockfish; F-move-advice R2–R9; CFG.ADVICE_TIME_MS; Load time / latency; Observability; ADR-0001

## Context

Advice needs Stockfish when online and On. Definition forces: advice optional, asynchronous, time-capped; a local move never waits on the network.

## Purpose

How does the client get streamed advice without coupling to Stockfish or blocking moves?

In scope: boundary, stream ownership, time cap, non-blocking. Out of scope: host vendor, deploy, wire schema.

## Decision

**Stockfish runs only on the server.** An **advice backend** is the sole UCI peer. The client talks **only to that backend** (never to Stockfish).

When Advice is On and online, the client sends the position; the backend streams eval/best-move until **`CFG.ADVICE_TIME_MS` (2000)**. Advice Off, offline, move complete, or game end stops eval and clears advice ([F-move-advice](../../design/features/move-advice.md)). **A local move never waits** on advice traffic.

## Reasoning

1. Instant play and F-move-advice R6 forbid gating moves on the engine.
2. Backend-only UCI keeps Stockfish off the client.
3. Streaming matches the eval experience and 2000 ms cap.
4. Host left open; deploy can change without a new ADR.

Costs accepted: server dependency; operating a backend for optional advice.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Stockfish.wasm in browser | Conflicts with server-Stockfish; hitch risk |
| Client UCI to Stockfish | Frontend must never talk to Stockfish |
| Single HTTP, no stream | Weaker than streaming |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | Advice I/O must not hitch moves |
| Load time / latency | Affects | Advice ≤2000 ms when On/online; never delays a move |
| Reliability | Affects | Offline/backend failure clears advice; play continues |
| Observability | Affects | Expose advice timing/errors for playtests |
| Save durability | No effect | — |
| Accessibility | No effect | Marks are view/UX |
| Localization | No effect | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Stockfish GPL; comply when shipping binary |
| Maintainability | Backend isolates engine upgrades |
| Testability | Stream contracts; client mocks backend |
| Portability | Web client; deploy open |
| Security and privacy | Positions when Advice On; TLS; no accounts |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Move while advice in flight | F-move-advice R6 test/playtest | Every release |
| Stream stops by 2000 ms | quality.md timed advice | Every release |
| No client Stockfish endpoint | Review/architecture test | Every release |
| Backend failure clears advice | Automated test | Every release |
| Advice timing/errors logged | quality.md log check | Every release |
