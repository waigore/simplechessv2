# Protocol: Game state

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: Design
- **Spec key**: `PTD-game-state`
- **Environment**: Headless only
- **Cites**: `GS` (selected fields + invariants from stories)
- **Situational tools**: `SIT.3`

## Steps

| ID | Action |
|----|--------|
| S1 | Shared play: select a piece; confirm `selectedPiece`; deselect / move clears appropriately. |
| S2 | After legal moves, confirm `position`, `sideToMove`, clocks fields match loop rules. |
| S3 | End a game; confirm `gameEnded` and advice fields cleared. |
| S4 | Puzzle: confirm `puzzleId`, sequence index, `wrongMoveOnPuzzle` transitions. |
| S5 | Persist path: after puzzle result, reopen; confirm `playerElo`, `lastMode`, `recentSolved` committed values. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Play fields update only via legal transitions; inspect matches stories. |
| P2 | Persist fields survive reopen; failed write leaves prior commit (when injectable). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Fields desync from board / mode / puzzle rules | yes |
| F2 | Persist fields lost or corrupted across reopen | yes |

## Evidence

Default evidence rules (Headless: no screenshots).
