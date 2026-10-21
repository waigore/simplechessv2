# End condition details

Authoring rules: [`.agents/specs/rules/design/end-conditions.md`](../../../.agents/specs/rules/design/end-conditions.md).

Split from [end-conditions.md](../end-conditions.md). Shared-game endings stop both clocks and continue at [K3](../loops/two-player-game.md). Puzzle endings (W1, L4, L5, L6) continue at [K3](../loops/puzzle-stream.md).

| ID | Unit | Type | Condition | Checked when | Outcome |
|----|------|------|-----------|--------------|---------|
| L1 | Shared game | loss | Side to move is in check and has no legal move | After a move, before the other clock starts | Side to move loses |
| L2 | Shared game | loss | Side to move resigns | On resign | Side to move loses |
| L3 | Shared game | loss | A running clock hits zero and the other side can checkmate | While that clock runs | Side to move loses. No seconds added |
| D1 | Shared game | draw | Side to move is not in check and has no legal move | After a move, before the other clock starts | Draw |
| D2 | Shared game | draw | `GS.drawOffer` is the side to move and the other side accepts, while the game is open and no other ending applies | On accept | Draw. A decline or withdraw continues, same side to move, clock running; an unanswered offer lapses when the side to move moves |
| D3 | Shared game | draw | Same position, side to move, castling and en passant rights, three times | After a move, before the other clock starts | Draw |
| D4 | Shared game | draw | Fifty moves by each side with no capture and no pawn move | After a move, before the other clock starts | Draw |
| D5 | Shared game | draw | A running clock hits zero and the other side cannot checkmate | While that clock runs | Draw. No seconds added |
| W1 | Puzzle | win | Required sequence played and no wrong move on that puzzle | Sequence completed | Solved. Next puzzle is harder |
| L4 | Puzzle | loss | Required sequence completed after a wrong move on that puzzle | Sequence completed | Failed. Next puzzle is easier |
| L5 | Puzzle | loss | Player reveals the solution | On reveal | Failed. Next puzzle is easier |
| L6 | Puzzle | loss | Player abandons the puzzle | On abandon | Failed. Next puzzle follows the Elo update |

**Can checkmate** (L3/D5): some legal-move series from here leads to checkmate, even if play is not best ([pieces.md](../entities/pieces.md)). D5 is its negation.

A [Wrong move](../glossary.md) is a [Solving side](../glossary.md) move that misses the next step. On a mate-in-one puzzle, any checkmating move is that step ([F-puzzle-catalog](../features/puzzle-catalog.md) R5). It blocks W1, resets the puzzle, and does not deal the next. The player may try again until L4, L5, or L6.
