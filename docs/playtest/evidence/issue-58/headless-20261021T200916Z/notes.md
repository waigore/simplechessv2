# Headless notes

Acceptance playtest for #58 on the merged build that includes layout/focus fixes (#337 / `576242f`) and later `main` tip `fff626b`.

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 12 passed (gesture-level `shared_play_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 88.4% (2444/2766), threshold 80
- `godot --headless --path game -s res://shared_play_test.gd` — exit 0; `TEL.1`–`TEL.5` with outcome-valued `TEL.5`
- `godot --headless --path game` — smoke exit 0

## Scope

#58 owns `UI-shared-play` C1/C2/C4, S1/S2, B2/B3/B10, R1/R2/R4, resign → `END.L2` → `NAV.T6`, Advice `F-move-advice.R2` stub. Deferred: last-rank/`S4`, refuse flash/`S5`, deselect, draw-offer (#94); full result journey (#59).

## Judgement

- **B2 / B3 / B10**: pointer-level tests pass (tap own piece changes selection; tap destination places; pick-and-drag without prior selection places).
- **PHY.M5**: off-board drag runs `end_drag_illegal` (`last_return_s` = `TRAVEL_S`).
- **Resign / NAV.T6**: C4 → S2 with `board_unavailable`; Cancel → S1; Confirm → `shared-result` / `result_black`.
- **S2 clock**: side-to-move clock still ticks while confirm is open; gestures blocked.
- **Pause**: ticks and controls halt while seams paused.
- **Layout / focus**: 16:9 and 9:16 keep every corner square visible; focus order C1→C2→C3→C4.
- **Advice stub**: C3 toggles; snapshot has no eval / best-move.
- **PTD-shared-game**: covered by shared session + rules unit suite (untimed start, legal/illegal place, timed clock, resign end).

Display server was headless (`ENV.1`). Graphical twin under `../graphical-20261021T200916Z/`.
