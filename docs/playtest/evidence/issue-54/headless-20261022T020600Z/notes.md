# Notes

Headless acceptance playtest for #54 against merged `main` (Godot 4.7.2). Position setups use `load_position` / `start_opening` on `CMP-chess-rules` / `CMP-shared-game-session` (`SIT.1` / DBG.3 equivalents). Live clock expiry (`PTD-end-conditions` S4) and puzzle endings (S5) are out of scope per the issue body.

## PTD-end-conditions

- **S1**: Mating move from a loaded checkmate setup yields `END.L1`; `result_copy_key()` is `result_white` when Black is mated (side to move loses).
- **S2**: Resign as the side to move yields `END.L2` and stops clocks (`clocks_stopped`). Separate case with that side’s clock already at zero still yields `END.L2`, never `END.D5`.
- **S3**: Stalemate move yields `END.D1`; draw offer + accept yields `END.D2`. `END.D3` / `END.D4` covered at rules level (`ChessRulesEndTest`: third occurrence; 100th half-move; capture does not clear D3 history; pawn clears D4).

## END.P1 (non-clock)

- Ordered `elif` in `end_signals()`: L1 → D1 → D3 → D4. Named tests: L1 before D1, L1 before D4.
- After a position ending, `accept_draw()` is refused (D2 does not override L1).

## Session handoff

- Every owned ending sets F6 (`game_ended` + reason), clears the draw offer, sets `clocks_stopped`, and refuses further moves.
- Result classification uses only `result_white` / `result_black` / `result_draw`. Domain code does not emit `TEL.4` / `TEL.5`.

## Spec deliverable

- `SCH-play-state` F8/F9 and `fields-play-end.md` with story coverage and index rows (PR #301) present; `spec_lint.py` reports 0 errors.

## Suite

`python3 .github/scripts/gdscript_tests.py test` — 10 headless unit tests passed. Coverage 91.0% (1316/1446). Focused scripts `chess_rules_end_test.gd` and `shared_game_session_test.gd` exit 0.
