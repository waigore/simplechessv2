# Manifest — #402 quality-row re-record on the build the URL serves today

- **Issue**: #402 (parent epic #37, Wave 4). Re-record requested by the verify fail of
  2026-10-25T07:33Z. Previous run: `graphical-20261025T031500Z`.
- **Environment**: `graphical` (`ENV.2`) attempted, **not available on this seat** — the
  browser binary segfaults before it starts ([logs/browser-probe.md](logs/browser-probe.md)).
  No row claims a rendered reading from this host.
- **Build / session id**: published `https://waigore.github.io/simplechessv2/` at
  **`ad9c04d`**, attributed by `Web release` run **`40176551606`** (both jobs green,
  2026-10-25T08:25:24Z) and Pages deployment `7310604017`. Served `index.pck`
  9 364 800 B, `sha256 2954319b…754a8f`. `TEL.3` session id: **none** — the release
  strips telemetry by design (ADR-0004 `G2`, #729); none is invented.
- **Timing (`SIT.4`)**: not taken — no browser. **Coverage mode**: `critical-only`.
- **Screenshots**: **none of the build** — Chrome produced no frame here.

## Results

| # | Row | Method | Build read | Verdict |
|---|---|---|---|---|
| 1 | Performance | `SIT.4` during a move | none — no browser | **not-judged** — seat #625 |
| 2 | Load time, board playable ≤ 3 s | timed cold open | `ad9c04d` bytes; #845 fix in build | **not-judged** — seat #625 |
| 3 | Load time, advice ≤ 2000 ms | `CFG.ADVICE_TIME_MS` | `main` `101c216` (#559) | **not-judged** on release: `T9`/`T10` empty |
| 4 | Reliability, sitting soak | soak without crash | export of `c4202bb` (#558) | **not-judged** on `ad9c04d`; #626 owns the repeat |
| 5 | Reliability, reopen after failure | crash/fault, reopen | code only | **not-judged** — #557 owns the leg |
| 6 | Observability | `TEL.*` in a protocol run | playtest-certified build (`H1`) | **not-judged** — read on the playtest build (#729) |
| 7 | Save durability | reload; forced failed write | code only | **not-judged** — #557 owns the leg |
| 8 | Accessibility, shape / no colour-only | `PER.R1`, `PAL.K1`, `PAL.K2`, last move | published `69a03d4` (#640/#641) | **fail** — **#883**, **#888**; seven signals pass |
| 9 | Accessibility, smallest text | `SIT.6` | seam build `aa16e09` (#546) | **not-judged** — never read on a release build |
| 10 | Localization | switch locale, four screens | copy table in the served pack | **not-judged** — needs a browser |

**Totals: 0 `pass`, 1 `fail`, 9 `not-judged`.** Per-row reasoning:
[superseded.md](superseded.md), [readings.md](readings.md).

## Defects

| Defect | Row | Owner | State |
|---|---|---|---|
| **#888** — no last-move mark at all | 8 | #34 | open, `pending-clarification` |
| **#883** — `PAL.K2` piece-side carriers fail | 8 | #34 | closed COMPLETED 2026-10-25T06:12Z |
| **#845** — tap one rank off | 2 (historical) | #34 | accepted; fix `aa16e09` is in `ad9c04d`; not a current failure |

No new defect: the failing row already has #888; every `not-judged` is a missing reading
with a named owner.

## Paths

[builds.md](builds.md) · [readings.md](readings.md) · [superseded.md](superseded.md) ·
[notes.md](notes.md) · [logs/](logs/) · drivers `drive.mjs`, `locator.mjs`,
`pnglib.mjs`, `probe-browser.mjs`, `read-pck.mjs` · `screenshots/` empty by construction.
