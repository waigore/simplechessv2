# Schema: Advice update

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: DTO — one streamed advice tick
- **Owner**: [`CMP-advice-backend`](../components/advice-backend.md) (emit); [`CMP-advice-client`](../components/advice-client.md) (apply)
- **Serves**: F-move-advice marks and eval
- **Informed by**: [F-move-advice](../../design/features/move-advice.md) R4 R5 R7
- **ADRs**: [ADR-0002](../../adr/decisions/0002-stockfish-advice-backend.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | best_from | square | yes | Side to move |
| F2 | best_to | square | yes | Side to move |
| F3 | eval_cp | int | yes | Centipawns from White's view |
| F4 | depth_or_time | optional hint | no | Deepening signal; TBD — which optional depth/time fields ship on the wire? |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | Applies only while Shared Advice On and online |
| I2 | Best move is for current side to move only |
| I3 | Stale updates after cancel are dropped |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | Backend stream tick | New DTO |
| L2 | update | Client applies to play-state advice fields | `GS.adviceBestMove` / eval |
| L3 | destroy | Cancel / end / Off / offline | Fields cleared |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-play-state`](play-state.md) | many→one | Advice fields only |

## Diagram

None — flat DTO.

## Persistence

N/A — ephemeral stream payload.
