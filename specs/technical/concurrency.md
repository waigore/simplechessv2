# Concurrency

Authoring rules: [`.agents/specs/rules/technical/concurrency.md`](../../.agents/specs/rules/technical/concurrency.md).

- **Serves**: Instant play ([`CMP-advice-client`](components/advice-client.md) R5, [`CTR-advice-stream`](contracts/advice-stream.md) G1); Performance 60 fps; deal reads that never block a frame ([`CTR-puzzle-catalog-read`](contracts/puzzle-catalog-read.md) G3)
- **Informed by**: [ADR-0001](../adr/decisions/0001-godot-engine.md), [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md); clocks in Shared game
- **ADRs**: [ADR-0001](../adr/decisions/0001-godot-engine.md), [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md)

## Update loops

| ID | Loop | Cadence | Runs | Owns |
|----|------|---------|------|------|
| U1 | Frame | Display frame | Presentation render; input sample; piece motion | L1 presentation state |
| U2 | Session tick | Frame or fixed idle | Clock countdown when timed; session orchestration | Shared clocks; session flags |
| U3 | Advice I/O | Async network callbacks | Apply streamed eval/best-move; cancel | Advice overlay fields only |
| U4 | Catalog deal I/O | Async network callbacks | Request one deal record through [`CTR-puzzle-catalog-read`](contracts/puzzle-catalog-read.md) O1 ([`CatalogDealClient`](../../game/catalog_deal_client.gd), worker thread); hand the one record to [`CMP-puzzle-session`](components/puzzle-session.md); drop it on leave | Puzzle attempt create only; never a move, a frame, or `GS.playerElo` |

## Ownership

| ID | Data or resource | Writer | Readers | Rule |
|----|------------------|--------|---------|------|
| O1 | [`SCH-play-state`](schemata/play-state.md) position and turn | [`CMP-chess-rules`](components/chess-rules.md) via session | Presentation; Advice client | Single writer; Advice never mutates position |
| O2 | Clocks | [`CMP-shared-game-session`](components/shared-game-session.md) | Presentation | Only side-to-move clock runs |
| O3 | Advice best-move / eval | [`CMP-advice-client`](components/advice-client.md) | Presentation | Cleared on move/end/Off/offline |
| O4 | Persist document | [`CMP-persist-store`](components/persist-store.md) | Session router; puzzle session | Whole-document replace |
| O5 | In-flight deal read and its one record | Catalog deal I/O (U4) | [`CMP-puzzle-session`](components/puzzle-session.md) | At most one record at a time; a failed read writes nothing |
| O6 | `GS.playerElo` and `GS.recentSolved` | [`CMP-puzzle-progression`](components/puzzle-progression.md) via [`CTR-puzzle-progress`](contracts/puzzle-progress.md) O1 | [`CMP-puzzle-session`](components/puzzle-session.md) (commits the returned values); Presentation | Single writer in L3; the session commits, never computes; a Shared game and leaving the stream never write them |

## Synchronization

| ID | Mechanism | Between | Purpose |
|----|-----------|---------|---------|
| S1 | Queue advice updates onto U1/U2 | U3 → session | Apply marks without hitching the move path |
| S2 | Cancel in-flight advice on local move | apply-local-move → U3 | Instant play; start new eval if still allowed |
| S3 | Queue the deal outcome onto U2 | U4 → U2 | Board stays playable while a deal is in flight (G3); a failure deals nothing |
| S4 | Retire an in-flight deal read on leave | puzzle leave → U4 | A record fetched for a stream the player left never deals |

## Diagram

```mermaid
flowchart LR
  U1[U1 Frame]
  U2[U2 Session tick]
  U3[U3 Advice I/O]
  U4[U4 Catalog deal I/O]
  U3 -.->|queued marks| U2
  U4 -.->|one record or a failed read| U2
  U2 --> U1
```
