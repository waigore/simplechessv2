# Component: Advice backend

Authoring rules: [`.agents/specs/rules/technical/components.md`](../../../.agents/specs/rules/technical/components.md).

- **Layer**: Outside client stack (M2 only)
- **Module**: M2 `advice-backend`
- **Serves**: Optional Stockfish Advice; Instant play (client never waits)
- **Informed by**: [F-move-advice](../../design/features/move-advice.md); `CFG.ADVICE_TIME_MS`
- **ADRs**: [ADR-0002](../../adr/decisions/0002-stockfish-advice-backend.md), [ADR-0010](../../adr/decisions/0010-advice-backend-stack.md), [ADR-0011](../../adr/decisions/0011-local-stockfish-invocation.md), [ADR-0012](../../adr/decisions/0012-advice-backend-gpl-compliance.md)

## Responsibilities

| ID | Responsibility |
|----|----------------|
| R1 | Be the sole UCI peer to Stockfish |
| R2 | Accept a position from the client and stream eval/best-move |
| R3 | Stop search by `CFG.ADVICE_TIME_MS` (2000) or on client cancel |
| R4 | Never expose Stockfish or UCI endpoints to the browser |
| R5 | Are a separate Python server from the frontend ([ADR-0010](../../adr/decisions/0010-advice-backend-stack.md)) |
| R6 | Accept a request only when its API key matches the configured key |
| R7 | Invoke Stockfish locally on this same Python server. That UCI link is not a network connection ([ADR-0011](../../adr/decisions/0011-local-stockfish-invocation.md)) |
| R8 | Ship no Stockfish binary: the operator installs and runs Stockfish as a separate program. Record Stockfish's GPL text, credits, exact version, and source URL beside the server, and keep its notices intact ([ADR-0012](../../adr/decisions/0012-advice-backend-gpl-compliance.md)) |
| R9 | Serve no player-facing copy and persist no player state, so Localization and Save durability impose nothing on it |

## Communication

| ID | Peer | Direction | Via contract | Notes |
|----|------|-----------|--------------|-------|
| C1 | [`CMP-advice-client`](advice-client.md) | both | [`CTR-advice-stream`](../contracts/advice-stream.md) | Network; provider of stream |
| C2 | Stockfish | both | Local UCI, same server ([ADR-0011](../../adr/decisions/0011-local-stockfish-invocation.md)) | Not a network connection. Not a client contract |

## Owns / mutates

| Schema or state | Access |
|-----------------|--------|
| In-flight search / stream session | write |
| [`SCH-advice-update`](../schemata/advice-update.md) payloads | emit |

## Diagram

```mermaid
flowchart LR
  A[CMP-advice-client]
  B[CMP-advice-backend]
  SF[Stockfish]
  A -->|CTR-advice-stream| B
  B -->|local UCI| SF
```

## Failure / concurrency / persistence

[`failures.md`](../failures.md) T1; [`concurrency.md`](../concurrency.md) U3; [`SEQ-advice-stream`](../sequences/advice-stream.md). Licensing constraint: [ADR-0012](../../adr/decisions/0012-advice-backend-gpl-compliance.md) — unbundled invocation, so an operator that conveys Stockfish with the backend makes the GPL source offer for the binary it conveys (R8).
