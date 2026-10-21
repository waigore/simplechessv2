# Notes — #62 graphical

Headless twin already passed glyph coverage and ~40% layout for this build. This run re-drove the same Godot 4.7.2.stable.official.ed1daf0bf playtest build on macOS Aqua and captured 720×1280 PNGs.

## Prep

- Godot 4.7.2 graphical session (`DISPLAY=macOS` in `logs/graphical-capture.log`).
- Cycled `UI-mode-pick.C4` through `en` → `zh-Hant` → `ja`, then spot-checked shared-setup, shared-play (S1/S4/S5/S6), shared-result, and EX dialogs in CJK locales.
- PNGs under `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-en.png` | Mode-pick; “Choose how to play”; locale own-name English |
| `02-mode-pick-zh-Hant.png` | After C4; 選擇遊玩方式; 繁體中文 |
| `03-mode-pick-ja.png` | After C4; 遊び方を選ぶ; 日本語 |
| `04-ex-quit-confirm-ja.png` | EX.confirm quit; このセッションを終了しますか？ |
| `05-shared-setup-ja.png` | シェア対局の設定; clock/advice/start/back in ja |
| `06-shared-play-s1-ja.png` | 白の手番; Advice / Resign / Offer draw in ja; full board |
| `07-shared-play-s5-ja.png` | S5 refuse flash on refused square |
| `08-shared-play-s4-ja.png` | S4 promote chooser on board; ja chrome |
| `09-ex-resign-confirm-ja.png` | Resign EX.confirm path (confirm → Black wins result) |
| `10-shared-result-ja.png` | 対局終了 / 黒の勝ち |
| `11-shared-setup-zh-Hant.png` | 共用對局設定 |
| `12-shared-play-s6-zh-Hant.png` | S6 draw offer; 已提議和棋; 接受 / 拒絕 / 撤回 |
| `13-shared-result-zh-Hant.png` | 對局結束 / 和棋 |

No clipped labels or missing-glyph tofu observed on judged chrome. Piece silhouettes and board geometry unchanged across locales.
