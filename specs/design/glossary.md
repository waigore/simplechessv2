# Glossary

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Advice | Optional move suggestions in a Shared game when online and Advice is On | [`configuration.md`](configuration.md) |
| Blitz | Timed Shared game; each side starts at `CFG.BLITZ_START` | [`configuration.md`](configuration.md), [`loops/two-player-game.md`](loops/two-player-game.md) |
| Bottom player | The seat at the bottom of the shared device | [`configuration.md`](configuration.md) |
| Check | The side to move's king is attacked | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Checkmate | Side to move is in check and has no legal move (Shared-game loss) | [`end-conditions.md`](end-conditions.md) |
| Clock | Shared-game timing choice: Untimed, Blitz, or Rapid | [`configuration.md`](configuration.md) |
| Clock expiry | A running clock reaches zero (loss or draw per end conditions) | [`end-conditions.md`](end-conditions.md) |
| Draw | Shared-game ending that is neither win nor loss | [`end-conditions.md`](end-conditions.md) |
| Fifty-move rule | Draw after fifty moves each with no capture and no pawn move | [`end-conditions.md`](end-conditions.md) |
| Increment | Seconds added after each completed move in Blitz or Rapid | [`configuration.md`](configuration.md) |
| Legal move | One orthodox move that does not leave the mover's king in check | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Player Elo | The player's visible Puzzle-stream rating; starts at 1000; classic Elo updates | [`difficulty.md`](difficulty.md), [`progression.md`](progression.md) |
| Puzzle | One dealt position with a required sequence in Puzzle stream | [`end-conditions.md`](end-conditions.md) |
| Puzzle Elo | Fixed pre-rated difficulty of a puzzle; never changes | [`difficulty.md`](difficulty.md) |
| Puzzle stream | Solo continuous puzzles dealt one at a time; next pick follows Player Elo | [`configuration.md`](configuration.md), [`difficulty.md`](difficulty.md) |
| Rapid | Timed Shared game; each side starts at `CFG.RAPID_START` | [`configuration.md`](configuration.md), [`loops/two-player-game.md`](loops/two-player-game.md) |
| Required sequence | The correct move sequence that solves a puzzle | [`end-conditions.md`](end-conditions.md) |
| Resign | Side to move ends the Shared game and loses | [`end-conditions.md`](end-conditions.md) |
| Shared game | Two people play orthodox chess on one device in one sitting | [`configuration.md`](configuration.md), [`loops/two-player-game.md`](loops/two-player-game.md) |
| Side to move | The color whose turn it is to move | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Sitting | One continuous play period of about 15–40 minutes | [`design.md`](design.md), [`loops/two-player-game.md`](loops/two-player-game.md) |
| Stalemate | Side to move is not in check and has no legal move (draw) | [`end-conditions.md`](end-conditions.md) |
| Threefold repetition | Draw when the same position, side to move, and rights occur three times | [`end-conditions.md`](end-conditions.md) |
| Top player | The seat at the top of the shared device | [`configuration.md`](configuration.md) |
| Untimed | Shared game with no clocks | [`configuration.md`](configuration.md) |
| White seat | Which seat plays White and moves first | [`configuration.md`](configuration.md) |
| Wrong move | Any move in a puzzle that is not the next move of the required sequence | [`end-conditions.md`](end-conditions.md) |
