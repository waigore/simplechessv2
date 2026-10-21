# Graphical notes

Judged the same playable build as the headless twin for #94 verification fixes.

## Prep

- Godot 4.7.2 playtest session on macOS Aqua (OpenGL Compatibility / Apple M5 Metal). `DISPLAY=macOS` in the capture log.
- Drove shared-play choice states: select → B8 clear → B9 empty non-destination → S5 refuse flash → S4 promote chooser → resign restart → S6 draw panel → Accept → shared-result (`END.D2`).
- Captured 720×1280 viewport PNGs into `screenshots/`.

## Judgement

| Screenshot | Judged state |
|------------|--------------|
| `01-shared-play-s1.png` | S1 default; White to move; Advice / Resign / Offer draw |
| `02-selection-legal.png` | e2 selected (PAL.C6); legal marks on e3/e4 |
| `03-deselect-cleared.png` | After B8/IN.deselect; selection and legal marks gone |
| `04-b9-empty-deselect.png` | After empty non-destination clear; no S5 flash |
| `05-reject-flash-s5.png` | S5: PAL.C8 rim on refused square; selection + legal marks remain |
| `06-promote-s4.png` | S4 “Choose promotion”; Q/R/B/N at destination e8 |
| `07-draw-offer-s6.png` | S6 shared panel Accept / Decline / Withdraw; board still shown |
| `08-draw-accepted-result.png` | shared-result after Accept (`END.D2`) |

No protocol fail for in-scope UX steps. Headless twin covers session ops, clocks, and gesture suites.
