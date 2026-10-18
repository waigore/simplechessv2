# Sequence: Shared end and new session

Authoring rules: [`.agents/specs/rules/technical/sequences.md`](../../../.agents/specs/rules/technical/sequences.md).

- **Trigger**: Shared game reaches an end condition (`GS.gameEnded`)
- **Participants**: [`CMP-shared-game-session`](../components/shared-game-session.md), [`CMP-advice-client`](../components/advice-client.md), [`CMP-presentation`](../components/presentation.md), [`CMP-session-router`](../components/session-router.md)
- **Contracts used**: [`CTR-advice-stream`](../contracts/advice-stream.md)
- **Serves**: Shared result UX; new session after end ([two-player-game K3](../../design/loops/two-player-game.md))
- **Informed by**: end-conditions; UX shared-result
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md), [ADR-0002](../../adr/decisions/0002-stockfish-advice-backend.md)

## Steps

| ID | From | To | Via | Action / message |
|----|------|----|-----|------------------|
| S1 | shared-game | chess-rules / self | internal | Observe end signal; set game_ended |
| S2 | shared-game | advice-client | CTR-advice-stream.O2 | cancel + clear |
| S3 | shared-game | presentation | internal | Show shared-result |
| S4a | presentation | session-router | internal | Play again → shared-setup |
| S4b | presentation | session-router | internal | Stop → mode-pick |
| S5 | session-router | shared-game | internal | If Play again: new Shared session (setup unlocked) |

## Branches

| ID | Condition | Next steps | Outcome |
|----|-----------|------------|---------|
| B1 | Play again | S4a → S5 | Fresh Shared setup; no Elo change |
| B2 | Stop | S4b | Mode pick; Last mode already committed |

## Postconditions

- Advice cleared before result UI.
- No durable Elo write from Shared end.

## Diagram

```mermaid
sequenceDiagram
  participant S as shared-game
  participant A as advice-client
  participant V as presentation
  participant R as session-router
  S->>A: S2 cancel
  S->>V: S3 result
  V->>R: S4a or S4b
  R->>S: S5 new session if again
```
