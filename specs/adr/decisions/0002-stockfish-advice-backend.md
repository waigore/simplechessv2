# ADR-0002: Stockfish advice via backend

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; Cafe calm; definition async time-capped Stockfish; F-move-advice R2–R9; CFG.ADVICE_TIME_MS; [quality.md](../../definition/quality.md) Performance, Load time / latency, Reliability, Observability; ADR-0001

## Context

Advice needs Stockfish when online and On. The definition makes Stockfish optional, asynchronous, and time-capped, and a local move never waits on the network. quality.md sets this decision's targets: 60 frames per second with no hitch longer than one frame (Performance), advice within 2000 ms that never delays a move (Load time / latency), a crash-free sitting (Reliability), and timing and errors in logs (Observability).

## Purpose

How does the client get streamed advice without coupling to Stockfish or blocking moves?

In scope: the client–engine boundary, stream ownership, and the non-blocking guarantee. Out of scope: host vendor, deploy, and wire schema.

## Decision

**Stockfish runs only on the server.** An **advice backend** is the sole UCI peer. The client talks **only to that backend**, never to Stockfish, and its shape is fixed by [CTR-advice-stream](../../technical/contracts/advice-stream.md). The backend is a separate Python server ([ADR-0010](0010-advice-backend-stack.md)) that invokes Stockfish locally ([ADR-0011](0011-local-stockfish-invocation.md)).

Advice runs only when On and online; the search cap is `CFG.ADVICE_TIME_MS` ([F-move-advice](../../design/features/move-advice.md)). **A local move never waits** on advice traffic (F-move-advice R6).

## Reasoning

1. Instant play (F-move-advice R6, I1) forbids gating a move on the engine, and quality.md Load time / latency pairs that with 2000 ms advice. A queued, non-blocking stream meets both, and advice never acts as the other seat (vision non-goal: a computer opponent).
2. Cafe calm (vision) keeps advice an optional, quiet hint; every failure clears advice and play continues (F-move-advice R9; [FAIL.T1](../../technical/failures.md)).
3. The definition's time-capped, asynchronous Stockfish constraint is met by server-only UCI, keeping the engine off the browser as ADR-0001 and quality.md Performance require.
4. Streaming matches the eval experience and the cap.
5. Leaving the host open keeps the boundary stable; a deploy change needs no new ADR.

Costs accepted: a server dependency for optional advice; if the backend is unavailable, advice is too, and the game continues (Reliability).

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Stockfish.wasm in the browser | Drivers 1 and 3: engine work competes with the 60 fps frame budget, and it puts UCI in the client |
| Client UCI to Stockfish | Driver 3: the frontend must never talk to Stockfish |
| Single HTTP response, no stream | Driver 4: a deeper eval is what the streamed experience and the cap deliver; one answer cannot deepen |

## Non-functional requirements

Quality rows, engineering rows, and validation: [non-functional requirements](0002-stockfish-advice-backend/non-functional.md).

### Quality expectations

N/A — in the split file.

### Engineering qualities

N/A — in the split file.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

Every check runs every release; one proves the decision — a simulated backend failure clears advice while the local move completes unblocked.
