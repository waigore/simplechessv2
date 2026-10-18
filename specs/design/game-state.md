# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

- **Serves**: Shared game with clocks; Puzzle stream + Elo matching; optional Stockfish advice (definition scope).

Logical only: no data formats or storage. Other specs reference fields by name. Persistence: [`progression.md`](progression.md). Options: [`configuration.md`](configuration.md).

## Scopes

| Scope | Lifetime | Examples in this game |
|-------|----------|-----------------------|
| Moment | One selection or in-flight advice update | Selected piece; advice stream deepening |
| Session / run | One Shared game, or one open puzzle in the stream | Position, clocks, sequence progress |
| Persistent | Across sittings until this game's storage is cleared | Player Elo, Last mode, recent solved IDs |
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

- **H1**: The full [Required sequence](glossary.md) is not knowable until played or revealed. `GS.position` and `GS.sideToMove` are always knowable in play.
- **H2**: `GS.adviceBestMove` and `GS.adviceEval` are knowable only when set (Advice On, online, ready).

## Randomness and determinism

- **Q1**: Which puzzle is dealt among candidates matching [DIF.Y1](difficulty.md) need not be identical for the same Elo and history (catalog order may vary).
