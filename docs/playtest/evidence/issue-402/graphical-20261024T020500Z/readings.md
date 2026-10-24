# Readings — timelines and frame numbers, published and fallback

Raw captures: `logs/published-40049651531-cold-open.log`, `logs/fallback-bccdb1c-cold-open.log`,
`logs/*-frames.json`, `logs/*run.json`. Builds: [builds.md](builds.md).

## Timeline — published `dd15479`, run 1

| t | Event |
|---|---|
| 2.522 s | `Godot Engine v4.7.2.stable.official.ed1daf0bf` on the console |
| 2.94 s | 14 asset open failures — `Error opening file 'game_assets/…'`, `Can't open file from path 'game_assets/…'` |
| 2.942 s | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 25 s | capture ends; `canvas=true`, screenshot still `Loading…` |

## Timeline — fallback `bccdb1c`

| t | Event |
|---|---|
| 3.77 s | 14 asset open failures, now with the `res://game_assets/…` prefix |
| 3.778 s | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 3.778 s | `ERROR: Boot assets failed: 9 approved IDs unresolved` — #647's E4 line, absent from the published build |
| 25 s | `Loading…` still on screen |

The repair changed the **reporting**, not the **outcome**. The fallback's `index.pck` carries
`35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`
(`logs/fallback-bccdb1c-check-assets.log`, exit 0) and the browser still cannot open them from `res://`.
That is the open read-path question ADR-0014 records; #715 owns proving it.

## Frame-time numbers (`SIT.4`)

| Reading | frames | fps over span | p50 | p95 | p99 | worst | deltas > 16.7 ms |
|---|---|---|---|---|---|---|---|
| published, 25 s (run 1) | 1474 | 56.5 | 16.7 | 16.8 | 33.4 | 450 ms | 48 / 1473 |
| published, 20 s (runs 2–4) | 611–621 | 26.0–26.5 | — | — | — | 1.41–1.63 s | 449–469 |
| fallback, 25 s | 1457 | 53.2 | 16.7 | 16.8 | 33.3 | 1166.6 ms | 50 |

## What these numbers do **not** prove

- **They are not a Performance verdict.** That row's method is frame-time capture *during piece movement*
  (`SIT.4`, `PTU-shared-play` S5). No move was reachable, so the row is `not-judged`. These numbers describe a
  `Loading…` screen.
- **Runs 2–4 are not comparable with run 1.** They ran concurrently and their frame delivery is contended by
  parallel headless Chromes. Only run 1 is a clean single-sitting reading.
- The manifest's `SIT.4` requirements (device, browser, repeat count) are met; a repeat count is not the same
  as a reached screen.
