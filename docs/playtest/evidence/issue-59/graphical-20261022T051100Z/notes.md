# Graphical notes

Judged the same playable build as the headless twin: commit `e4d9e94` (PR #350), worktree also includes the #354 evidence-manifest commit.

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove `J-shared-session`: mode-pick → shared-setup → Start → shared-play → resign confirm → shared-result → Play again → Back → mode-pick; then Stop path (resign → Stop → mode-pick).
- Captured 720×1280 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-n1.png` | N1 cold open; “Choose how to play”; Quit + English |
| `02-shared-setup.png` | Shared setup after C1; options unlocked |
| `03-shared-play.png` | After Start; orthodox opening; “White to move”; Advice On + Resign |
| `04-shared-result.png` | After resign (`END.L2`); “Game over”; “Black wins”; “Shared game”; Play again + Stop; no tournament chrome |
| `05-play-again-setup.png` | After C1 Play again (`NAV.T7`); unlocked shared-setup (Clock · Untimed; Advice · On; Start / Back) |
| `06-mode-pick-after-back.png` | B2 Back from setup → mode-pick |
| `07-mode-pick-after-stop.png` | N2 after Stop (`NAV.T8`) → mode-pick; session dropped |

No protocol fail for in-scope UX steps. Headless twin already covered copy-key mapping, session reset, clocks stopped, and interrupt.
