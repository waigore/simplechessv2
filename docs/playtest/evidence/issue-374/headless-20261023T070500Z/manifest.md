# Manifest

- **Issue**: 374
- **Environment**: headless (`ENV.1`), Godot 4.7.2.stable.official.ed1daf0bf
- **Build / session id**: default branch `origin/main` at `e022f83` (deliverable #518 is `ec3fa86`; `game/advice_stream_transport.gd` and `game/advice_wire_reader.gd` are byte-identical to the verified build `289bce8`). Probe `TEL.3`: `sess-1792739149930-1771677-playtest`.
- **Coverage mode**: full, intersected with issue scope: `PTD-move-advice` (Design, headless only). The protocol says no screenshots, so this headless folder is the whole requirement.
- **Peers**: `logs/accept-374-peer.py` (simulated `CTR-advice-stream` wire over HTTP, ADR-0002 Testability) and the real `advice_backend` (#373) with `logs/fake_stockfish.py` as its stand-in engine. No Stockfish and no host deployment; #112 does not gate this task.
- **Scripts run**: `logs/accept-374-probe.gd` (protocol drive), `logs/accept-374-transport-trace.gd` (client-transport root cause), `logs/accept-374-tel-flood.gd` (observability side-check).

## Results

| Protocol / step | Result | Evidence |
|-----------------|--------|----------|
| `PTD-move-advice` S1 — production path, simulated peer over HTTP | **fail** | `logs/accept-374-probe.log` (`prod waited_ms=3002 best=<null> online=false`), `logs/peer-normal.jsonl` (O1 arrived with the right key / FEN / `time_ms`) |
| `PTD-move-advice` S1 — real #373 backend over HTTP | **fail** | `logs/transport-trace.log` (0 updates, `ended=error` in 8 ms), `logs/advice-backend.log` (backend saw the request, then `reason=cancel … disconnected=True`) |
| `PTD-move-advice` S2 — move never waits | pass (simulated peer) | `move_ms=26.671`, turn changed, advice cleared before the next poll |
| `PTD-move-advice` S3 — clear then re-evaluate | pass (simulated peer) | new O1 with ` b ` FEN, `e7e5` / `-20` applied |
| `PTD-move-advice` S4 — Off / offline clears | pass (simulated peer) | `C3` Off cleared, no new O1; On restarted |
| `PTD-move-advice` S5 — Puzzle stream never | pass | `puzzle_advice=none`; Shared-only gate refuses O1 |
| Root cause — shipped client transport | reproduced | `logs/transport-trace.log` |
| Observability — one failure, many events | fail | `logs/tel-flood.log` (112 events in 60 frames) |
| Unit tests | pass | `logs/unit-tests.log` (19 scripts) |
| Coverage | pass | `logs/coverage.log` (86.8%, threshold 80) |
| Code lint | pass | `logs/lint.log` (`gdlint`, `gdformat --check`) |
| Spec lint | pass | `logs/spec-lint.log` (0 errors, 1 pre-existing warning) |

## Paths

- `notes.md`, `setup.md`, `results.md`, `verdicts.md`
- `logs/accept-374-probe.log`, `logs/accept-374-probe.gd`
- `logs/transport-trace.log`, `logs/accept-374-transport-trace.gd`
- `logs/tel-flood.log`, `logs/accept-374-tel-flood.gd`
- `logs/peer-normal.jsonl`, `logs/accept-374-peer.py`, `logs/fake_stockfish.py`
- `logs/advice-backend.log`
- `logs/import.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/lint.log`, `logs/spec-lint.log`
