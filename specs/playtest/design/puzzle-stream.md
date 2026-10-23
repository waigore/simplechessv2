# Protocol: Puzzle stream

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-puzzle-stream`
- **Environment**: Headless only
- **Cites**: `L-puzzle-stream` (K1–K4, E1), `END.L4`, `END.L5`, `END.L6`
- **Situational tools**: `SIT.1`

## Steps

| ID | Action |
|----|--------|
| S1 | Enter Puzzle stream from mode-pick; note dealt `puzzleId` / Elo (K1). |
| S2 | Play required sequence with no wrong move; confirm solve and next deal (K3). |
| S3 | On next puzzle, play a wrong move; confirm the open puzzle returns to its start with the same `puzzleId` and no next puzzle is dealt, then play another wrong move and confirm it is still retryable (K2). |
| S4 | Reveal solution on a puzzle; confirm failure then next deal (K2). |
| S5 | Leave stream confirmed; return to mode-pick (K4/E1). |
| S6 | On an open puzzle, play a wrong move, then complete the required sequence; confirm `END.L4`, an Elo update and exactly one next deal (K3). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Deal yields a puzzle; solve advances stream with Elo update path. |
| P2 | A wrong move resets the open puzzle and deals nothing; it is never a solve. Reveal fails and deals next. |
| P3 | Leave exits to mode-pick without treating open puzzle as solved. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A wrong move deals the next puzzle, counts as a solve, or cannot be retried | yes |
| F2 | Leave applies Elo penalty for open puzzle | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
