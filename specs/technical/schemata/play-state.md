# Schema: Play state

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: entity — in-memory session play
- **Owner**: [`CMP-shared-game-session`](../components/shared-game-session.md) (Shared) and [`CMP-puzzle-session`](../components/puzzle-session.md) (Puzzle) create and destroy it; [`CMP-chess-rules`](../components/chess-rules.md) is its `F1` / `F2` writer
- **Serves**: Shared game; Puzzle stream; Advice marks
- **Informed by**: [`fields-play`](../../design/game-state/fields-play.md); [Run](../../design/glossary/session.md) scope; F-move-advice state
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | position | board occupancy + side to move | yes | Domain-owned |
| F2 | castling_ep | castling rights + en passant square | yes | Per design |
| F3 | clocks | white/black remaining ms or none | no | Timed Shared only |
| F4 | advice_best_move | from/to or none | no | Cleared per F-move-advice |
| F5 | advice_eval | int cp from White or none | no | With F4 |
| F6 | game_ended | bool + reason | yes | End-conditions (`END.*` id) |
| F7 | mode | shared / puzzle | yes | Session |
| F8 | repetition_history | occurrence keys (position, side, castling, en passant) | yes | `END.D3`; Domain; clear only on new run |
| F9 | fifty_move_count | int half-moves since capture or pawn | yes | `END.D4`; Domain; clear on capture, pawn move, or new run |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | Only Domain mutates F1 F2 F8 F9 via [`CTR-local-move`](../contracts/local-move.md) |
| I2 | F4/F5 never gate F1 updates |
| I3 | Only side-to-move clock runs when timed |
| I4 | Only the active L2 session mutates F3, F6, F7; F4/F5 are written only by [`CMP-advice-client`](../components/advice-client.md) (never gating position, per I2) |
| I5 | F8 lasts the game; F9 is 0–100 and resets on capture, pawn move, or new run |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | Beginning a Shared game or a puzzle attempt by its L2 session (Owner) | Initial position / puzzle deal |
| L2 | update | Move / clock / advice | Fields above |
| L3 | destroy | Leaving that Shared game or puzzle attempt | Drop ephemeral state |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-persist-doc`](persist-doc.md) | 0..1 | Elo/Last mode separate; not embedded |

## Diagram

None — flat session object.

## Persistence

N/A — ephemeral play state; durable fields live in [`SCH-persist-doc`](persist-doc.md) / [`persistence.md`](../persistence.md).
