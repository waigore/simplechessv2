# Graphical notes

Judged the same build as the headless twin: `main` at `4baccec`.

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove cold-open mode-pick → Shared C1 (commit Last mode) → shared-setup → Back → mode-pick with Shared Last mode → `show_save_failure` (S4) → Dismiss → S1.
- Captured 1280×720 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-last-mode-none.png` | Mode-pick S1 after cold open; Last mode none → Shared default highlight (`FL-mode-pick.N1`) |
| `02-after-commit-shared-setup.png` | After C1 commit; Shared setup options (Untimed / Increment / Advice) |
| `03-mode-pick-last-mode-shared.png` | Back on mode-pick; Shared Last-mode affordance after durable commit |
| `04-ex-save-failure.png` | `EX.save-failure`: “Save failed. Prior values kept.” + Dismiss; Shared · Last still shown |
| `05-dismiss-save-failure-s1.png` | Dismiss → S1; prior Last mode highlight retained |

Wave-1 scope matches the headless manifest. No protocol fail observed on the Last-mode / save-failure path.
