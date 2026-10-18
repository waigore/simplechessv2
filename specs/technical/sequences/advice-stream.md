# Sequence: Advice stream

Authoring rules: [`.agents/specs/rules/technical/sequences.md`](../../../.agents/specs/rules/technical/sequences.md).

- **Trigger**: Shared game needs Advice for the side to move (On + online)
- **Participants**: [`CMP-shared-game-session`](../components/shared-game-session.md), [`CMP-advice-client`](../components/advice-client.md), [`CMP-advice-backend`](../components/advice-backend.md), [`CMP-presentation`](../components/presentation.md)
- **Contracts used**: [`CTR-advice-stream`](../contracts/advice-stream.md)
- **Serves**: F-move-advice; streamed eval to `CFG.ADVICE_TIME_MS`
- **Informed by**: requirement note — server Stockfish, time-capped stream, moves never wait
- **ADRs**: [ADR-0002](../../adr/decisions/0002-stockfish-advice-backend.md)

## Steps

| ID | From | To | Via | Action / message |
|----|------|----|-----|------------------|
| S1 | shared-game | advice-client | O1 | start(position) |
| S2 | advice-client | advice-backend | network | Send position |
| S3 | advice-backend | Stockfish | UCI | Search (M2 only) |
| S4 | advice-backend | advice-client | E1 | Stream updates |
| S5 | advice-client | shared-game | internal | Write best-move/eval |
| S6 | shared-game | presentation | internal | Show marks |
| S7 | advice-backend | advice-client | E2 | End at cap or cancel |

## Branches

| ID | Condition | Next steps | Outcome |
|----|-----------|------------|---------|
| B1 | Offline / error | Fail after S2 | Clear marks; play continues |
| B2 | Local move during stream | [`SEQ-apply-local-move`](apply-local-move.md) S5 | Cancel; optional restart |
| B3 | Advice Off / leave | O2 from session | Clear; stop |

## Postconditions

- Eval/best-move reflect side to move only while R2 holds.
- No step blocks [`SEQ-apply-local-move`](apply-local-move.md).

## Diagram

```mermaid
sequenceDiagram
  participant S as shared-game
  participant A as advice-client
  participant B as advice-backend
  S->>A: S1 start
  A->>B: S2 position
  B-->>A: S4 updates
  A->>S: S5 fields
  B-->>A: S7 ended
```
