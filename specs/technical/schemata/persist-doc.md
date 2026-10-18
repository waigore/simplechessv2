# Schema: Persist document

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: DTO — durable JSON for this origin
- **Owner**: [`CMP-persist-store`](../components/persist-store.md)
- **Serves**: Save durability; PRG; mode resume cue
- **Informed by**: [`fields-persist`](../../design/game-state/fields-persist.md)
- **ADRs**: [ADR-0003](../../adr/decisions/0003-localstorage-persistence.md)

## Fields

| ID | Field | Type / shape | Required | Notes |
|----|-------|--------------|----------|-------|
| F1 | version | int | yes | Single version `1` |
| F2 | player_elo | number | yes | `GS.playerElo` |
| F3 | last_mode | `shared` / `puzzle` / `none` | yes | `GS.lastMode` |
| F4 | recent_solved | string[] | yes | Puzzle IDs; max 20; newest last |

Exact `localStorage` key string: TBD — which key name for this game's document?

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | `len(F4) ≤ 20` |
| I2 | Commit replaces the whole document |
| I3 | Failed write does not mutate stored bytes |

## Lifecycle

| ID | Phase | Who | What changes |
|----|-------|-----|--------------|
| L1 | create | First successful commit or default seed | New document |
| L2 | update | commit | Whole replace |
| L3 | destroy | Origin storage cleared by user | Gone |

## Relationships

| Related schema | Cardinality | Notes |
|----------------|-------------|-------|
| [`SCH-play-state`](play-state.md) | none | Ephemeral play not stored |

## Diagram

None.

## Persistence

[`persistence.md`](../persistence.md) M1–M4; [`CTR-persist-document`](../contracts/persist-document.md).
