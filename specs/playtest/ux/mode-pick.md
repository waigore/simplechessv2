# Protocol: Mode pick screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-mode-pick`
- **Environment**: Headless and Graphical
- **Cites**: `UI-mode-pick.US1`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Open mode-pick; activate Shared game control. |
| S2 | Return; activate Puzzle stream control. |
| S3 | Confirm Last mode affordance when persisted. |
| S4 | Activate Switch locale; confirm the copy switches locale immediately. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both mode entries work; Last mode indication matches `UI-mode-pick.US1.1`. |
| P2 | Headless and Graphical both pass. |
| P3 | Switch locale updates mode-pick copy without leaving the screen. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Mode control missing or routes wrong | yes |

## Evidence

Default evidence rules. Graphical: screenshot mode-pick.
