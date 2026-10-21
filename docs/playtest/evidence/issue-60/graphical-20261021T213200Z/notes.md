# Graphical notes

Judged the same build as the headless twin: `0a14c88` (PRs #356 / #359).

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove cold-open mode-pick → Shared setup → Start → select e2 → place e2→e4 → resign confirm → result → Stop → mode-pick.
- Asserted Ambient off until Shared-play, cue counts for X1/X2/X4, Ambient still loaded after Stop.
- Captured 1280×720 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-cold-open-silent.png` | Cold-open mode-pick; Ambient not loaded; music not started |
| `02-shared-setup-pre-ambient.png` | Shared setup before board playable; still silent |
| `03-shared-play-ambient-started.png` | Shared-play; Ambient loaded; M1 started |
| `04-shared-play-select-x1.png` | e2 selected; X1 cue fired |
| `05-shared-play-after-move-x2.png` | After e2→e4; X2 cue fired; Black to move |
| `06-resign-confirm-s2.png` | Resign confirm open (`EX.confirm`) |
| `07-shared-result-after-x4.png` | Result after resign; X4 end cue fired (`END.L2`) |
| `08-mode-pick-ambient-continues.png` | Mode-pick after Stop; Ambient still loaded for the sitting |

Log ends with `ISSUE60_GRAPHICAL pass`. Design `PTD-shared-game` is headless-only.
