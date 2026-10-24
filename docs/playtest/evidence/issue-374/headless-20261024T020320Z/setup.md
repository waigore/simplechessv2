# Setup

Build `b171a3f`, environment `ENV.1`. Back to [`notes.md`](notes.md).

## Commands

```sh
# 1. import (fresh checkout)
godot --headless --path game --import --quit                     # logs/import.log

# 2. shipped graph
python3 .github/scripts/web_export.py --preset "Web Release"     # logs/export-release.log

# 3. protocol on the released scene graph, 3 repeats per phase
python3 docs/playtest/evidence/issue-374/headless-20261024T020320Z/logs/run_checks.py \
  "$PWD/docs/playtest/evidence/issue-374/headless-20261024T020320Z" 3   # logs/repeats.{json,log}

# 4. advice suite with the transport peer armed (hermetic in CI without it)
python3 .../logs/peer.py --port 8792 --mode normal --key k --fail-count 0 --log .../logs/peer-unit.jsonl &
ADVICE_STREAM_PEER=127.0.0.1:8792 godot --headless --path game --script res://advice_client_test.gd
                                                                 # logs/advice-suite-peer.log

# 5. gates
GODOT_BIN="$(command -v godot)" python3 .github/scripts/gdscript_tests.py test      # logs/unit-tests.log
GODOT_BIN="$(command -v godot)" python3.11 .github/scripts/gdscript_tests.py coverage  # logs/coverage.log
gdlint game                                                      # logs/gdlint.log
gdformat --check game                                            # logs/gdformat-check.log
python3 .github/scripts/spec_lint.py                             # logs/spec-lint.log
```

## Probe design

Unchanged from [`../headless-20261023T220603Z/logs`](../headless-20261023T220603Z/logs) — `drive.gd`, `peer.py` and `run_checks.py` are byte-identical copies, so this run reads the same protocol on the post-#711 build:

- `drive.gd` loads `res://main_release.tscn` and asserts no `PlaytestSeams`, so `AdviceClient` builds the shipped `AdviceStreamTransport`. T6 (`advice_time_ms`) is left unset to exercise B3's 2000 default.
- `peer.py` is a loopback chunked-NDJSON `CTR-advice-stream` peer (E1 deepening, then E2 `cap`), not Stockfish; it logs key / FEN / `time_ms` / authorisation per O1.
- `run_checks.py` starts one fresh peer per phase (`advice`, `lifecycle`, `failure`), runs the probe, and stops the peer.

`gdscript_tests.py coverage` needs `gdtoolkit==4.5.0`; on this machine that is `python3.11`, which is also behind `gdlint` / `gdformat` (`4.5.0`).
