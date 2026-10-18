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
| S2 | Cancel selection by empty square or designated cancel. |
| S3 | Optionally replay a recorded select-move sequence with `SIT.2`. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Input stories in `IN` hold for select/move/cancel. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Primary move path cannot complete a legal move | yes |

## Evidence

Default evidence rules.
