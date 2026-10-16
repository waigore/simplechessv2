# End condition details

Authoring rules: [`.agents/specs/rules/design/end-conditions.md`](../../../.agents/specs/rules/design/end-conditions.md).

Split from [end-conditions.md](../end-conditions.md). Shared-game endings stop both clocks and continue at [K3](../loops/two-player-game.md). Puzzle endings deal the next puzzle per [progression.md](../progression.md).

| ID | Unit | Type | Condition | Checked when | Outcome |
|----|------|------|-----------|--------------|---------|
| L1 | Shared game | loss | Side to move is in check and has no legal move | After a move, before the other clock starts | Mover loses |
| L2 | Shared game | loss | Side to move resigns | On resign | Mover loses |
| L3 | Shared game | loss | A running clock hits zero and the other side can checkmate | While that clock runs | Mover loses. No seconds added |
| D1 | Shared game | draw | Side to move is not in check and has no legal move | After a move, before the other clock starts | Draw |
| D2 | Shared game | draw | Side to move offers a draw and the other accepts | On accept | Draw. A decline continues, same side to move, clock running |
| D3 | Shared game | draw | Same position, side to move, castling and en passant rights, three times | After a move, before the other clock starts | Draw |
| D4 | Shared game | draw | Fifty moves by each side with no capture and no pawn move | After a move, before the other clock starts | Draw |
| D5 | Shared game | draw | A running clock hits zero and the other side cannot checkmate | While that clock runs | Draw. No seconds added |
| W1 | Puzzle | win | Required sequence played and no wrong move on that puzzle | Sequence completed | Solved. Next puzzle is harder |
| L4 | Puzzle | loss | Required sequence completed after a wrong move on that puzzle | Sequence completed | Failed. Next puzzle is easier |
| L5 | Puzzle | loss | Player reveals the solution | On reveal | Failed. Next puzzle is easier |

A wrong move may be any move of a multi-move sequence. It blocks W1, returns the puzzle to its start, and does not deal the next puzzle. The player may try again until L4 or L5.
