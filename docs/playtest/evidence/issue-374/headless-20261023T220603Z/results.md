# Results

Build `ba6a59a`, environment `ENV.1`, released scene graph.

## What happened

**Advice (3 runs).** After `shared-setup` C5 the client opened one O1 carrying `api_key`, the start FEN and `time_ms: 2000` — the B3 default, since the release build reads no T6 seam. First E1 landed **102–111 ms** later and the stream kept deepening (`+19 → +28 → +41` cp at 0.00 / 0.10 / 0.30 s, E2 `cap` at 0.70 s). `GS.adviceBestMove` held `{e2, e4}`, the board rendered `+0.41`, and `GS.online` stayed `true`.

**Lifecycle (3 runs).** With a stream in flight, a HUD click e2→e4 applied in **28–30 ms** and a press-move-release drag e7→e5 in **14–15 ms**; the turn flipped and advice was `null` right after each move. Each new position opened its own stream (Black: `e7e5 / −14`). C3 Off cleared at once and froze the stream count; C3 again restarted. Resign and leaving the Shared game both cleared and stopped. Puzzle-play carried no advice and made no advice request.

**Failure (3 runs).** Against a peer failing the first stream with a 500: offline within the first second, advice cleared, local move still applied, exactly one `advice: error` in the log, and a later `poll` returned `{"events": []}`.

## Criterion-by-criterion

| AC block | Result | Evidence |
|----------|--------|----------|
| 1–2 (arrival, side to move) | pass | `drive-advice-*.log`, `drive-lifecycle-*.log` |
| 3–4 (never-delay, clear + restart) | pass | HUD 28–30 ms, drag 14–15 ms; `hud_move_cleared_advice`, `game_end_cleared_advice` |
| 5–6 (Off / end / leave, stale `I3`) | pass | `c3_*`, `left_shared_game`; cleared fields stay `null` |
| 7–8 (Puzzle, `time_ms`) | pass | `puzzle_no_advice_fields`; every O1 `time_ms: 2000` (T6 unset, B3) |
| 9–11 (endpoint/key, reachability, progressive E1) | pass | 8/8 peer rows `authorized`; `drive-failure-*.log`; depth progression |
| 12–14 (off the move path, one error, no Stockfish endpoint) | pass | timings; 1 `advice.error`; AC 13 from this run's PCK probe, not #560's |
| 15 (telemetry `TEL.4` / `TEL.5`) | **not captured** | no seam on the release graph — limit in [`notes.md`](notes.md) |
| 16 (lint / tests / coverage) | pass | 86.3% (80), 25 suites, lint clean |

## Judgement

`PTD-move-advice` **pass**: P1, P2 and P3 hold on the shipped path; F1 and F2 not observed. No defect filed. AC 15 is the one criterion this run cannot evidence — recorded as a limit in [`notes.md`](notes.md), not as a pass.
