# Prep

Build `ba6a59a`, environment `ENV.1`. Back to [`notes.md`](notes.md).

## Commands

```sh
# 1. import (fresh checkout)
godot --headless --path game --import --quit                     # logs/import.log

# 2. shipped graph
python3 .github/scripts/web_export.py --preset "Web Release"     # logs/export-release.log

# 3. protocol on the released scene graph, 3 repeats per phase
python3 logs/run_checks.py "$PWD" 3                             # logs/repeats.{json,log}

# 4. gates
GODOT_BIN="$(command -v godot)" python3 .github/scripts/gdscript_tests.py test    # logs/unit-tests.log
GODOT_BIN="$(command -v godot)" python3.11 .github/scripts/gdscript_tests.py coverage  # logs/coverage.log
gdlint game                                                      # logs/gdlint.log
gdformat --check game                                            # logs/gdformat-check.log
python3 .github/scripts/spec_lint.py                             # logs/spec-lint.log
```

`gdscript_tests.py coverage` needs `gdtoolkit==4.5.0` on the interpreter that runs it; on this machine that is `python3.11`, which is also the interpreter behind `gdlint` / `gdformat` (`4.5.0`).

## Probe design

`logs/drive.gd` (`R374_PHASE` = `advice` | `lifecycle` | `failure`):

- Loads `res://main_release.tscn`, asserts no `PlaytestSeams`, so `SessionRouter._advice_sim_factory()` is `null` and `AdviceClient` builds the shipped `AdviceStreamTransport`.
- Sets `router.advice_endpoint` / `advice_api_key` (T9/T10) and leaves `advice_time_ms` at the T6 default so the missing-T6 row of B3 is exercised.
- Drives `mode-pick` C1 → `shared-setup` C5, then `shared-play` C3/C4/`confirm`, `shared-result` C2, and `mode-pick` C2 for the Puzzle stream.
- Board input is driven through `Presentation.handle_gui_input` with `InputEventScreenTouch` / `InputEventScreenDrag` at `BoardPresentation.world_to_screen(square_center)` — the same projection the shipped HUD uses.
- Counts streams from `AdviceClient._stream_id` rather than from the peer's log file, because the peer is a separate process and its log lags the running request.
- Ends each phase by leaving the Shared game, joining the transport worker thread, and clearing the scene before `quit`, so the exit is clean.

`logs/peer.py` (`--mode normal|fail`, `--fail-count N`): a chunked-NDJSON `CTR-advice-stream` peer on loopback. `normal` sends three deepening E1s for the side to move and then E2 `{"reason":"cap"}` at 700 ms; `fail` answers the first N requests with a 500 and then behaves as `normal`. It logs every request (key, FEN, `time_ms`, authorisation) so the run shows what O1 actually carried. No Stockfish, no UCI.
