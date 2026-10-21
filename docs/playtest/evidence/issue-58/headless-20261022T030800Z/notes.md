# Headless notes

Implement session for #58 (shared-play board interaction, status, resign).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 12 passed (includes `shared_play_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 85.9% (2260/2630), threshold 80
- `godot --headless --path game` — smoke exit 0; `TEL.1`–`TEL.5` present

## Scope

#58 owns `UI-shared-play` C1/C2/C4, S1/S2, B2/B3/B10, R1/R2/R4, resign → `END.L2` → `NAV.T6`, Advice `F-move-advice.R2` stub. Deferred: last-rank/`S4`, refuse flash/`S5`, deselect, draw-offer (#94); full result journey (#59); `PHY.M5` (#56).

## Judgement

- **Select / place / refuse**: `shared_play_test` — C1 select, legal marks, C2 place clears selection; illegal keeps selection and side to move; last-rank without promotion refuses (no auto-queen).
- **B10**: place without prior selection via `handle_input_commit(from, to)`.
- **Resign / NAV.T6**: C4 → S2; Cancel → S1; Confirm → `shared-result` with `result_black` after White resign; C1/C2 inert in S2.
- **Advice stub**: C3 toggles `GS.advice`; snapshot has no eval / best-move marks.
- **Clocks**: Blitz shows tabular `W m:ss · B m:ss` in R2.

Display server was headless (`ENV.1`). Graphical twin deferred to acceptance.
