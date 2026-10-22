# Persistence

Authoring rules: [`.agents/specs/rules/technical/persistence.md`](../../.agents/specs/rules/technical/persistence.md).

- **Serves**: Save durability; Reliability; [PRG](../design/progression.md); `GS.playerElo` `GS.lastMode` `GS.recentSolved`
- **Informed by**: [`fields-persist`](../design/game-state/fields-persist.md); quality Save durability
- **ADRs**: [ADR-0003](../adr/decisions/0003-localstorage-persistence.md)

## Durable vs ephemeral

| ID | Data | Durability | Owner |
|----|------|------------|-------|
| D1 | Player Elo, Last mode, recent solved IDs | Durable across sittings until origin storage cleared | [`CMP-persist-store`](components/persist-store.md) |
| D2 | Play position, clocks, advice marks, in-session options | Ephemeral; lost on quit/reload | Session components |
| D3 | Mode-pick UI selection before commit | Ephemeral until Last mode written | [`CMP-session-router`](components/session-router.md) |

## Save mapping

| ID | Schema / field | Stored as | When written | When loaded |
|----|----------------|-----------|--------------|-------------|
| M1 | [`SCH-persist-doc`](schemata/persist-doc.md) whole document | `localStorage` key `simplechessv2.persist.v1` | After successful Elo/Last mode/recentSolved commit; a failed write leaves the prior commit intact ([`SCH-persist-doc.I3`](schemata/persist-doc.md)) | Cold open before mode pick ready |
| M2 | `GS.playerElo` ([`SCH-persist-doc.F2`](schemata/persist-doc.md)) | Number in document | Puzzle result commit (W1 / fail path per design). Wave 2 slot inside version `1` ([`PRG.P1`](../design/progression.md) / [`PRG.A1`](../design/progression.md), [`PRG.M1`](../design/progression.md)) | M1 load |
| M3 | `GS.lastMode` | Enum string in document | Mode pick enters Shared or Puzzle | M1 load |
| M4 | `GS.recentSolved` ([`SCH-persist-doc.F4`](schemata/persist-doc.md)) | Array ≤ `CFG.ELO_RECENT_WINDOW` ([`CFG.T7`](configuration.md)) PuzzleIds | Append on solve; trim to `CFG.ELO_RECENT_WINDOW`. Wave 2 slot inside version `1` ([`PRG.P3`](../design/progression.md), [`PRG.M1`](../design/progression.md)) | M1 load |

## Migration

| ID | From → to | Change | Strategy |
|----|-----------|--------|----------|
| G1 | version `1` → version `1` | [`SCH-persist-doc.F2`](schemata/persist-doc.md) `player_elo` and [`SCH-persist-doc.F4`](schemata/persist-doc.md) `recent_solved` are already reserved for Wave 2 | No document-version bump; Wave 2 commits them per [`PRG.M1`](../design/progression.md) |

## Diagram

None — single whole-document replace.
