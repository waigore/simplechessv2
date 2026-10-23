# Prep and probe

Build `e022f83`, environment `ENV.1`. Back to [`notes.md`](notes.md).

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `GODOT_BIN=… python3 .github/scripts/gdscript_tests.py test` — 19 scripts pass (`logs/unit-tests.log`)
- `… gdscript_tests.py coverage` — 86.8% (threshold 80), gdtoolkit 4.5.0 (`logs/coverage.log`)
- `gdlint game`, `gdformat --check game` — clean (`logs/lint.log`)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`logs/spec-lint.log`)
- Simulated peer: `python3 accept-374-peer.py --port 18491` (logs every O1 it receives). Real backend: `ADVICE_API_KEY=accept-key ADVICE_PORT=18492 STOCKFISH_PATH=./fake_stockfish.py python3 -m advice_backend`.

## Probe

The probe drives the real `Presentation`/`SessionRouter` player paths (`mode-pick` `C1` → `shared-setup` `C5`, `shared-play` `C3`/`C4`/`confirm`, `shared-result` `C2`, `handle_input_commit`) and reads `DBG.2` state plus `TEL.*` from the playtest seams. It does not reuse `game/advice_client_test.gd` assertions.

Two paths were driven, because on `e022f83` the playtest build replaces the network transport with the in-process simulated peer (`SessionRouter._advice_sim_factory` → `FakeAdviceTransport`), while the shipped export has no seam node and keeps `AdviceStreamTransport`:

1. **Production path** — the probe instantiates `main.tscn` with the `PlaytestSeams` node removed, so the router builds the real transport and talks to the simulated peer over HTTP.
2. **Playtest build** — the seams stay; the probe pushes E1 updates through the simulated peer by hand, the way ADR-0002 Testability intends ("client mocks backend"), to judge the session lifecycle.
