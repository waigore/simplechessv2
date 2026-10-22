# Protocol: Shared result screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-result`
- **Environment**: Headless and Graphical
- **Cites**: `UI-shared-result.US1`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Reach shared-result after a game end. |
| S2 | Play again → shared-setup. |
| S3 | Stop → mode-pick. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Result actions match `UI-shared-result.US1`. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Play again / Stop route incorrectly | yes |

## Evidence

Default evidence rules. Graphical: screenshot result.
