# Game-state fields — play

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Part of [`fields.md`](fields.md). Ending fields: [`fields-play-end.md`](fields-play-end.md).

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.selectedPiece` | Moment | Piece under select, or none | none | Select/clear; clear on completed move | Empty, or one piece of the side to move |
| `GS.position` | Session / run | Board and rights for legality | Opening (Shared); dealt start (Puzzle) | Legal moves; wrong move resets puzzle | Always legal for the mode |
| `GS.sideToMove` | Session / run | White or Black to move | White (Shared); as dealt (Puzzle) | Legal move; required reply; wrong move → dealt | Alternates on each legal move in play |
| `GS.whiteClock` | Session / run | White seconds left, or none | Equal CFG start, or none | Tick; stop/add on move; stop on end | Timed: ≥ 0 |
| `GS.blackClock` | Session / run | Black seconds left, or none | Equal CFG start, or none | Same as white | Timed: ≥ 0 |
| `GS.puzzleId` | Session / run | Current puzzle, or none | [Puzzle catalog](../features/puzzle-catalog.md) PuzzleId, or none | Deal; leave | Only in Puzzle stream |
| `GS.puzzleElo` | Session / run | Open puzzle's [Puzzle Elo](../glossary.md) | [Puzzle catalog](../features/puzzle-catalog.md), or none | Deal; leave | Fixed for that puzzle |
| `GS.requiredSequence` | Session / run | Open puzzle's correct move list | [Puzzle catalog](../features/puzzle-catalog.md), or none | Deal; leave | Length ≥ 1 when open |
| `GS.sequenceIndex` | Session / run | Next required step (0-based) | 0 | Matching move or reply; wrong move → 0 | 0 ≤ index ≤ length |
| `GS.solvingSide` | Session / run | Side the player moves | None; side to move at deal | Deal; leave | None, or side to move at deal |
| `GS.wrongMoveOnPuzzle` | Session / run | Any [Wrong move](../glossary.md) this puzzle | false | Wrong move | True until a new deal |
| `GS.online` | Moment | Browser can reach the advice service | As observed | Connection changes | Read by Advice only |
| `GS.adviceBestMove` | Moment | Best move for side to move, or none | none | [move-advice.md](../features/move-advice.md) | None when Off, offline, or cleared |
| `GS.adviceEval` | Moment | Eval in centipawns from White, or none | none | [move-advice.md](../features/move-advice.md) | None when best move is none |
