# Protocol: Controls

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-controls`
- **Environment**: Headless and Graphical
- **Cites**: `IN`
- **Situational tools**: `SIT.2` when validating recorded touch sequences

## Steps

| ID | Action |
|----|--------|
| S1 | Select piece then destination via primary touch/click path. |
| S2 | Clear a selection by tapping the selected piece or an empty non-destination. `IN.cancel` stays the exception-dialog dismiss. |
| S3 | Optionally replay a recorded select-move sequence with `SIT.2`. |
| S4 | Pick-and-drag an unselected own piece onto a legal destination. That plays the move. |
| S5 | Release a drag on an illegal square, an empty non-destination, or off the board. The selection clears and no place is asked. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Input stories in `IN` hold for select, tap move, drag move, and deselect (tap and bad drop). |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Primary move path cannot complete a legal move | yes |

## Evidence

Default evidence rules.
