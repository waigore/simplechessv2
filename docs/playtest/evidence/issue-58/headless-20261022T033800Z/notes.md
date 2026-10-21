# Headless notes

Verification-fix follow-up for #58 (shared-play board interaction, status, resign). Addresses findings from the prior fail on merged PR #320.

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 12 passed (includes gesture-level `shared_play_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 88.4% (2406/2721), threshold 80
- `godot --headless --path game -s res://shared_play_test.gd` — exit 0; `TEL.1`–`TEL.5` with outcome-valued `TEL.5`
- `godot --headless --path game` — smoke exit 0

## Scope

#58 owns `UI-shared-play` C1/C2/C4, S1/S2, B2/B3/B10, R1/R2/R4, resign → `END.L2` → `NAV.T6`, Advice `F-move-advice.R2` stub. Deferred: last-rank/`S4`, refuse flash/`S5`, deselect, draw-offer (#94); full result journey (#59). `PHY.M5` drawing stays on #56; this run asserts bad-drop still calls `end_drag_illegal`.

## Judgement

- **B2 / B3 / B10**: pointer-level tests — tap own piece changes selection while selected; tap destination places; pick-and-drag without prior selection places (`InputEventScreenTouch` / `ScreenDrag` past 12 px).
- **PHY.M5**: off-board drag sets `last_return_s` to `TRAVEL_S` via `end_drag_illegal` (not instant `cancel_drag`).
- **Resign / NAV.T6**: C4 → S2 with `board_unavailable`; Cancel → S1; Confirm → `shared-result` / `result_black`.
- **S2 clock**: side-to-move clock still ticks while confirm is open; gestures blocked.
- **Pause**: `_process` and controls ignore advances while seams paused; pointers ignored.
- **Layout**: board `offset_top` reserves chrome at 720×1280 and 800×450.
- **Advice stub**: C3 toggles; snapshot has no eval / best-move.
- **Orchestration**: select / place / resign / advice live on `SharedGameSession`; router navigates and emits chrome.

Display server was headless (`ENV.1`). Graphical twin deferred to acceptance.
