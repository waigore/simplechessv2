# Verdicts

Outcome vocabulary: [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md). Build `ba6a59a`, environment `ENV.1`, released scene graph, 3 repeats per phase.

## `PTD-move-advice` (Design, headless)

| Story / step | Outcome | Note |
|--------------|---------|------|
| S1 — advice arrives with no ask action | pass | first E1 at 102–111 ms after C5; O1 carried the start position and the configured key |
| S1 — best move / eval land in `GS.adviceBestMove` / `GS.adviceEval` | pass | `e2→e4`, `+41` cp; the presentation rendered `+0.41` |
| S1 — updates deepen until the backend's cap | pass | `19 → 28 → 41` at 0.00 / 0.10 / 0.30 s, E2 `cap` at 0.70 s |
| S2 — local move never waits | pass | HUD click 28–30 ms, drag 14–15 ms, both with a stream in flight; turn changed each time |
| S3 — clear then re-evaluate | pass | advice cleared on move complete; a fresh stream evaluated the Black-to-move position (`e7e5 / -14`) |
| S4 — Off / end / leave clear and stop | pass | C3 clears and freezes the stream count; resign and leave the Shared game both cleared |
| S5 — Puzzle stream never | pass | no advice fields and no advice request on puzzle-play |
| AC 10 — connection loss mid-evaluation | pass | `online=false`, advice cleared, the local move still applied |
| AC 12 — one failure, one event | pass | exactly one `advice: error` per failed stream; no repeat on later polls |

**Protocol verdict: pass.** P1 (never-delay), P2 (On + online + Shared only) and P3 (side-to-move, time-capped) all hold on the shipped path. F1 (move blocked) and F2 (advice when Off/offline/Puzzle) not observed.

## Side-checks

| Check | Outcome |
|-------|---------|
| `unit-tests` | pass — 25 suites |
| `coverage` | pass — 86.3% (threshold 80) |
| `Code lint` | pass — `gdlint`, `gdformat --check` clean |
| `Spec lint` | pass — 0 errors, 1 pre-existing warning |
| Shipped bundle contains no Stockfish endpoint | pass — 0 matches for `stockfish` / `bestmove` / `uci` in the release PCK |
| `TEL.4` / `TEL.5` on advice events | not captured (release graph has no seam); carried by the #375 recorder run |
