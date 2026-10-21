# Sequence: Puzzle result commit

Authoring rules: [`.agents/specs/rules/technical/sequences.md`](../../../.agents/specs/rules/technical/sequences.md).

- **Trigger**: Puzzle attempt reaches solved (W1) or failure (L4 / L5)
- **Participants**: [`CMP-puzzle-session`](../components/puzzle-session.md), [`CMP-persist-store`](../components/persist-store.md), [`CMP-presentation`](../components/presentation.md)
- **Contracts used**: [`CTR-persist-document`](../contracts/persist-document.md), [`CTR-presentation`](../contracts/presentation.md)
- **Serves**: Save durability; DIF Elo; recent solved ≤20
- **Informed by**: end-conditions W1 L4 L5; [PRG](../../design/progression.md); [`SCH-puzzle-attempt`](../schemata/puzzle-attempt.md)
- **ADRs**: [ADR-0003](../../adr/decisions/0003-localstorage-persistence.md)

## Steps

| ID | From | To | Via | Action / message |
|----|------|----|-----|------------------|
| S1 | puzzle-session | puzzle-session | internal | Compute Elo delta from outcome |
| S2 | puzzle-session | puzzle-session | internal | If W1, append puzzle_id to recentSolved; trim to 20 |
| S3 | puzzle-session | persist-store | CTR-persist-document.O2 | commit full document |
| S4 | persist-store | puzzle-session | CTR-persist-document.O2 return | Success or fail signal |
| S5 | puzzle-session | presentation | CTR-presentation.E2 E3 | Feedback; deal next or show fail then next per design |

## Branches

| ID | Condition | Next steps | Outcome |
|----|-----------|------------|---------|
| B1 | Commit success | S5 | Durable Elo / recentSolved updated |
| B2 | Commit fail | S5 with in-memory values; [`FAIL.T2`](../failures.md) | Prior document intact; sitting may diverge |

## Postconditions

- Prior durable document unchanged if S3 failed.
- Attempt outcome recorded in session before next deal.

## Diagram

```mermaid
sequenceDiagram
  participant Q as CMP-puzzle-session
  participant P as CMP-persist-store
  participant V as CMP-presentation
  Q->>Q: S1 Elo
  Q->>Q: S2 recentSolved
  Q->>P: S3 commit
  P-->>Q: S4 result
  Q->>V: S5 feedback and next deal
```
