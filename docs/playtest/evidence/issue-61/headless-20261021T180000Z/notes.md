# Headless notes

Judged `main` at `4baccec` (includes PR #299 Last mode persistence + save-failure).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 10 passed (includes `persist_store_test.gd`, `entry_spine_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 91.0% (1316/1446), threshold 80
- `godot --headless --path game` — smoke exit 0; `TEL.1`–`TEL.5` present (`TEL.3` `sess-1792605530328-11464-playtest`)
- `godot --headless --path game -s res://persist_store_test.gd` — exit 0 (forced write failure expected in log)
- `godot --headless --path game -s res://entry_spine_test.gd` — exit 0

## Scope

Wave-1 Last mode persistence and `EX.save-failure` only. Issue AC names design protocol `game-state` and UX protocol `exceptions` for the save-failure path. Board play fields, puzzle result Elo / recent-solved commits, Advice-offline, and illegal-move exceptions stay with later tasks (#58 / Wave 2). Locale and quit-confirm were accepted on #57.

## Judgement

- **PTD-game-state P2 / persist slice**: successful commit + reload restores `last_mode=shared`; forced write failure leaves prior bytes and committed snapshot; cleared storage returns `none`; corrupt/missing fields fall back to defaults; session roundtrip reloads Shared Last mode. Wave-2 `player_elo` / `recent_solved` slots present and preserved.
- **PTD-mode-and-config S1**: cold-open load feeds mode-pick R1; Shared is default highlight when Last mode is none (`FL-mode-pick.N1`).
- **PTU-mode-pick S3**: after C1 commit, Last mode is Shared; highlight / `· Last` affordance driven from persisted document.
- **PTU-exceptions `EX.save-failure`**: forced failure emits `write_failed` → mode-pick S4; Dismiss → S1 with prior Last mode intact (`entry_spine_test` save-failure path).

Display server was headless (`ENV.1`). Screenshots deferred to the graphical twin folder for the same build id.
