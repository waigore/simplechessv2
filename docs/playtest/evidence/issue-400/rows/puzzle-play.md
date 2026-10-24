# Rows — `puzzle-play`

Graphical re-read: [`rows-puzzle-play.md`](../graphical-20261025T231024Z/rows-puzzle-play.md).

One row per cited story row: its headless outcome and every `not-judged` reason.

| Story row | Outcome | Note |
|---|---|---|
| `screens/puzzle-play.md#US1` | pass | US1.1/2.2 dealt record opens the board (w400a) / US1.3 opponent's first move applied; side to move black / US1.1/2.7 solve advances (END.W1, elo 1000.00 → 1011.15, gesture true, owed moves done 0) |
| `screens/puzzle-play-regions.md#US2` | pass | US2.1 board renders the dealt position (e2 = { "color": "white", "kind": "pawn" }) / US2.2 R2 shows Player Elo 1011 (no Elo label) / US2.3 harness begins in SS1 |
| `screens/puzzle-play-choices.md#US3` | pass | US3.1 C3 reveal confirm → SS2 reveal_confirm / US3.2 cancel keeps the puzzle open (SS1) |
| `screens/puzzle-play-place.md#US3` | not-judged | US3.11 refused place a7 → SS5, selection kept (a7) [gesture accepted false] / US3.12 flash ends → SS1 / US3.13 promotion and US3.14 lapsed confirm need a last-rank pawn not reachable in this run |
| `screens/puzzle-play-confirm.md#US5` | pass | US5.1 reveal → END.L5 (results 1 → 2, at confirm { "ui_state": "S2", "confirm_kind": "reveal_confirm", "open": true, "outcome": "" }) / US5.2 reveal scores S = 0 (elo 1011.15 → 1001.97) / US5.3 confirm leaves S2 (SS1) |
