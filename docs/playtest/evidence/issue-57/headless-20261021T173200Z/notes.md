# Headless notes

Judged `main` at `7cad9d1` (includes #290 entry spine and #295 UIS.M1–M3 / B7 remediations).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 7 passed (includes `entry_spine_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 93.2% (1123/1205), threshold 80
- `godot --headless --path game` — smoke exit 0; jump → `mode-pick`, inspect, pause/resume; `TEL.1`–`TEL.5` present (`TEL.3` `sess-1792603972073-83360-playtest`)
- `godot --headless --path game -s res://entry_spine_test.gd` — exit 0

## Scope

Wave-1 entry spine only. Issue AC and body omit `UI-mode-pick.C2` (Puzzle stream, Wave 2). Shared-play board controls and Advice offline / illegal-move exception paths belong to #58. Verification pass already recorded that acceptance needs this scoped run.

## Judgement

- **PTU-mode-pick**: S1 Shared → setup; S3 Last-mode highlight on Shared when none; S4 locale `en`→`zh-Hant`→`ja`→`en` with R3 own-name and immediate copy apply. S2 N/A.
- **PTU-shared-setup**: four options; Increment unavailable when Untimed and inert when activated; Start locks into shared-play stub; Back returns to mode-pick.
- **PTU-navigation**: `NAV.T1`/`T3`/`T4`/`T5` and cold-open loading → mode-pick. Puzzle transitions N/A.
- **PTU-controls**: entry bindings (focus order, unavailable inert, B7 hover on Confirm/Cancel/Dismiss) pass via `entry_spine_test`. Board IN stories N/A (#58).
- **PTU-exceptions**: quit Confirm / Cancel (S3) pass; S1/S2 N/A (#58). Save-failure S4 panel exists (persist drive #61).

Display server was headless (`ENV.1`). Screenshots deferred to the graphical twin folder for the same build id.
