# Manifest — #402 quality-row re-record on the shipped release build

- **Issue**: #402 — Verify every `quality.md` row on the shipped release build
- **Environment**: `graphical` — Chrome headless (`--headless=new`, SwiftShader WebGL), 390×844 CSS px, DPR 2, touch emulation; no seam, no playtest build
- **Build / session id**:
  - **Published reading** — `https://waigore.github.io/simplechessv2/`, attested as commit `dd1547913c71b623629c66711c098bdd42581d69` (`dd15479`), `Web release` workflow run **`40049651531`** on `main` (conclusion `success`). No `TEL.3` session id: the release export carries no seam, so it emits no telemetry.
  - **Fallback reading** — `Web Release` export of `bccdb1c9790b9033e790a425587215490607da36` (`bccdb1c`, the merge of #712 / #647's repair) at `build/web/`, served locally. **Why**: #712 merged at `2026-10-24T01:58:59Z`, and no `Web release` run exists on `bccdb1c` (`GET .../actions/workflows/web-release.yml/runs?head_sha=bccdb1c…` → `total_count: 0`), so the commit carrying #647's repair is unpublished. The fallback never stands in for a published reading.
  - The old `98d3473` reading ([`../graphical-20261024T011500Z/`](../graphical-20261024T011500Z/manifest.md)) is superseded by this re-record, not dropped: it stays cited as the superseded one.
- **Timing (`SIT.4`)**: macOS arm64, Google Chrome (headless), 390×844 DPR 2. Published: 4 cold opens (25 s, 20 s, 20 s, 20 s). Fallback: 1 cold open (25 s). Repeat count 4 / 1.
- **Coverage mode**: `critical-only` — the sweep stops at the first blocking failure, the same reading the superseded record took
- **Screen reached**: none. Both builds render `Loading…` for the full capture window.

## Results

One row per `quality.md` row, each naming the build it was read on and its source.

| `quality.md` row | Method (`How checked`) | Build read | Verdict |
|---|---|---|---|
| Performance | `SIT.4` frame time during a move | published `dd15479` / run `40049651531` | not-judged — no move is reachable; the build never leaves `EX.loading`, so there is no piece movement to time |
| Load time — board playable ≤ 3 s | timed cold open to first legal move (open time: `SIT.4`, `PTU-mode-pick` S1) | published `dd15479` / run `40049651531` | **fail** — engine boots at 2.522 s, `Preload boot left 9 approved IDs unresolved` at 2.942 s, `Loading…` still on screen at 25 s; board never playable (4/4 cold opens) |
| Load time — advice ready ≤ 2000 ms, never delays a local move | timed advice readiness while moving (`CFG.ADVICE_TIME_MS`) | published `dd15479` / run `40049651531` | not-judged — Advice Off by default and no board is reachable; the seat is #559 ([`issue-559/`](../../issue-559/)) |
| Reliability — 15–40 min sitting | sitting soak | published `dd15479` / run `40049651531` | not-judged — no screen past `EX.loading` to sit in; the seat is #558 |
| Reliability — reopen at mode pick with committed Player Elo and Last mode | fault mid-session, reopen | published `dd15479` / run `40049651531` | not-judged — no puzzle result can be committed on a build that never reaches a board; the seat is #557 |
| Observability | protocol run, story IDs, outcomes, errors in captured logs (`SIT.5`) | published `dd15479` / run `40049651531` | **fail** (defect #729) — the release export binds no seam (`game/session_router.gd:99–117`: `_emit_tel` is a no-op when `_seams == null`), so zero `TEL.1`–`TEL.5` lines appear in 4 captured console logs; only engine errors do. Carried over from `98d3473`, re-read and unchanged |
| Save durability | quit/reload after a puzzle result; forced failed write | published `dd15479` / run `40049651531` | not-judged — no commit path is reachable; the seat is #557 |
| Accessibility — piece readable from shape, no color-only information | `PER.R1`, `PAL.K1`, `PAL.K2` review | published `dd15479` / run `40049651531` | not-judged on this build — no piece is rendered; the artefact fails to load (`game_assets/…svg`). The seats are #640 / #641 |
| Accessibility — text legible at smallest size (`SIT.6`) | 390×844 phone-width read | published `dd15479` / run `40049651531` | not-judged on this build — only `Loading…` renders and its font file (`noto-sans-latin-500.woff2`) fails to open. The seat is #546 |
| Localization — `en` / `zh-Hant` / `ja` | locale switch, four screens | published `dd15479` / run `40049651531` | not-judged on this build — no locale switch is reachable; the seat is #643 |
| Load time — board playable ≤ 3 s (fallback control) | timed cold open to first legal move | **fallback** `bccdb1c` `build/web/` | **fail** — `Preload boot left 9 approved IDs unresolved`, then the new #647 E4 line `Boot assets failed: 9 approved IDs unresolved`; `Loading…` at 25 s. Reading is of the export only, never a published reading |
| All other rows (fallback control) | as above | **fallback** `bccdb1c` `build/web/` | not-judged — the fallback does not stand in for a published reading, and it also never leaves `EX.loading` |

Neither build reached a screen any row measures. The published build is older than #647's
repair (`bccdb1c`); the fallback carries the repair and is still stalled. Both are `fail` on
board playable and on Observability, and every other row is `not-judged` with its own seat named.

## What the re-read establishes, per row

- **Rows re-read and unchanged from the superseded `98d3473` reading**: Load time — board playable
  (`fail`), Observability (`fail`), and both Accessibility rows, Localization, Reliability,
  Save durability and Performance (`not-judged`, same cause).
- **Load time — advice ready** is now `not-judged` with #559 as its seat instead of "Advice Off,
  no board" alone; #559's measurement itself is unchanged.

## Paths

**Published reading (`dd15479`, run `40049651531`)**

- `logs/published-40049651531-cold-open.log` — run 1, 25 s, every console/network line and driver probe
- `logs/published-40049651531-frames.json` — `SIT.4` frame-time summary for run 1
- `logs/published-40049651531-repeat-timing.json` — the four cold opens' frame summaries and probes
- `logs/published-40049651531-release-attribution.md` — the workflow-run query that names the served commit
- `screenshots/published-40049651531-390x844-{500,1000,2000,3000,5000,10000,15000,20000,25000}ms.png` — run 1
- `screenshots/published-40049651531-r{2,3,4}-390x844-20000ms.png` — runs 2–4

**Fallback reading (`bccdb1c`, `build/web/`)**

- `logs/fallback-bccdb1c-cold-open.log` — 25 s capture
- `logs/fallback-bccdb1c-frames.json` — `SIT.4` frame-time summary
- `logs/fallback-bccdb1c-run.json` — build, source, counts, and the explicit "fallback, not published" note
- `logs/fallback-bccdb1c-export.log` — `python3 .github/scripts/web_export.py --preset "Web Release"`
- `logs/fallback-bccdb1c-check-assets.log` — `web_export.py --preset "Web Release" --check-assets`
- `logs/fallback-bccdb1c-asset-requests.log` — local `http.server` access log (loose `game_assets/` request → `404`)
- `screenshots/fallback-bccdb1c-390x844-{500,1000,2000,3000,5000,10000,15000,20000,25000}ms.png`

`notes.md` sits beside this file.

## Defects

- **#729** — "Shipped release emits no `TEL.*` telemetry: the Observability quality row fails on the
  published build" (`type:defect`, `status:pending-review`, sub-issue of **#37 Release** — owner table:
  Observability → #37). **Cited for**: Observability (`fail`). Filed by this run.
- **#630** — shipped release never leaves the loading screen (`game_assets/` is not served); owner epic
  #37 Release (owner table: Load time / board playable → #34 Shared game; the screen-wide cause is #630's).
  **Blocks**: Load time — board playable (`fail`), and every `not-judged` row that needs a screen.
- The fallback's own stall (assets carried in `index.pck` but unresolvable from `res://`) is the open
  read-path question ADR-0014 records; #715 owns proving it, and #630 owns the observation.
