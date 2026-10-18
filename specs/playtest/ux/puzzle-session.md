# Protocol: Puzzle session journey

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-puzzle-session`
- **Environment**: Headless and Graphical
- **Cites**: `J-puzzle-session` (N1–N2, S1–S2, B1)
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | From mode-pick, Puzzle stream → puzzle-play. |
| S2 | Leave stream → confirm → mode-pick. |
| S3 | Leave → cancel; remain on puzzle-play. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Journey matches `J-puzzle-session` including cancel branch. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Leave without confirm exits, or cancel leaves stream | yes |
| F2 | Passes in only one environment | yes |

## Evidence

Default evidence rules. Graphical: screenshot confirm and cancel states.
