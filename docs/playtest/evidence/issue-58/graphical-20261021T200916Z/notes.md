# Graphical notes

Judged the same build as the headless twin: worktree at `fff626b` (includes merged #337 shared-play layout/focus).

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove mode-pick → Shared setup → Start → shared-play; select e2; place e2→e4; resign confirm; restart with Top White seat + Blitz; toggle Advice Off.
- Captured 1280×720 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-play-bottom.png` | Opening S1; White Bottom; “White to move”; Advice On + Resign; full 8×8 in frame under R2 chrome |
| `02-shared-play-selection-legal.png` | e2 selection highlight; empty-target diamonds on e3/e4 (`PER.R3` / `PER.R4`) |
| `03-shared-play-after-place.png` | After legal place; pawn on e4; selection cleared; “Black to move” |
| `04-resign-confirm-s2.png` | `EX.confirm` “Resign this game?” with Confirm / Cancel; board dimmed unavailable |
| `05-shared-play-top-blitz.png` | White seat Top (`CAM-board.M2`); Blitz clocks `W 0:59 · B 1:00` (`PER.R6`) |
| `06-advice-toggle-stub.png` | Advice Off; no evaluation / advice display (`F-move-advice.R2`) |

No protocol fail for in-scope UX steps. Design `PTD-shared-game` is headless-only.
