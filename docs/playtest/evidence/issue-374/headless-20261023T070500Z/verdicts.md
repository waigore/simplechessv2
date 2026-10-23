# Verdicts

Outcome vocabulary: [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md). Build `e022f83`, environment `ENV.1`.

## `PTD-move-advice` (Design, headless)

| Story / step | Outcome | Note |
|--------------|---------|------|
| S1 — production path, simulated peer over HTTP | fail | O1 correct, no E1 applied, service reported offline |
| S1 — real #373 backend | fail | backend streamed; client dropped the stream in <100 ms |
| S2 — move never waits | pass | 26.7 ms move, turn changed, advice cleared immediately |
| S3 — clear then re-evaluate | pass | new O1 for the Black-to-move position, `e7e5`/`-20` applied |
| S4 — Off / offline clears | pass | Off cleared and stopped; On restarted |
| S5 — Puzzle stream never | pass | `advice: none`; Shared-only gate refuses O1 |

**Protocol verdict: fail.** P3 fails (no best move or eval is produced against a reachable service). P1 and P2 hold. F1 and F2 are not observed.

## Side-checks

| Check | Outcome |
|-------|---------|
| `AdviceStreamTransport` against a reachable simulated peer | fail — `ended=error` in 7 ms, 0 updates |
| `AdviceStreamTransport` against the real backend | fail — `ended=error` in 8 ms, 0 updates |
| Mirrored HTTP exchange | `STATUS_REQUESTING` judged as a close; body arrives 40 ms later |
| Failure telemetry fields (`TEL.4` / `TEL.5`) | pass |
| One failure, one event | fail — 112 events in 60 frames |
