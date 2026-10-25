# Notes — #334 acceptance, graphical `PTU-localization`

Build: `origin/main` `0fd4640`, Godot 4.7.2, `ENV.2` (macOS window 1280×720). Probe and judgements: `probe/accept334_graphical.gd`, run log `logs/graphical-probe.log`, session `sess-1792882280138-80759-playtest-439809`.

## What was judged

The graphical half of `PTU-localization` that `../headless-20261024T180000Z` deferred (`P5` is Graphical-only, `F7` fails while either environment is missing). This leaf's deliverable is the `puzzle-play` string table and its gate; the headless twin judged those table rows and they are re-read here on this build rather than copied. Everything else is the rendered screen, in protocol order: S1 (mode-pick at `en`, two `C4` activations), S2 (per-screen copy in three locales), S3 (third `C4` closing at `en`, then the `queen` row).

## S1 — pass on the rendered screen

`02-mode-pick-zh-Hant.png` after the first activation: S1 held, `R3` `繁體中文`, rows `選擇遊玩方式` / `共用對局 · 上次` / `謎題串流` / `結束`. `03-mode-pick-ja.png` after the second: `遊び方を選ぶ` / `シェア対局 · 前回` / `パズルストリーム` / `終了` / `日本語`. `title`, `shared`, `puzzle` differ in all three locales; the `locale` row never reads `English`; no `FAIL.T13` miss marker in the log.

The mode-pick panel paints faintly on this build — title and buttons at low contrast, most uninked in the capture. That is the `PTU-mode-pick` leg, not this protocol's rows: the text is present and correct.

## Findings

B1–B4 are in `screen-findings.md`: `shared-play` renders no `queen` row (B1), the promotion chooser never opens on a last-rank pawn place (B2), the dealt board is not the standard set (B3), and the headless twin's regional-indicator finding does not reproduce (B4).

## Outcome

**Fail on a game/interface reason.** `P4` and `P5` are not met for the `shared-play` `queen` row and the promotion chooser, and `F5`/`F6` block acceptance. The cause is in the Shared-play screen and rules, not in the `puzzle-play` copy this leaf ships: its 21 keys plus `mode-pick.puzzle` resolve in all three locales here, and its gate is non-vacuous (headless twin, re-read here). Acceptance waits on the defect, not on another localization run.
