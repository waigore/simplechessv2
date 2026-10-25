# Driver — graphical run `20261025T015431Z`

Back to [`notes.md`](notes.md); the driver itself is [`logs/w550_sweep.gd`](logs/w550_sweep.gd).


This run reuses the #400 sweep driver (`../issue-400/headless-*/logs/w400_sweep.gd`) so its readings stay comparable, with these changes for #550:

- `_judge_ux()` runs the seven wave-2 UX protocols in the graphical kind too (the #400 driver stood them down there and judged display rows only).
- `_judge_puzzle_session()` judges the journey's cancel branch (`J-puzzle-session` US1.3) and labels the confirmed leave as US1.2, as the story does.
- `_judge_puzzle_stream()` K2 records the reset itself (sequence index, no `END.W1`, no next deal) and K3 records the `END.L4` score and the single next deal.
- `_judge_puzzle_screen()` reads the R2 result cue from `puzzle.result`.
- `_judge_exceptions()` drives `EX.save-failure` on a puzzle result.
- `_judge_g_wave2_shots()` adds `PTU-mode-pick` S6 and the leave/resign/save-failure shots.

No `specs/`, `game/`, `asset_catalog/` or `game_assets/` file changed: the driver lives in `logs/` and ran from `game/_w550/` in a detached worktree, never committed.
