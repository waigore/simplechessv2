# Graphical notes — #511

Same build as the headless twin (`e022f83`, deliverable `f44b535` / PR #519). Graphical run: `godot --path game --resolution 720x1280 -s res://accept511_probe.gd`, X11 on Xvfb with Mesa llvmpipe (OpenGL Compatibility); 720×1280 PNGs under `screenshots/`.

## Drive

- Mode pick in `en`, then `UI-mode-pick.C4` twice: `en` → `zh-Hant` → `ja`. Each reading dumps every visible label and button and checks it against its Copy-table row.
- Shared game: `C1` (Shared game) → shared set-up `C5` (開始, live `ja`) → Shared play. White promotes on the `d7xc8` path (`e2e4 a7a6 e4e5 a6a5 e5e6 a5a4 e6xd7`) so the `S4` promote chooser is on screen with the live locale's chrome.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-en.png` | Mode pick S1, `en`: “Choose how to play”, Shared game · Last, Quit, `English`. |
| `02-mode-pick-zh-Hant.png` | After the first `C4`: 選擇遊玩方式, 共用對局 · 上次, 結束, `繁體中文`. P1/P4 pass. |
| `03-mode-pick-ja.png` | After the second `C4`: 遊び方を選ぶ, シェア対局 · 前回, 終了, `日本語`. P1/P2/P4 pass. |
| `04-shared-setup-ja.png` | Shared set-up in `ja` (シェア対局の設定 chrome, 開始). |
| `05-shared-play-promote.png` | Shared play `S4` promote chooser in `ja`: the four piece rows read `Queen` `Rook` `Bishop` `Knight` — their `en` value, per `L3` / `I5` — with `ja` chrome (黒の手番, チェック, 投了, 引き分けを提案). P3 pass. |
| `06-shared-play-s1.png` | Shared play `S1` in `ja` after the promotion commits on `Queen`; chrome unchanged, marked rows unchanged. |

## Checks recorded in the log

- `COPY mode-pick/reading{1,2,3} unmatched=[]` — every visible mode-pick string (four per reading, `Shared game · Last` counted as its `shared` + `last` rows) is a Copy-table value for the live locale.
- `COPY shared-play/{promote,s1} unmatched=[]` — every visible shared-play copy string is a `shared-play` row value; the `C1`/`C10`/`C2` focus sentinels and board coordinates are not copy and are excluded.
- `JUDGE P1`/`P2`/`P3`/`P4` pass; `ISSUE511_PROBE pass`.
- No `CLIPPED` line: each visible label's minimum width fits its slot. Glyph coverage for `zh-Hant` / `ja` is asserted by the shipped `_font_chain_and_glyphs` gate in the 19-test run of the same build.
- Screenshot pixel sanity (distinct colours and non-uniform mean) confirms six rendered frames rather than blank captures.
