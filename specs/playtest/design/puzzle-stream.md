# Protocol: Puzzle stream

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-puzzle-stream`
- **Environment**: Headless only
- **Cites**: `L-puzzle-stream` (K1–K4, E1)
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Enter Puzzle stream from mode-pick; note dealt `puzzleId` / Elo. |
| S2 | Play required sequence with no wrong move; confirm solve and next deal (K3). |
| S3 | On next puzzle, play a wrong move; confirm puzzle not advanced as solve; fail path deals next (K2/K3). |
| S4 | Reveal solution on a puzzle; confirm failure then next deal. |
| S5 | Leave stream confirmed; return to mode-pick (K4/E1). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Deal yields a puzzle; solve advances stream with Elo update path. |
| P2 | Wrong move / reveal are failures; next puzzle is dealt without treating as solve. |
| P3 | Leave exits to mode-pick without treating open puzzle as solved. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Wrong move counted as solve or blocks next deal incorrectly | yes |
| F2 | Leave applies Elo penalty for open puzzle | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
