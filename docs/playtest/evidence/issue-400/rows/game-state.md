# Rows — `game-state`

Graphical re-read: [`rows-game-state.md`](../graphical-20261025T231024Z/rows-game-state.md).

One row per cited story row: its headless outcome and every `not-judged` reason.

| Story row | Outcome | Note |
|---|---|---|
| `game-state.md#PS1` | pass | V1 White to move / V2 untimed: no clock runs / V3 no advice in shared |
| `game-state/fields-play.md#PS1` | pass | PS1.2 new game resets to orthodox opening / GS.position readable (e2 = { "color": "white", "kind": "pawn" }) |
| `game-state/fields-play-moment.md#PS1` | pass | selectedPiece initial none / selectedPiece set on select / deselect clears selectedPiece |
| `game-state/fields-play-puzzle.md#PS1` | pass | puzzleId w400h, sequenceIndex 0 |
| `game-state/fields-play-reset.md#PS1` | pass | Untimed shared start clears clocks |
| `game-state/fields-play-end.md#PS1` | pass | drawOffer initial none / gameEnded after resign |
| `game-state/fields-play-draw.md#PS1` | pass | draw offer initial none |
| `game-state/fields-persist.md#PS1` | pass | playerElo 1000 default on a fresh document (1000.0); run document holds 994.87568183641 |
| `game-state/fields-persist-config.md#PS1` | pass | whiteSeat/clock/increment/advice defaults |
