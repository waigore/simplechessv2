# Headless notes

Acceptance playtest for #374 (client advice streaming) on `origin/main` `e022f83`. Run in a session that posted neither the implementation summary nor the verification comment.

## Scope

#374 changes playable behavior: advice must appear automatically in a Shared game while Advice is On and online. The intersect with `full` coverage is `PTD-move-advice` (Design, headless only; the protocol says no screenshots). UI chrome, `EX.error`, and the UX protocols belong to #375, so no UX protocol is in scope.

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `GODOT_BIN=… python3 .github/scripts/gdscript_tests.py test` — 19 scripts pass (`logs/unit-tests.log`)
- `… gdscript_tests.py coverage` — 86.8% (threshold 80), gdtoolkit 4.5.0 (`logs/coverage.log`)
- `gdlint game`, `gdformat --check game` — clean (`logs/lint.log`)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`logs/spec-lint.log`)
- Simulated peer: `python3 accept-374-peer.py --port 18491` (logs every O1 it receives). Real backend: `ADVICE_API_KEY=accept-key ADVICE_PORT=18492 STOCKFISH_PATH=./fake_stockfish.py python3 -m advice_backend`.

The probe drives the real `Presentation`/`SessionRouter` player paths (`mode-pick` `C1` → `shared-setup` `C5`, `shared-play` `C3`/`C4`/`confirm`, `shared-result` `C2`, `handle_input_commit`) and reads `DBG.2` state plus `TEL.*` from the playtest seams. It does not reuse `game/advice_client_test.gd` assertions.

Two paths were driven, because on `e022f83` the playtest build replaces the network transport with the in-process simulated peer (`SessionRouter._advice_sim_factory` → `FakeAdviceTransport`), while the shipped export has no seam node and keeps `AdviceStreamTransport`:

1. **Production path** — the probe instantiates `main.tscn` with the `PlaytestSeams` node removed, so the router builds the real transport and talks to the simulated peer over HTTP.
2. **Playtest build** — the seams stay; the probe pushes E1 updates through the simulated peer by hand, the way ADR-0002 Testability intends ("client mocks backend"), to judge the session lifecycle.

## What happened

**S1, production path: fail.** The O1 leaves the client correctly — the peer logs the configured key, the start FEN, and `time_ms=2000` (the T6-missing default, `CMP-advice-client.R7`) — but no update ever reaches `GS.adviceBestMove`. Within 3 s the session reports `online=false` and play continues with no advice.

**S1, real backend: fail, same cause.** `logs/advice-backend.log` shows `advice_start … cap_ms=2000` and then `advice_end reason=cancel elapsed_ms=64 disconnected=True`: the backend streamed, and the client dropped it in under 100 ms.

**Root cause (`logs/transport-trace.log`).** `HTTPClient.STATUS_DISCONNECTED` is `0` in Godot 4.7.2 — the trace prints the enum. `game/advice_stream_transport.gd` `_read_stream` guards its disconnect branch with `elif status >= HTTPClient.STATUS_DISCONNECTED`, which matches **every** status. The mirrored exchange shows the sequence: `status_after_request=6` (`STATUS_REQUESTING`), first poll `status=6` judged `closed-by-transport`, and only then `status=7` (`STATUS_BODY`) with 1323 bytes arriving 40 ms later. So every stream whose first poll lands before the response body — i.e. normally — is closed, `AdviceWireReader.closed()` records `error`, and `FAIL.T1` marks the service offline. `AdviceStreamTransport` against both the simulated peer and the real backend ends `error` in 7–8 ms with 0 updates.

**S2–S5, playtest build with the simulated peer: pass.** With E1 pushed through `FakeAdviceTransport`, the session lifecycle behaves as specified: the update lands in `GS.adviceBestMove`/`GS.adviceEval`; a move applies in 26.7 ms and clears advice before the next poll; a new O1 carries the Black-to-move FEN and re-evaluates on `e7e5`/`-20`; a stale update from the cancelled stream is dropped (`I3`); Advice Off clears and stops; On restarts; resign clears (`X4`); leaving the Shared game stops evaluation (`R9`). Puzzle play state carries `advice: none` and the Shared-only gate refuses O1 outside Shared, Off, or offline. Telemetry carries `TEL.4`/`TEL.5` on every advice event.

Note for the playtest build itself: an unscripted `FakeAdviceTransport` never answers, so a headless run that does not push E1 by hand cannot see advice at all. That is a playtest-affordance gap introduced by #531, not by #374, and it is recorded here because it constrains how this protocol can be run.

**Observability (`logs/tel-flood.log`).** One failed stream is reported on every poll while the game stays in `shared-play`: 112 `advice.error` events across 60 frames (`AdviceClient._failed` is never cleared and `_poll_advice` re-reports it each tick). The log of a longer session floods.

## Judgement

Protocol `PTD-move-advice`: **fail**. S1 fails on the shipped path (no best move or eval is produced against a reachable service, and a healthy service is reported offline), so P3 does not hold. S2–S5 and the gate checks pass with the simulated peer; F1 and F2 are not observed. A defect is filed and linked from the acceptance comment.
