# Manifest — #402 quality-row re-record

- **Issue**: #402 — verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` — headless Chrome (SwiftShader), 390×844 CSS, DPR 2, touch
- **Build / session id**: published `c5b8189`, `Web release` run **`40118381611`**.
  `TEL.3` session id: none — the release strips telemetry by design (`I3`/`G2`). Board
  diagnosis also used the local export of `0019e75`; the two are never merged.
- **Timing (`SIT.4`)**: macOS arm64, headless Chrome + SwiftShader; repeats in
  [builds.md](builds.md).
- **Coverage mode**: `critical-only` — reachable rows read; seated rows `not-judged`.

## Results

Each row names the build it read.

| Row | Method | Build read | Verdict |
|---|---|---|---|
| Performance | `SIT.4` frame capture during a move | published `c5b8189` | not-judged — idle and move windows equally slow on SwiftShader (p50 50–66.7 ms both); move committed 2/2 |
| Load time — board playable ≤ 3 s | timed cold open to first legal move | published `c5b8189` | **fail** — board not playable by touch (#845), and cold open measured 5.5–6.1 s first paint / 8.2–8.7 s FCP (3/3) |
| Load time — advice ≤ 2000 ms | timed readiness on the simulated peer | — (#559) | not-judged — measured in that run's folder |
| Reliability — sitting soak | 15–40 min soak | — (#558) | not-judged — not run in this window |
| Reliability — reopen after failure | `Page.crash`, reopen | published `c5b8189` | **pass** — mode pick, stored doc unchanged |
| Observability | protocol run with `TEL.*` | playtest-certified build (`H1`) | not-judged — read on the playtest build per the body |
| Save durability | reload after a result; forced failed write | published `c5b8189` | **pass** — commit survives reload; forced failure leaves prior commit intact |
| Accessibility — shape / no colour-only | `PER.R1`, `PAL.K1`, `PAL.K2` | — (#640/#641) | not-judged — verified outside playtest |
| Accessibility — smallest text, phone width | `SIT.6` | — (#546) | not-judged — seam still pending implementation |
| Localization — `en`/`zh-Hant`/`ja` | switch locale, four screens | published `c5b8189` | not-judged — locale control focused without activating in three attempts; no translated copy rendered |

**Totals, published: 2 `pass`, 1 `fail`, 7 `not-judged`.**

## Paths

- [builds.md](builds.md) — commits, environment, repeats
- [readings.md](readings.md) — numbers and values
- [notes.md](notes.md) — judgement text, seats, defects, method
- `screenshots/`: `published-01-mode-pick-cold-open-focused-label-invisible` (#833),
  `durability-01-reload-mode-pick`, `durability-02-forced-write-failure`,
  `reliability-01-reopen-after-renderer-crash` (same screen as `durability-01`),
  `perf-01-shared-play-before-move`, `perf-02-after-move` (the committed move),
  `board-01-tap-visible-e2-selects-e1`, `board-02-y640-selects-rank2` (#845, published
  `c5b8189`). The rank sweep and full e2–e4 move ran on the `0019e75` fallback, no screenshot.
  The locale run has no screenshot: no new copy rendered.
- `logs/`: `GATE-rungate-{load,dur,perf,board}.json`, `GATE-locfix.json`,
  `published-*-events.log`, `fallback-*`
- Drivers: `drive.mjs`, `locator.mjs`, `pnglib.mjs`, `rungate.mjs`, `ymap.mjs`,
  `confirmmove.mjs`

## Defects

- **#845** — board taps hit one rank above the finger. Cited for Load time and for how
  the move was driven.
- **#833** — focused label nearly invisible; already filed, part of the Localization
  blocker.
