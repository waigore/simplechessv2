# Sequence: Cold open

Authoring rules: [`.agents/specs/rules/technical/sequences.md`](../../../.agents/specs/rules/technical/sequences.md).

- **Trigger**: Player opens the Web game
- **Participants**: [`CMP-asset-resolver`](../components/asset-resolver.md), [`CMP-persist-store`](../components/persist-store.md), [`CMP-session-router`](../components/session-router.md), [`CMP-presentation`](../components/presentation.md)
- **Contracts used**: [`CTR-persist-document`](../contracts/persist-document.md)
- **Serves**: Load time ≤3 s to playable; mode pick
- **Informed by**: quality Load time; [`ACC.G1`](../../assets/access.md)
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md), [ADR-0003](../../adr/decisions/0003-localstorage-persistence.md), [ADR-0005](../../adr/decisions/0005-asset-catalog-roots.md)

## Steps

| ID | From | To | Via | Action / message |
|----|------|----|-----|------------------|
| S1 | boot | asset-resolver | internal | Preload Boot asset IDs |
| S2 | boot | persist-store | CTR-persist-document.O1 | Load document or defaults |
| S3 | persist-store | session-router | internal | Provide Elo / Last mode |
| S4 | session-router | presentation | internal | Show mode pick when Boot ready |

## Branches

| ID | Condition | Next steps | Outcome |
|----|-----------|------------|---------|
| B1 | Persist corrupt/missing | S2 defaults → S3 → S4 | Mode pick with Elo start |
| B2 | Boot asset fail | AST.R3 handling → S4 if possible | Degraded visuals; session continues |

## Postconditions

- Mode pick is interactive without waiting on Advice or Play assets.
- Committed Elo and Last mode are available to sessions.

## Diagram

```mermaid
sequenceDiagram
  participant Boot
  participant AR as asset-resolver
  participant PS as persist-store
  participant SR as session-router
  Boot->>AR: S1 Boot preload
  Boot->>PS: S2 load
  PS->>SR: S3 committed fields
  SR->>SR: S4 mode pick
```
