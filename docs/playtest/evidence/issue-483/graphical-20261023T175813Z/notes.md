# Graphical notes — #483

Acceptance playtest for #483 on build `c4fcb88` (PR [#631](https://github.com/waigore/simplechessv2/pull/631) head `fa23a7d` + `main` `63f744c`), graphical environment `ENV.2` (OpenGL 4.1 Metal on Apple M5).

## Prep

- `godot --path game -s res://accept483_graphical.gd` — drives the shipped `main.tscn` and saves viewport captures (`logs/graphical-capture.log`).
- The build is the same merged tree the headless run used; the smoke `PlaytestHarness` node is present here (it no-ops off headless), so the run is unmodified.

## Judgement (graphical)

| ID | Outcome | Evidence |
|----|---------|----------|
| P1 — first `C4` gives `zh-Hant` copy and the `locale` row reads `繁體中文` | pass | `screenshots/01-mode-pick-en.png` → `02-mode-pick-zh-Hant.png`; `OK graphical first C4 -> zh-Hant` |
| P2 — `title`, `shared` differ per locale on screen | pass | `01`/`02`/`03` show `Choose how to play` / `選擇遊玩方式` / `遊び方を選ぶ` |
| P4 — `locale` reads the live own name | pass | `English` / `繁體中文` / `日本語` across the three captures |
| P5 — promotion-chooser `queen` row reads `Queen` in all three locales | pass | `screenshots/04-shared-play-promote.png`; `QUEEN {"en":"Queen","ja":"Queen","zh-Hant":"Queen"}` |

## Screenshot list

- `01-mode-pick-en.png` — mode-pick at `en`, before any switch.
- `02-mode-pick-zh-Hant.png` — mode-pick **after the first `C4` activation**: `title` `選擇遊玩方式`, `quit` `結束`, `locale` row `繁體中文`.
- `03-mode-pick-ja.png` — mode-pick at `ja`.
- `04-shared-play-promote.png` — Shared play with the promotion chooser open, showing the four piece sprites including the `queen` row (same in every locale).

## Notes

No protocol failed. The five-screen full copy listing (S2/S3) is not re-judged here: the change adds no player-facing string, and key-set completeness for every owner is asserted by the unit-test gate and recorded in the headless twin. Screenshots are of the judged build and cover the two states the protocol names (mode-pick after the first activation; the `queen` row).
