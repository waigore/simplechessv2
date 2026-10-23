# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

- **Serves**: Shared game with clocks; Puzzle stream + Elo matching; optional Stockfish advice (definition scope).

Logical only: no data formats or storage. Other specs reference fields by name. Persistence: [`progression.md`](progression.md). Options: [`configuration.md`](configuration.md).

## Scopes

| Scope | Lifetime | Examples in this game |
|-------|----------|-----------------------|
| Moment | One selection or in-flight advice update | Selected piece; advice stream deepening |
| [Run](glossary.md) | One Shared game, or one open puzzle in the stream | Position, clocks, sequence progress |
| Persistent | Across sessions until this game's saved data is cleared | Player Elo, Last mode, recent solved IDs |
| Configuration | Until changed, or locked per [configuration.md](configuration.md) | White seat, Clock, Increment, Advice, locale |

Stage: deleted — no stages.

Field tables: [`game-state/fields.md`](game-state/fields.md).

## Derived values

| Value | Derived from | Used by |
|-------|--------------|---------|
| Check, checkmate, stalemate, legal moves | `GS.position`, `GS.sideToMove` | Shared-game and puzzle loops; end conditions |
| Running clock | Timed Clock; not `GS.gameEnded`; `GS.sideToMove` | [`two-player-game.md`](loops/two-player-game.md) |
| Advice may show | Advice On; online; Shared game; not ended; `GS.adviceBestMove` set | [`move-advice.md`](features/move-advice.md) |

## Global invariants

- **V1**: Only the [Side to move](glossary.md) may change `GS.position` (Shared game and Puzzle stream).
- **V2**: In a timed Shared game, at most one of `GS.whiteClock` and `GS.blackClock` is running.
- **V3**: In Puzzle stream, `GS.adviceBestMove` and `GS.adviceEval` are always none.

## Hidden and visible state

- **H1**: The full [Required sequence](glossary.md) is not knowable until played or revealed. `GS.position` and `GS.sideToMove` are always knowable in play, and `GS.solvingSide` in Puzzle stream.
- **H2**: `GS.adviceBestMove` and `GS.adviceEval` are knowable only when set (Advice On, online, ready).

## Randomness and determinism

- **Q1**: The random outcome is which [Puzzle](glossary.md) is dealt. The range is any puzzle in the [DIF.Y1](difficulty.md) candidate set. That set is the in-band puzzles ([Puzzle Elo](glossary.md) within ±`CFG.ELO_MATCH_RANGE` of current [Player Elo](glossary.md)) outside the recent-solved window (not solved among the last `CFG.ELO_RECENT_WINDOW` puzzles), then the specified widen (`CFG.ELO_BAND_WIDEN`) and/or allow-recent relax, until at least one candidate exists. Any puzzle in that set may be dealt. The same Elo and history need not deal the same puzzle.
