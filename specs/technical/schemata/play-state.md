# Schema: Play state

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity — in-memory session play
- **Owner**: [`CMP-chess-rules`](../components/chess-rules.md)
- **Serves**: Shared game; Puzzle stream; Advice marks
- **Informed by**: [`fields-play`](../../design/game-state/fields-play.md); F-move-advice state
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | position | board occupancy + side to move | yes | Domain-owned |
| F2 | castling_ep | castling rights + en passant square | yes | Per design |
| F3 | clocks | white/black remaining ms or none | no | Timed Shared only |
| F4 | advice_best_move | from/to or none | no | Cleared per F-move-advice |
| F5 | advice_eval | int cp from White or none | no | With F4 |
| F6 | game_ended | bool + reason | yes | End-conditions |
| F7 | mode | shared / puzzle | yes | Session |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | Only Domain mutates F1 F2 via [`CTR-local-move`](../contracts/local-move.md) |
| I2 | F4/F5 never gate F1 updates |
| I3 | Only side-to-move clock runs when timed |
| I4 | Only the active L2 session mutates F3, F6, F7; F4/F5 are written only by [`CMP-advice-client`](../components/advice-client.md) (never gating position, per I2) |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | Session start | Initial position / puzzle deal |
| L2 | update | Move / clock / advice | Fields above |
| L3 | destroy | Leave session | Drop ephemeral state |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-persist-doc`](persist-doc.md) | 0..1 | Elo/Last mode separate; not embedded |

## Diagram

None — flat session object.

## Persistence

N/A — ephemeral play state; durable fields live in [`SCH-persist-doc`](persist-doc.md) / [`persistence.md`](../persistence.md).
