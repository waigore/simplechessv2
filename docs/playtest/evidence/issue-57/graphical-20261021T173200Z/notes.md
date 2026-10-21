# Graphical notes

Judged the same build as the headless twin: `main` at `7cad9d1`.

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove mode-pick → locale cycle → quit confirm → shared-setup (Untimed then Blitz) → Start → shared-play stub.
- Captured 1280×720 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-mode-pick-s1.png` | Mode-pick S1; title “Choose how to play”; Quit + English (R3); Shared C1 present (Last-mode default); playtest DBG panel |
| `02-mode-pick-locale-zh.png` | After C4; R3 shows 繁體中文; still on mode-pick |
| `03-mode-pick-quit-confirm.png` | EX.confirm “End this session?” with Confirm / Cancel |
| `04-shared-setup.png` | Shared setup options; Clock · Untimed; Increment · 3 s; Advice · On |
| `05-shared-setup-blitz.png` | After C2; Clock · Blitz (Increment available) |
| `06-shared-play-stub.png` | After Start; shared-play stub label (board play is #58) |

Wave-1 scope matches the headless manifest (no Puzzle C2; no board IN / Advice-offline / illegal-move paths). No protocol fail observed on the rendered entry spine.
