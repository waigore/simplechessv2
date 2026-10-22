# Protocol: Shared play screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-play`
- **Environment**: Headless and Graphical
- **Cites**: `UI-shared-play.US1`, `UI-shared-play.US2`, `ACT-bottom-player.US1`, `ACT-top-player.US1`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | As Bottom, select and move when Bottom is side to move. |
| S2 | As Top seat, select and move when Top is side to move (same device). |
| S3 | Toggle Advice if present; resign flow with confirm. |
| S4 | Confirm coordinates / advice affordances per screen story. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both seats can operate when it is their turn; resign confirm works. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Seat cannot move on its turn or resign skips confirm | yes |

## Evidence

Default evidence rules. Graphical: screenshot play and resign confirm.
