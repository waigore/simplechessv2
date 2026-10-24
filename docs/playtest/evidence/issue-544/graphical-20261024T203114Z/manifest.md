# Manifest

- **Issue**: 544 — implement `SIT.4` frame-time / load-time capture (seam `S11`, op `O10`)
- **Environment**: graphical (`ENV.2`) — a rendered Godot session (`OpenGL API 4.1 Metal - Compatibility - Using Device: Apple - Apple M5`), not a browser. `S11` is read on Graphical where the engine renders; the browser leg of `PTU-*` belongs to the #400 sweep.
- **Build / session id**: `origin/main` `1894f31`, clean detached worktree, `Godot 4.7.2.stable.official.ed1daf0bf`. `TEL.3` `sess-1792873748328-5923-playtest-402179` (run 1), `sess-1792873749095-5925-playtest-394675` (run 2), `sess-1792873390470-3528-playtest-410804` (earlier run) — a fresh id per run, so the repeat count is expressible (`D2`).
- **Coverage mode**: partial — `S11` scope only. `PTU-mode-pick` S1, `PTU-shared-play` S5, `PTU-puzzle-play` S4 are judged only as far as `S11` serves them.
- **SIT.4 timing record**: device `Mac (Apple M5)`, OS `macOS 27.0.1 arm64`, browser n/a (native window), build id `1894f31` / `TEL.3` above, repeat count **3** for the shared-close probe and **2** for the full loading+shared probe.
- **Screenshots**: **waiting.** The probe drives from a `SceneTree` script, so no person-visible frame was captured; a screenshot from a graphical re-run of this same build is still owed before acceptance of this leg.

## Results

| Check | Result |
|-------|--------|
| `S11` `loading_ready` arms on a live open, closes on `mode-pick` | pass |
| `S11` `frame_times` / shared arms and closes on the judged move | pass at the seam |
| `S11` — the report a caller receives for a self-closed window | **fail** |
| `S11` — `loading_ready` report content | **fail** — `ok` with `sample_count: 0`, `max_ms: 0.0`, empty `events.end` |
| `S11` — `measure("")` disarm on an open window | pass — `cancelled`, 10 samples, no `max_ms` |
| `frame_times` / shared `solver` and per-mode spelling | pass — report `shared-play` / `white` against router `shared` / `shared-play` |
| `S11` — refused arm names the first failed predicate | pass — `puzzle_id` on an undealt puzzle |
| `S11` — `frame_times` / puzzle closes on `sequence_index` | **not-judged** — no deal, no open puzzle |
| Story-level release absence (`R3`) | not this leaf, per `D3` |

Judgement, reproduction steps, and routing: [`notes.md`](notes.md).

## Paths

- `logs/graphical-preboot.log` — engine and Metal context.
- `logs/probe-loading-shared-run1.log` — full run: `loading_ready`, then shared `frame_times`.
- `logs/probe-shared-close-run2.log`, `logs/probe-shared-close-run3.log` — repeats isolating the closed-window loss.
- `logs/probe-disarm-cancelled.log` — the `measure("")` disarm path.
- `logs/probe-measure-arguments.log` — every `measure()` argument against a self-closed window.
- `probe/` — the throwaway probes that boot the real `main.tscn` and call only public seam and router entry points.
- Notes: [`notes.md`](notes.md). Findings and routing: [`findings.md`](findings.md).

## Defects

None filed. Routing is in [`findings.md`](findings.md).
