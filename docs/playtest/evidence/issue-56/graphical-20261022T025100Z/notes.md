# Graphical notes

Judged the same build as the headless twin: `main` at `e080596` (Godot 4.7.2).

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove mode-pick → Shared setup → Start → shared-play; then O2 Top seat; then O2 selection on e2 with legal diamonds.
- Captured 1280×720 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-play-bottom.png` | Opening position; White at Bottom; file letters a–h and ranks 1–8 on outer edges; full 8×8 in frame with cafe letterbox; playtest DBG panel |
| `02-shared-play-top-flip.png` | After Top seat O2; White pieces toward Top of frame (180° about center); coordinates remain readable on edges |
| `03-shared-play-selection-legal.png` | e2 selection frame in `PAL.C6`; empty-target diamonds in `PAL.C11` on e3/e4; piece silhouettes remain readable |

No protocol fail for the in-scope UX steps. Board `IN` / resign remain #58.
