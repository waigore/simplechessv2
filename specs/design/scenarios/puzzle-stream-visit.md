# Scenario: Puzzle stream visit

Authoring rules: [`.agents/specs/rules/design/scenarios.md`](../../../.agents/specs/rules/design/scenarios.md).

- **Kind**: puzzle
- **Stage**: N/A — no stages; board play only
- **Serves**: Instant play and Cafe calm (vision); Puzzle stream + Elo matching (definition scope).

## Setup

- **Starting state**: First visit — `GS.playerElo` = `CFG.ELO_START`; `GS.recentSolved` empty; `GS.lastMode` none; no puzzle open (`GS.puzzleId` none).
- **Participants**: One player; puzzles from the [Puzzle catalog](../glossary.md).
- **Configuration and difficulty**: Defaults (`CFG.ELO_START`, `CFG.ELO_K`, `CFG.ELO_MATCH_RANGE`, `CFG.ELO_RECENT_WINDOW`, `CFG.ELO_BAND_WIDEN`); dynamic matching per [DIF.Y1](../difficulty.md).
- **Objectives**: Solve each dealt [Puzzle](../glossary.md).
- **Constraints**: Untimed. A [Wrong move](../glossary.md) returns the puzzle to its start. No [Advice](../glossary.md).
- **End conditions**: END.W1, END.L4, END.L5, END.L6 in [conditions.md](../end-conditions/conditions.md) (Puzzle unit).

## Walkthroughs

### Walkthrough 1: Solve the first deal

| ID | Player does | Game responds (rule applied) | Resulting state |
|----|-------------|------------------------------|-----------------|
| W1.1 | Opens the game | Mode pick starts ([FL-mode-pick.N1](../flows/mode-pick.md)); default highlight Shared game (no Last mode) | At mode pick |
| W1.2 | Chooses Puzzle stream | [FL-mode-pick.T2](../flows/mode-pick.md); [L-puzzle-stream.K1](../loops/puzzle-stream.md): deal per [DIF.Y1](../difficulty.md) within ±`CFG.ELO_MATCH_RANGE` of `CFG.ELO_START`; store Last mode = Puzzle stream ([PRG.P2](../progression.md)) | Puzzle dealt; `GS.sequenceIndex` 0; `GS.wrongMoveOnPuzzle` false |
| W1.3 | Plays each move of the required sequence | Each legal move advances the sequence ([L-puzzle-stream.K2](../loops/puzzle-stream.md); `E-pieces.I10`) | `GS.sequenceIndex` reaches the end |
| W1.4 | Completes the sequence | [END.W1](../end-conditions/conditions.md): Elo update S = 1 per [DIF.Y1](../difficulty.md); `GS.recentSolved` appends the id, trimmed to `CFG.ELO_RECENT_WINDOW` ([PRG.P3](../progression.md), [PRG.M1](../progression.md)); next deal prefers the raised band ([L-puzzle-stream.K3](../loops/puzzle-stream.md)) | `GS.playerElo` up; new puzzle open |

- **Outcome**: END.W1 — solved; [Player Elo](../glossary.md) rises; the stream continues.
- **Player experience**: Untimed and calm; the result and the new deal are clear ([feedback.md](../experience/feedback.md)).

### Walkthrough 2: Wrong move, reveal, abandon

| ID | Player does | Game responds (rule applied) | Resulting state |
|----|-------------|------------------------------|-----------------|
| W2.1 | Plays a wrong move on the new deal | [L-puzzle-stream.K2](../loops/puzzle-stream.md): puzzle returns to its start; no deal; END.W1 now blocked on this puzzle | `GS.sequenceIndex` 0; `GS.wrongMoveOnPuzzle` true |
| W2.2 | Retries, then reveals the solution | [END.L5](../end-conditions/conditions.md): failed; Elo update S = 0 per [DIF.Y1](../difficulty.md); next puzzle dealt on the lowered band ([L-puzzle-stream.K3](../loops/puzzle-stream.md)) | `GS.playerElo` down; new puzzle open |
| W2.3 | Abandons that puzzle | [END.L6](../end-conditions/conditions.md): failed; the next puzzle follows the Elo update S = 0 ([L-puzzle-stream.K3](../loops/puzzle-stream.md); [PRG.M1](../progression.md)) | `GS.playerElo` down again; new puzzle open |
| W2.4 | Leaves the stream | [L-puzzle-stream.K4](../loops/puzzle-stream.md); [FL-mode-pick.T4](../flows/mode-pick.md): Elo kept ([PRG.P1](../progression.md)); open puzzle not scored as END.L6 | At mode pick |

- **Outcome**: END.L5 then END.L6 — two failures, each followed by the next deal; the open puzzle at leave is unscored; the sitting continues at mode pick.
- **Player experience**: Failure never ends the stream; leaving costs nothing on the open puzzle.

## Edge cases covered

Wrong-move reset without a deal; reveal after a wrong move; abandon with an open puzzle; leaving with an open puzzle (not scored).

## Specs exercised

[flows/mode-pick.md](../flows/mode-pick.md), [loops/puzzle-stream.md](../loops/puzzle-stream.md), [difficulty.md](../difficulty.md), [end-conditions/conditions.md](../end-conditions/conditions.md), [progression.md](../progression.md), [configuration.md](../configuration.md), [game-state/fields-play.md](../game-state/fields-play.md), [game-state/fields-persist.md](../game-state/fields-persist.md), [entities/pieces/common.md](../entities/pieces/common.md), [experience/feedback.md](../experience/feedback.md).
