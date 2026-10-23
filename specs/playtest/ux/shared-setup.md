# Protocol: Shared setup screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-shared-setup`
- **Environment**: Headless and Graphical
- **Cites**: `UI-shared-setup.US1`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Set White seat, clock, increment, Advice; Start → shared-play. |
| S2 | Back → mode-pick without starting. |
| S3 | Confirm controls are operable by Bottom actor roles in story. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Setup controls and Start/Back match `UI-shared-setup.US1`. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Start/Back or options do not match story | yes |

## Evidence

Default evidence rules. Graphical: screenshot setup with options visible.
