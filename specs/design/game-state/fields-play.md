# Game-state fields — play

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Part of [`fields.md`](fields.md).

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.selectedPiece` | Moment | Piece under select, or none | none | Select or clear on Shared and Puzzle play; cleared when a move completes | Empty, or one piece of the side to move |
| `GS.position` | Session / run | Board and rights needed for legality | Opening (Shared); dealt start (Puzzle) | Legal moves; wrong move resets puzzle start | Always a legal position for the mode |
| `GS.sideToMove` | Session / run | White or Black to move | White (Shared); as dealt (Puzzle) | Completed legal move | Alternates on each legal move |
| `GS.whiteClock` | Session / run | White seconds left, or none if Untimed | Equal CFG start, or none | Tick; stop and add on move; stop on end | Timed: ≥ 0 |
| `GS.blackClock` | Session / run | Black seconds left, or none if Untimed | Equal CFG start, or none | Same as white clock | Timed: ≥ 0 |
| `GS.gameEnded` | Session / run | Shared game over | false | End conditions | True ⇒ no further Shared-game moves |
| `GS.puzzleId` | Session / run | Current catalog puzzle, or none | Dealt id, or none | Deal; leave stream | Set only in Puzzle stream |
| `GS.puzzleElo` | Session / run | Fixed [Puzzle Elo](../glossary.md) of the open puzzle | From catalog | Deal | Never changes for that puzzle |
| `GS.requiredSequence` | Session / run | Correct move list for the open puzzle | From catalog | Deal | Length ≥ 1 when a puzzle is open |
| `GS.sequenceIndex` | Session / run | Next required step (0-based) | 0 | Matching move; wrong move → 0 | 0 ≤ index ≤ length |
| `GS.wrongMoveOnPuzzle` | Session / run | Any [Wrong move](../glossary.md) this puzzle | false | Wrong move | Stays true until a new deal |
| `GS.online` | Moment | Browser can reach the advice service | As observed | Connection changes | Read by Advice only |
| `GS.adviceBestMove` | Moment | Best move for side to move, or none | none | [move-advice.md](../features/move-advice.md) | None when Off, offline, or cleared |
| `GS.adviceEval` | Moment | Eval in centipawns from White's view, or none | none | [move-advice.md](../features/move-advice.md) | None when best move is none |
