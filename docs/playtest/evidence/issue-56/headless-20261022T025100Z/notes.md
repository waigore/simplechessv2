# Headless notes

Judged `main` at `e080596` (includes merged #307 / #311 board presentation). Fresh accept session; did not post the implementation summaries.

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 11 passed (includes `board_presentation_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 88.5% (1862/2105), threshold 80
- `godot --headless --path game` — smoke exit 0; `TEL.1`–`TEL.5` present (`TEL.3` `sess-1792608919665-74585-playtest`)
- `godot --headless --path game -s res://board_presentation_test.gd` — exit 0
- `godot --headless --path game -s res://entry_spine_test.gd` — exit 0
- One-shot ENV.1 drive (mode-pick → setup → Start → board; seat flip; O2 marks) — exit 0

## Scope

#56 owns `CMP-presentation` board, camera, pieces, `SPC.L4` selection/legal marks, and `PHY.M5` drawing. View stories are out of the playtest coverage set; geometry / seat / timing / mark budgets are judged by `board_presentation_test` and the AC scorecard.

In-scope UX intersection: `PTU-shared-session` S1 (reaches shared-play with a real board) and `PTU-shared-play` S4 (coordinates / R1 board affordances). Board `IN` / resign / Advice paths stay on #58; bad-drop clear on #94.

## Judgement

- **PTU-shared-session S1**: C1 → shared-setup → C5 Start → `shared-play` with `BoardPresentation` visible; L1–L4 layers present; ≥16 coordinate chips.
- **PTU-shared-play S4**: Rank/file labels on outer edges; Bottom seat rotation 0; Top seat applies `CAM-board.M2` (π).
- **Marks via O2**: Selection `Line2D` visible; `LegalMarks` children for `e2` targets — without emitting `E1` / playing cues.
- **Unit AC proxies**: Framing 9:16–16:9, safe area, travel/return/settle wall-clock budgets, promotion inside `TRAVEL_S`, O2 post-apply animate path — all green in `board_presentation_test`.
- **Contrast / area (re-derived)**: full-opacity `PAL.C6` and `PAL.C11` vs C1/C2 = 2.008:1; C9 on C10 = 12.7:1; empty diamond area 0.259; capture ring ink ≈0.251.

Display server was headless (`ENV.1`). Screenshots deferred to the graphical twin folder for the same build id.
