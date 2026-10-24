# Results

Build `b171a3f`, released scene graph, three repeats per phase. Back to [`notes.md`](notes.md).
Raw lines: `logs/drive-*-N.log` (`R374 {...}`); request rows: `logs/peer-*.jsonl`; summary: `logs/repeats.json`.

| Measurement | Worst of 3 | Source |
|-------------|-----------|--------|
| First E1 after C5 | 120 ms | `drive-advice-1.log` `advice_stream_reached_cap` |
| E1 progression on one stream | `+19 → +28 → +41` cp, E2 `cap` at 41 | `updates_seen` / `final_eval_at_cap` |
| HUD click-to-move while streaming | 28 ms | `drive-lifecycle-*.log` `hud_move_not_delayed` |
| `advice.error` per failed stream | 1 served request, `{"events":[]}` on the next poll | `peer-failure-*.jsonl`, `one_error_not_per_poll` |
| O1 `time_ms` (T6 unset) | 2000, every request | `repeats.json` |
| O1 authorisation | `authorized: true`, key `accept-key`, start FEN | `repeats.json` |
| Repeats | 9/9 `exit: 0`, `failed: 0` (16 + 28 + 9 checks) | `repeats.json` |
| Bundle probe | 0 matches for `stockfish` / `bestmove` / `uci` in `build/web/index.pck` | this run |
| Unit tests | 26 suites pass | `logs/unit-tests.log` |
| Coverage | 86.4% (4478/5180), threshold 80 | `logs/coverage.log` |
| Lint / format | `gdlint` clean, `gdformat --check` clean | `logs/gdlint.log`, `logs/gdformat-check.log` |
| `Spec lint` (evidence included) | 0 errors / 1 pre-existing glossary warning | `logs/spec-lint.log` |
| Transport peer armed | advice suite passes with `ADVICE_STREAM_PEER` set (2 E1/E2 requests, no skips) | `logs/advice-suite-peer.log`, `logs/peer-unit.jsonl` |

Per-phase checks (all `ok: true`), from `logs/drive-lifecycle-1.log` and `logs/drive-failure-1.log`:

- lifecycle — `advice_shown_before_move` (White `e2→e4 / 19`), `hud_move_not_delayed` (28 ms, side→black), `hud_move_cleared_advice`, `black_position_evaluated` (`e7→e5 / −14`), `drag_move_not_delayed`, `c3_clears_advice`, `c3_stops_evaluation`, `c3_on_restarts`, `game_end_cleared_advice`, `left_shared_game`, `puzzle_no_advice_request`, `puzzle_advice_still_none`.
- failure — `connection_loss_marks_offline` (`online=false`), `loss_clears_advice` (both fields null), `play_continues_offline` (side→black), `one_error_not_per_poll`.
