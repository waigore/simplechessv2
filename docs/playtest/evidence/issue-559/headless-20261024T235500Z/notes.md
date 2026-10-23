# Notes — #559 advice readiness

## What was judged

- **Readiness (AC1).** Five independent streams. `start()` returns before the client
  reads anything (0 polls, 0 messages) and the E1 becomes readable only on the next
  `poll()`; readiness is `AdviceClient.elapsed_ms()` at the `apply_update` that fires
  on that poll, against the configured `T6` (1500 ms). Worst 12 ms. The 250 ms
  ceiling rejects a timer-produced number; the 1 ms floor rejects a delivery that
  slipped inside `start`.
- **Never-delay (AC2).** The shipped `SharedGameSession.place` runs five legal moves
  (e4 e5 Nf3 Nc6 Bc4) with a permanently silent peer. Every move applies, flips the
  turn, reissues O1, and takes 0 ms against a 40 ms ceiling; `poll()` returns empty
  and the stream answers nothing 250 ms later.
- **`T6` agreement (AC3).** The recorded O1 request is the source: `time_ms` equals
  `T6` for 500 / 1200 / 1500 / 2000 / 5000, and 2000 for `-1` / 0 / 499 / 5001 /
  9999 (`R7`, `B3`).

## Design choices

- **A test-side peer.** `DeferredAdviceTransport` sits next to `FakeAdviceTransport`
  because the scripted peer answers inside `start()`, which would time ~0 ms whatever
  the client did. Like it, it subclasses nothing.
- **Tick alignment.** Each measurement starts after the clock ticks, so a rounded
  boundary cannot swallow the window.
- **Probe off in the never-delay window.** In the `Coverage` build each statement
  appends to a ~490 KB hit file, costing far more than a move. The window clears
  `CI_COV_OUT` and restores it, so coverage stays complete; the anti-tautology
  check still fails under that build.

## Limits

- **Not a playtest, not `SIT.4`.** No screenshots, no protocol verdict. The release
  runs Advice Off (#505), so the check has teeth only on an advice-enabled build.
- **Machine-dependent numbers.** Wall clock on one Apple Silicon machine; the
  ceilings leave two orders of magnitude of headroom.
- **No blocker**, no defect filed.
