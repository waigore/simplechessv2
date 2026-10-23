# Results

Build `e022f83`, environment `ENV.1`. Back to [`notes.md`](notes.md); prep in [`setup.md`](setup.md).

## What happened

**S1, production path: fail.** The O1 leaves the client correctly — the peer logs the configured key, the start FEN, and `time_ms=2000` (the T6-missing default, `CMP-advice-client.R7`) — but no update ever reaches `GS.adviceBestMove`. Within 3 s the session reports `online=false` and play continues with no advice.

**S1, real backend: fail, same cause.** `logs/advice-backend.log` shows `advice_start … cap_ms=2000` and then `advice_end reason=cancel elapsed_ms=64 disconnected=True`: the backend streamed, and the client dropped it in under 100 ms.

**Root cause (`logs/transport-trace.log`).** `HTTPClient.STATUS_DISCONNECTED` is `0` in Godot 4.7.2 — the trace prints the enum. `game/advice_stream_transport.gd` `_read_stream` guards its disconnect branch with `elif status >= HTTPClient.STATUS_DISCONNECTED`, which matches **every** status. The mirrored exchange shows the sequence: `status_after_request=6` (`STATUS_REQUESTING`), first poll `status=6` judged `closed-by-transport`, and only then `status=7` (`STATUS_BODY`) with 1323 bytes arriving 40 ms later. So every stream whose first poll lands before the response body — i.e. normally — is closed, `AdviceWireReader.closed()` records `error`, and `FAIL.T1` marks the service offline. `AdviceStreamTransport` against both the simulated peer and the real backend ends `error` in 7–8 ms with 0 updates.

**S2–S5, playtest build with the simulated peer: pass.** With E1 pushed through `FakeAdviceTransport`, the session lifecycle behaves as specified: the update lands in `GS.adviceBestMove`/`GS.adviceEval`; a move applies in 26.7 ms and clears advice before the next poll; a new O1 carries the Black-to-move FEN and re-evaluates on `e7e5`/`-20`; a stale update from the cancelled stream is dropped (`I3`); Advice Off clears and stops; On restarts; resign clears (`X4`); leaving the Shared game stops evaluation (`R9`). Puzzle play state carries `advice: none` and the Shared-only gate refuses O1 outside Shared, Off, or offline. Telemetry carries `TEL.4`/`TEL.5` on every advice event.

Note for the playtest build itself: an unscripted `FakeAdviceTransport` never answers, so a headless run that does not push E1 by hand cannot see advice at all. That is a playtest-affordance gap introduced by #531, not by #374, and it is recorded here because it constrains how this protocol can be run.

**Observability (`logs/tel-flood.log`).** One failed stream is reported on every poll while the game stays in `shared-play`: 112 `advice.error` events across 60 frames (`AdviceClient._failed` is never cleared and `_poll_advice` re-reports it each tick). The log of a longer session floods.

## Judgement

Protocol `PTD-move-advice`: **fail**. S1 fails on the shipped path, so P3 does not hold. S2–S5 and the gate checks pass with the simulated peer; F1 and F2 are not observed. A defect is filed and linked from the acceptance comment.
