# Story rows — design — headless run

Rows from `traceability/story-protocol/protocols.md` at `d34050f`; outcomes from
this run's `results.json`. Manifest: [manifest.md](manifest.md).

## Story rows

| Story row | Protocol | Outcome | Why |
|---|---|---|---|
| `loops/two-player-game.md#PS1` | `PTD-shared-game` | not-judged | clock start and expiry (PS1.2/1.3/1.6/1.12/1.13) sit beyond this sampled run |
| `loops/two-player-draw.md#PS1` | `PTD-shared-game` | pass | all scenario checks pass |
| `configuration.md#PS1` | `PTD-mode-and-config` | pass | all scenario checks pass |
| `flows/mode-pick.md#PS1` | `PTD-mode-and-config` | pass | all scenario checks pass |
| `flows/mode-pick-unavailable.md#PS1` | `PTD-mode-and-config` | pass | all scenario checks pass |
| `loops/two-player-tunables.md#PS1` | `PTD-mode-and-config` | pass | all scenario checks pass |
| `features/move-advice-tunables.md#PS1` | `PTD-mode-and-config` | not-judged | `CFG.ADVICE_TIME_MS` default is a technical configuration row, not a play observation |
| `difficulty-tunables.md#PS1` | `PTD-mode-and-config` | not-judged | DIF tunables are proven by the puzzle-stream rows, outside the wave-1 set |
| `end-conditions.md#PS1` | `PTD-end-conditions` | pass | all scenario checks pass |
| `end-conditions/conditions.md#PS1` | `PTD-end-conditions` | pass | all scenario checks pass |
| `end-conditions/conditions-puzzle.md#PS1` | `PTD-end-conditions` | pass | all scenario checks pass |
| `end-conditions/conditions-draw.md#PS1` | `PTD-end-conditions` | pass | all scenario checks pass |
| `end-conditions/conditions-counts.md#PS1` | `PTD-end-conditions` | not-judged | D3 threefold repetition needs a crafted move history |
| `game-state.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play-moment.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play-puzzle.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play-reset.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play-end.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-play-draw.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-persist.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `game-state/fields-persist-config.md#PS1` | `PTD-game-state` | pass | all scenario checks pass |
| `entities/pieces.md#PS1` | `PTD-pieces-common` | pass | all scenario checks pass |
| `entities/pieces/common.md#PS1` | `PTD-pieces-common` | pass | all scenario checks pass |
| `entities/pieces/common-legality.md#PS1` | `PTD-pieces-common` | pass | all scenario checks pass |
| `entities/pieces/common-attack.md#PS2` | `PTD-pieces-common` | not-judged | I5/I6 attacked-square rows need crafted positions |
| `entities/pieces/king.md#PS1` | `PTD-pieces-king` | pass | all scenario checks pass |
| `entities/pieces/king-castling.md#PS1` | `PTD-pieces-king` | not-judged | castling needs a cleared f1/g1, reachable only by crafted positions |
| `entities/pieces/officers.md#PS1` | `PTD-pieces-officers` | not-judged | queen/rook long rays need crafted positions |
| `entities/pieces/pawn.md#PS1` | `PTD-pieces-pawn` | not-judged | en passant and promotion need crafted positions |
