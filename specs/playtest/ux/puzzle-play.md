# Protocol: Puzzle play screen

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-puzzle-play`
- **Environment**: Headless and Graphical
- **Cites**: `UI-puzzle-play`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | On puzzle-play, move pieces for the required side. |
| S2 | Use reveal if offered; confirm failure UX then next puzzle. |
| S3 | Leave stream with confirm / cancel. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Puzzle controls and leave/reveal match `UI-puzzle-play`. |
| P2 | Headless and Graphical both pass. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Required puzzle controls missing or misrouted | yes |

## Evidence

Default evidence rules. Graphical: screenshot puzzle-play and leave confirm.
