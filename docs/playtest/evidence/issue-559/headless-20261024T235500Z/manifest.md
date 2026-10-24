# Manifest — #559 advice readiness against `T6`

- **Issue**: #559 (type:task, parent #36). Check: `game/advice_readiness_test.gd`.
- **This is a headless integration run on `main`, not a playtest run and not `SIT.4`**: it claims no `S11` / `O10` seam. The peer is simulated (`AdviceClient.sim_factory`, ADR-0002 Testability): no Stockfish, no network.
- **Environment**: `ENV.1` headless Godot `4.7.2.stable.official.ed1daf0bf`, macOS `darwin` (Apple Silicon), no browser.
- **Build**: `main` `101c216` plus this task's two added test files (`game/advice_readiness_test.gd`, `game/deferred_advice_transport.gd`); no `game/` production change.
- **`T6` used**: 1500 ms in the readiness check (not the default, so ignoring `T6` fails); 2000 ms (the default, `B3`) for the never-delay session.
- **Repeat count**: **5 per timing**; one sample is not evidence (`evidence-manifest.md`).
- **Coverage mode**: full, narrowed to the advice-readiness half of `quality.md`'s Load time row (`CMP-advice-client` R5 / R7, `CTR-local-move.G1`, `I1`, `F-move-advice.R6`, `B3`).
- **Screenshots**: none (headless run, no UX protocol in scope).
- **Reproduce**: `python3 run_checks.py`; design and limits: `notes.md`; mutation rows: `non-vacuity.md`.

## Results

| Check | Result |
|-------|--------|
| AC1 readiness (5 repeats, worst of) | pass — **12 ms** vs `T6` 1500 ms (`logs/advice-readiness.log`) |
| AC1 anti-tautology (`start` returns unread) | pass (same log) |
| AC2 never-delay, shipped `SharedGameSession.place`, 5 moves, silent peer, worst of | pass — **0 ms** vs 40 ms ceiling; turn flips, O1 reissued (`logs/advice-readiness.log`) |
| AC2 `poll()` + 250 ms still silent | pass — no events, no advice (same log) |
| AC3 O1 `time_ms` = `T6` in range (`R7`) | pass (same log) |
| AC3 missing / out of range `T6` sends 2000 (`B3`) | pass (same log) |
| AC5 simulated peer only, no new production path | pass — one test, one test-side `RefCounted` peer |
| AC6 `Unit tests` | pass — 25 suites (`logs/unit-tests.log`) |
| AC6 `Coverage` | pass — 86.5% (4399/5085), threshold 80 (`logs/coverage.log`) |
| AC6 `Spec lint` | pass — 0 errors, 1 pre-existing warning (`logs/spec-lint.log`) |
| AC6 `Code lint` | pass — `gdformat --check`, `gdlint` clean (`logs/gdformat-check.log`, `logs/gdlint.log`) |

## Paths

- `notes.md`, `non-vacuity.md`
- `logs/`: `advice-readiness`, `unit-tests`, `coverage`, `spec-lint`, `gdformat-check`, `gdlint`, `mutations`, `coverage-with-start-waiting-mutation` (`.log` and `.status` per run)
- `run_checks.py`, `mutations.py`
