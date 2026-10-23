# Component: Puzzle session

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: L2 Session
- **Module**: M1 `client`
- **Serves**: Puzzle stream; Elo progression; recent solved
- **Informed by**: [`L-puzzle-stream`](../../design/loops/puzzle-stream.md); [`F-puzzle-catalog`](../../design/features/puzzle-catalog.md); [DIF](../../design/difficulty.md); [PRG](../../design/progression.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md), [ADR-0003](../../adr/decisions/0003-localstorage-persistence.md), [ADR-0006](../../adr/decisions/0006-layered-client-architecture.md), [ADR-0008](../../adr/decisions/0008-puzzle-catalog-storage.md), [ADR-0013](../../adr/decisions/0013-puzzle-catalog-api.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Deal the next puzzle per DIF.Y1 from the host catalog, reading one record through [`CTR-puzzle-catalog-read`](../contracts/puzzle-catalog-read.md) and offering it to [`CMP-puzzle-progression`](puzzle-progression.md) O2; the read runs off the move path and a failed or non-selecting record deals nothing (C5) |
| R2 | Accept puzzle moves via chess-rules, judging each against the required sequence through [`CTR-puzzle-progress`](../contracts/puzzle-progress.md) O3; detect solve vs wrong move |
| R3 | On result, take the updated Elo and recentSolved from [`CMP-puzzle-progression`](puzzle-progression.md) O1 and commit them via persist; own no Elo, recent-solved, or pick arithmetic of its own |
| R4 | Never enable Advice |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-chess-rules`](chess-rules.md) | calls | [`CTR-local-move`](../contracts/local-move.md) | Puzzle sequence checks |
| C2 | [`CMP-presentation`](presentation.md) | both | [`CTR-presentation`](../contracts/presentation.md) | Board and feedback: O1 up; E2–E3 down |
| C3 | [`CMP-persist-store`](persist-store.md) | calls | [`CTR-persist-document`](../contracts/persist-document.md) | Elo / recentSolved commit of the values O1 returned |
| C4 | [`CMP-session-router`](session-router.md) | listens | internal | Enter / leave stream |
| C5 | [`CMP-catalog-service`](catalog-service.md) | calls | [`CTR-puzzle-catalog-read`](../contracts/puzzle-catalog-read.md) | Deal read: Elo, recent ids, key; one record or a failed read (R1). Off the move path (`concurrency.md` U4) |
| C6 | [`CMP-puzzle-progression`](puzzle-progression.md) | calls | [`CTR-puzzle-progress`](../contracts/puzzle-progress.md) | O1 score, O2 pick, O3 sequence; Domain owns the policy ([`LAY.L3`](../layers.md)) |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| [`SCH-puzzle-attempt`](../schemata/puzzle-attempt.md) | write |
| `GS.playerElo` ([`SCH-persist-doc`](../schemata/persist-doc.md) `F2`), `GS.recentSolved` (via persist) | write on result: the Domain-returned values |

## Diagram

```mermaid
flowchart LR
  Q[CMP-puzzle-session]
  C[CMP-chess-rules]
  P[CMP-persist-store]
  V[CMP-presentation]
  D[CMP-catalog-service]
  G[CMP-puzzle-progression]
  Q --> C
  Q --> P
  Q -->|CTR-puzzle-progress| G
  Q -->|CTR-presentation| V
  Q -->|CTR-puzzle-catalog-read| D
```

## Failure / concurrency / persistence

[`persistence.md`](../persistence.md) M2 M4; [`failures.md`](../failures.md) T2 M2; [`SEQ-puzzle-result-commit`](../sequences/puzzle-result-commit.md).
