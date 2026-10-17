# Glossary

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Abandon puzzle | Leave current Puzzle unsolved; Elo loss; next dealt | [`loops/puzzle-stream.md`](loops/puzzle-stream.md) |
| Advice | Best-move highlights, arrow, and eval when On and online | [`features/move-advice.md`](features/move-advice.md) |
| Blitz | Timed Shared game; each side starts at `CFG.BLITZ_START` | [`configuration.md`](configuration.md) |
| Bottom player | Seat at the bottom of the shared device | [`configuration.md`](configuration.md) |
| Check | The side to move's king is attacked | [`entities/pieces/common.md`](entities/pieces/common.md) |
| Checkmate | Side to move is in check and has no legal move (Shared-game loss) | [`end-conditions.md`](end-conditions.md) |
| Clock | Shared-game timing: Untimed, Blitz, or Rapid | [`configuration.md`](configuration.md) |
| Clock expiry | A running clock reaches zero (loss or draw per end conditions) | [`end-conditions.md`](end-conditions.md) |
| Draw | Shared-game ending that is neither win nor loss | [`end-conditions.md`](end-conditions.md) |
| Fifty-move rule | Draw after fifty moves each with no capture and no pawn move | [`end-conditions.md`](end-conditions.md) |
| Increment | Seconds added after each completed move in Blitz or Rapid | [`configuration.md`](configuration.md) |
| Last mode | Shared game or Puzzle stream last chosen at mode pick; default highlight | [`flows/mode-pick.md`](flows/mode-pick.md) |
| Leave stream | Quit Puzzle stream; Elo kept; open puzzle not abandon | [`loops/puzzle-stream.md`](loops/puzzle-stream.md) |
| Legal move | Pseudo-legal piece move; mover's king not left in check | [`entities/pieces/common.md`](entities/pieces/common.md) |
| Piece | King, queen, rook, bishop, knight, or pawn | [`entities/pieces.md`](entities/pieces.md) |
| Player Elo | Puzzle rating; starts at `CFG.ELO_START`; Elo updates | [`difficulty.md`](difficulty.md), [`progression.md`](progression.md) |
| Puzzle | One dealt position with a required sequence in Puzzle stream | [`end-conditions.md`](end-conditions.md) |
| Puzzle Elo | Fixed pre-rated puzzle difficulty; never changes | [`difficulty.md`](difficulty.md) |
| Puzzle stream | Solo continuous puzzles; next pick follows Player Elo | [`loops/puzzle-stream.md`](loops/puzzle-stream.md) |
| Rapid | Timed Shared game; each side starts at `CFG.RAPID_START` | [`configuration.md`](configuration.md) |
| Required sequence | Correct move sequence that solves a puzzle | [`end-conditions.md`](end-conditions.md) |
| Resign | Side to move ends the Shared game and loses | [`end-conditions.md`](end-conditions.md) |
| Shared game | Two people play orthodox chess on one device in one sitting | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Side to move | The color whose turn it is to move | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Sitting | One continuous play period of about 15–40 minutes | [`design.md`](design.md) |
| Stalemate | Side to move is not in check and has no legal move (draw) | [`end-conditions.md`](end-conditions.md) |
| Threefold repetition | Draw when same position, side to move, and rights occur thrice | [`end-conditions.md`](end-conditions.md) |
| Top player | Seat at the top of the shared device | [`configuration.md`](configuration.md) |
| Untimed | Shared game with no clocks | [`configuration.md`](configuration.md) |
| White seat | Which seat plays White and moves first | [`configuration.md`](configuration.md) |
| Wrong move | Puzzle move that is not the next move of the required sequence | [`end-conditions.md`](end-conditions.md) |
