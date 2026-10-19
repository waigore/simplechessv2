# Game-state fields — play

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Part of [`fields.md`](fields.md).

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.selectedPiece` | Moment | Piece under select, or none | none | Select or clear in play; cleared when a move completes | Empty, or one piece of the side to move |
| `GS.position` | Session / run | Board and rights for legality | Opening (Shared); dealt start (Puzzle) | Legal moves; wrong move resets puzzle start | Always a legal position for the mode |
| `GS.sideToMove` | Session / run | White or Black to move | White (Shared); as dealt (Puzzle) | Completed legal move; required puzzle reply; wrong move → dealt | Alternates on each legal move that stays in play |
| `GS.whiteClock` | Session / run | White seconds left, or none | Equal CFG start, or none | Tick; stop and add on move; stop on end | Timed: ≥ 0 |
| `GS.blackClock` | Session / run | Black seconds left, or none | Equal CFG start, or none | Same as white clock | Timed: ≥ 0 |
| `GS.gameEnded` | Session / run | Shared game over | false | End conditions | True ⇒ no further Shared-game moves |
| `GS.drawOffer` | Session / run | Side with a pending draw offer, or none | none | Offer; decline; withdraw; completed move (lapse); end | None or one side; only while the Shared game is open |
| `GS.puzzleId` | Session / run | Current puzzle, or none | Dealt id, or none | Deal; leave | Only in Puzzle stream |
| `GS.puzzleElo` | Session / run | Open puzzle's [Puzzle Elo](../glossary.md) | Catalog, or none | Deal; leave | Never changes for that puzzle |
| `GS.requiredSequence` | Session / run | Open puzzle's correct move list | Catalog, or none | Deal; leave | Length ≥ 1 when a puzzle is open |
| `GS.sequenceIndex` | Session / run | Next required step (0-based) | 0 | Matching move or required reply; wrong move → 0 | 0 ≤ index ≤ length |
| `GS.solvingSide` | Session / run | Side the player moves | None; side to move at deal | Deal; leave | None, or side to move at deal; fixed for that puzzle |
| `GS.wrongMoveOnPuzzle` | Session / run | Any [Wrong move](../glossary.md) this puzzle | false | Wrong move | Stays true until a new deal |
| `GS.online` | Moment | Browser can reach the advice service | As observed | Connection changes | Read by Advice only |
| `GS.adviceBestMove` | Moment | Best move for side to move, or none | none | [move-advice.md](../features/move-advice.md) | None when Off, offline, or cleared |
| `GS.adviceEval` | Moment | Eval in centipawns from White's view, or none | none | [move-advice.md](../features/move-advice.md) | None when best move is none |
