# Verdicts

`PTD-move-advice` (design `specs/playtest/design/move-advice.md`), `Environment: Headless only` — no screenshots owed.
Build `b171a3f`, released scene graph, three repeats per phase (`logs/repeats.json`). Back to [`notes.md`](notes.md).

| Story | Statement | Verdict | Reading |
|-------|-----------|---------|---------|
| P1 | Evaluation arrives without a request action, deepens, ends on the backend cap | **Pass** | `advice_stream_reached_cap` first E1 120 ms; `updates_deepened` `+19 → +28 → +41`; `final_eval_at_cap` |
| P2 | The move shown is for the side to move; a local move clears it and the next position is evaluated | **Pass** | White `e2→e4 / 19`, Black `e7→e5 / −14`; `hud_move_cleared_advice`, `black_position_evaluated`, `re_evaluated_after_move` |
| P3 | A local move is not delayed by an in-flight stream; Off / end / leave / offline clear and stop | **Pass** | `hud_move_not_delayed` 28 ms, drag move applied with fields null; `c3_clears_advice` + `c3_stops_evaluation`, `game_end_cleared_advice`, `left_shared_game`, `connection_loss_marks_offline` |
| F1 | Advice appears in the Puzzle stream | **Not observed** | `puzzle_no_advice_request` false, `puzzle_advice_still_none` |
| F2 | A failed stream repeats `advice.error` on every poll / blocks play | **Not observed** | 1 served request in `peer-failure-*.jsonl`, `one_error_not_per_poll` `{"events":[]}`, `play_continues_offline` |

`move-advice` protocol verdict: **Pass**.
