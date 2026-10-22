# ADR-0002 non-functional requirements and validation

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0002](../0002-stockfish-advice-backend.md).

## Context

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md). This file holds the non-functional tables and the validation checks.

## Purpose

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md).

## Decision

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md).

## Reasoning

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md).

## Rejected alternatives

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | quality.md Performance: 60 fps with no hitch longer than one frame during a move. Advice I/O is queued off the move and render path ([concurrency.md](../../../technical/concurrency.md) U3, S1) |
| Load time / latency | Affects | quality.md Load time / latency: advice ready within 2000 ms when On and online ([CTR-advice-stream](../../../technical/contracts/advice-stream.md) G2), and never delays a local move (G1) |
| Reliability | Affects | quality.md Reliability: crash-free sitting. Backend failure is the declared advice unavailability ([FAIL.T1](../../../technical/failures.md)) that clears advice while play continues |
| Observability | Affects | quality.md Observability: advice timing and errors are logged with story IDs and outcomes ([`TEL.4`](../../../playtest/tools.md), [`TEL.5`](../../../playtest/tools.md)) |
| Save durability | No effect | Advice is never persisted |
| Accessibility | No effect | Marks are view and UX behavior |
| Localization | No effect | No new player-facing copy; advice copy is UX |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Stockfish is GPL; the compliance approach is tracked outside this ADR and changes no part of this decision |
| Maintainability | The backend isolates engine upgrades from the client |
| Testability | Stream contracts; the client mocks the backend; the backend is tested against the same wire |
| Portability | Web client; the deploy and host stay open |
| Security and privacy | Positions are sent only while Advice On; the transport is TLS with no accounts (ADR-0010) |

## Imposes

N/A — stated in [ADR-0002](../0002-stockfish-advice-backend.md).

## Validation

| Check | Method | When |
|-------|--------|------|
| Move while advice in flight | F-move-advice R6 automated test against a simulated peer, plus the playtest step | Every release |
| Stream stops by 2000 ms | quality.md Load time / latency: timed advice readiness (G2) | Every release |
| No client Stockfish endpoint | Review / architecture test over the Web export (module M1 boundary) | Every release |
| Backend failure clears advice | Automated test ([FAIL.T1](../../../technical/failures.md)) | Every release |
| Advice timing/errors logged | quality.md Observability log check | Every release |
| No move-path hitch | quality.md Performance: frame-time capture during piece movement | Every release |
