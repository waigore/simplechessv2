# Headless notes

Implementation evidence for #59 (shared-result screen and shared-session journey).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 13 passed (includes `shared_result_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 88.6% (2469/2787), threshold 80
- `godot --headless --path game -s res://shared_result_test.gd` — exit 0; `NAV.T6` / `NAV.T7` / `NAV.T8` TEL
- `godot --headless --path game` — smoke exit 0

## Scope

#59 owns `UI-shared-result` R1/R2/C1/C2/S1, Copy keys (incl. `shared_game`), `NAV.T7`/`T8`, `J-shared-session` S1–S4 + B1–B2, session reset (`PRG.F1` / `L-two-player-game.K3`), clocks stopped on result, `EX.interrupt` reopen at mode-pick, `UIS.M1` / no tournament chrome (`AES.P3`).

## Judgement

- **R1 copy**: resign (`END.L2`) → `result_black` + `shared_game` subtitle; title Game over.
- **Play again / Stop**: C1 → unlocked `shared-setup` (`NAV.T7`); C2 → `mode-pick` (`NAV.T8`).
- **Fresh session**: after Play again + Start, orthodox opening, White to move, selection cleared, clocks re-init, counters reset; finished clock does not carry.
- **Clocks**: `_finish` stops both; router `_process` does not tick on `shared-result`.
- **Journey**: S1–S4 walkable; B1 Play again; B2 Back from setup.
- **Interrupt**: cold-open path after mid-play drops session and lands mode-pick.

Display server was headless (`ENV.1`). Graphical twin deferred to acceptance.
