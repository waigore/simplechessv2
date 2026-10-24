# Notes — #402 quality-row re-record, 2026-10-24 (run `graphical-20261024T020500Z`)

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 402`). Re-read of every
`specs/definition/quality.md` row under the **Build under test** field this issue landed in its refine pass:
each row names the build it read, and the fallback never stands in for a published reading.

## Builds under test, and why this pair

| Reading | Commit | Source | Why this build |
|---|---|---|---|
| Published | `dd1547913c71b623629c66711c098bdd42581d69` | `https://waigore.github.io/simplechessv2/`, `Web release` run **`40049651531`** | the newest successful `Web release` run on `main` (`gh api .../web-release.yml/runs?status=success&branch=main` → `40049651531`, `2026-10-24T01:24:36Z`). It does **not** carry #647's repair (its commit predates #712's merge at `01:58:59Z`) |
| Fallback | `bccdb1c9790b9033e790a425587215490607da36` | `Web Release` export at `build/web/` of a detached worktree at that commit, served by `python3 -m http.server` | the merge of #712, which carries #647's asset-root repair. **Unpublished**: `GET .../actions/workflows/web-release.yml/runs?head_sha=bccdb1c…` → `total_count: 0`, so no run attributes it to `main` |

The pair is read deliberately: the published reading says what a player gets today; the fallback says
whether the repair moves any row. Neither reading is converted into the other.

## What was run

- **Published**: four cold opens (25 s, 20 s, 20 s, 20 s) of the URL with a cache-busting query, Chrome
  headless, 390×844 CSS px at DPR 2, touch emulation, SwiftShader WebGL. `SIT.4` frame-time sampler
  installed at 500 ms and screenshots at 500 ms / 1 s / 2 s / 3 s / 5 s / 10 s / 15 s / 20 s / 25 s.
- **Fallback**: one 25 s cold open of `http://127.0.0.1:8791/index.html` from `build/web/`, same envelope,
  with the same sampler. A second cold open of the loose `game_assets/` route was **not** part of this
  record; the `404` in `logs/fallback-bccdb1c-asset-requests.log` merely confirms the staged copies are
  packed rather than served loose.

## Timeline — published `dd15479`, run 1 (`logs/published-40049651531-cold-open.log`)

| t | Event |
|---|---|
| 2.522 s | `Godot Engine v4.7.2.stable.official.ed1daf0bf` on the console |
| 2.94 s | `ERROR: Error opening file 'game_assets/…'` / `Can't open file from path 'game_assets/…'` — 14 asset open failures |
| 2.942 s | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 25 s | capture ends; `DRIVER probe canvas=true`, screenshot still `Loading…` |

## Timeline — fallback `bccdb1c` (`logs/fallback-bccdb1c-cold-open.log`)

| t | Event |
|---|---|
| 3.77 s | 14 asset open failures, now with the `res://game_assets/…` prefix |
| 3.778 s | `ERROR: Preload boot left 9 approved IDs unresolved` |
| 3.778 s | `ERROR: Boot assets failed: 9 approved IDs unresolved` — #647's E4 line, absent from the published build |
| 25 s | `Loading…` still on screen |

The repair changed the *reporting*, not the *outcome*: the `index.pck` of the fallback carries
`35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)` (`logs/fallback-bccdb1c-check-assets.log`,
exit 0), and the browser still cannot open them from `res://`. That is the open read-path question ADR-0014
records and #715 exists to prove or refute on a shipped tree.

## Frame-time numbers (`SIT.4`), reported and not used as a row verdict

| Reading | frames | fps over the span | p50 | p95 | p99 | worst | deltas > 16.7 ms |
|---|---|---|---|---|---|---|---|
| published, 25 s (run 1) | 1474 | 56.5 | 16.7 | 16.8 | 33.4 | 450 ms | 48 / 1473 |
| published, 20 s (runs 2–4) | 611–621 | 26.0–26.5 | — | — | — | 1.41–1.63 s | 449–469 |
| fallback, 25 s | 1457 | 53.2 | 16.7 | 16.8 | 33.3 | 1166.6 ms | 50 |

**These are not a Performance verdict, and must not be read as one.** The Performance row's method is
frame-time capture *during piece movement*; no move is reachable, so the row is `not-judged` and these
numbers only describe a `Loading…` screen. Runs 2–4 ran concurrently and their frame delivery is
contended by the parallel headless Chromes, so even as a `Loading…` measurement they are not comparable
with run 1. `SIT.4`'s manifest rule (device, browser, repeat count) is met: macOS arm64, headless Chrome,
4 published + 1 fallback cold open.

## Row judgements

See `manifest.md` *Results*. In short: **2 `fail`** (Load time — board playable; Observability) and **8
`not-judged`**, every `not-judged` row naming its own seat. Both readings agree; nothing became a pass on
either build.

`not-judged` is chosen, not `fail`, for the rows the build never reached: per `specs/playtest/evidence.md`,
a row the run could not judge is `not-judged`, never `pass`. Rows that did run and misbehaved — board
playable, Observability — are `fail`.

## Defects filed

- **#630** — "Shipped release never leaves the loading screen" (owner: #37 Release for the screen-wide
  cause; the owner table routes board-playable to #34 Shared game). It is the sole cause of the eight
  `not-judged` rows in this record and stays the cited defect for **Load time — board playable ≤ 3 s**.
  Not re-filed: nothing in this run's readings changes it, and a second defect for the same observation
  would fork the owner.
- **Observability** — no open defect owned this row. #506 (*Map the quality rows with no playtest seam …*)
  is a planning task, not a defect, and it records that #402 is the row's only check today; the row has now
  failed on two published builds (`98d3473` and `dd15479`) and on the repair (`bccdb1c`). Filed this run as
  **#729** — `type:defect`, `status:pending-review`, sub-issue of **#37 Release** (owner table:
  Observability → #37), and cited against the row in `manifest.md`.

Nothing was fixed inside the gate: no code, spec, or asset changed in this run. The run folder is the only
artefact.

## Re-record rules this run followed

- Every row names its build (commit + published URL / export path), so a later record on a repaired build
  compares like with like.
- The superseded `98d3473` reading stays in the tree as
  [`../graphical-20261024T011500Z/`](../graphical-20261024T011500Z/manifest.md); this record marks the rows
  it replaces and states, per row, what the re-read found unchanged.
- A fallback row is labelled a fallback row in every table it appears in, and no fallback row is written
  into a published reading.
