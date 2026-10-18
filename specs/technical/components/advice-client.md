# Component: Advice client

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: L4 Edge
- **Module**: M1 `client`
- **Serves**: Optional Stockfish Advice; Instant play
- **Informed by**: [F-move-advice](../../design/features/move-advice.md); `CFG.ADVICE_TIME_MS`
- **ADRs**: [ADR-0002](../../adr/decisions/0002-stockfish-advice-backend.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Talk only to advice-backend (M2); never to Stockfish |
| R2 | Request stream for current position when On and online |
| R3 | Apply streamed best-move/eval onto play-state advice fields |
| R4 | Cancel and clear on move, end, Off, offline, or leave Shared |
| R5 | Never block local move apply |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-shared-game-session`](shared-game-session.md) | both | [`CTR-advice-stream`](../contracts/advice-stream.md) | Start/stop |
| C2 | advice-backend (M2) | calls | [`CTR-advice-stream`](../contracts/advice-stream.md) | Network stream |
| C3 | [`CMP-presentation`](presentation.md) | calls | internal | Marks via session state |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| `GS.adviceBestMove` `GS.adviceEval` | write |
| Position | read only |

## Diagram

```mermaid
flowchart LR
  S[CMP-shared-game-session]
  A[CMP-advice-client]
  B[M2 advice-backend]
  S --> A
  A --> B
```

## Failure / concurrency / persistence

[`concurrency.md`](../concurrency.md) U3 S1 S2; [`failures.md`](../failures.md) T1 M1.
