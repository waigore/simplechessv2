# Graphical notes

Re-capture after the S4 chrome layout fix for #94 (verification fail on PR #369).

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Viewport 720×1280. Drove shared-play choice states: select → clear → empty deselect → S5 refuse flash → S4 promote chooser (board-only) → resign restart → S6 draw panel → Accept → shared-result (`END.D2`).
- Captured PNGs into `screenshots/`.

## Layout fix under test

C6 focus stops are off-strip invisible sentinels (same pattern as C1/C2/C10). The visible promotion chooser stays on the board via `BoardPresentation.show_promotion_choice`. No chrome promote row or "Choose promotion" label, so PlayChrome never grows into `PLAY_CHROME_TOP_PX` / R1.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-play-s1.png` | S1 default; White to move; Advice / Resign / Offer draw |
| `02-selection-legal.png` | e2 selected; legal marks |
| `03-deselect-cleared.png` | After C10 / IN.deselect; selection and legal marks gone |
| `04-b9-empty-deselect.png` | After empty non-destination clear; no S5 flash |
| `05-reject-flash-s5.png` | S5: PAL.C8 rim on refused square |
| `06-promote-s4.png` | S4 board chooser Q/R/B/N at e8; chrome strip unchanged (no promote row over R1) |
| `07-draw-offer-s6.png` | S6 shared panel Accept / Decline / Withdraw; board still shown |
| `08-draw-accepted-result.png` | shared-result after Accept (`END.D2`) |

No protocol fail for in-scope UX steps. Headless twin covers chrome-in-reserve assertions for S1/S4/S6 timed and untimed.
