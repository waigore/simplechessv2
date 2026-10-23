# Protocol: Mode pick and configuration

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-mode-and-config`
- **Environment**: Headless only
- **Cites**: `FL-mode-pick`, `CFG`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Cold open to mode-pick; confirm Last mode highlight if persisted. |
| S2 | Choose Shared; set White seat, clock (Untimed/Blitz/Rapid), increment, Advice; Start. |
| S3 | Confirm applied CFG values in play state (`DBG.2`). |
| S4 | Return to mode-pick; choose Puzzle stream; confirm Advice not offered for puzzles. |
| S5 | Inspect CFG constants used (Blitz/Rapid starts, advice time ms) match design tables. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Mode-pick offers Shared and Puzzle; Last mode restored when present. |
| P2 | Setup options bind into Shared play state per CFG. |
| P3 | Puzzle path ignores Shared-only options (Advice). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Config values diverge from CFG tables | yes |
| F2 | Mode entry does not match FL-mode-pick | yes |

## Evidence

Default evidence rules.
