# Manifest — #879 acceptance run (independent, published build)

- **Issue**: #879 — Release Web: mode-pick presses are delivered but never activate Shared game or
  Puzzle stream (`type:defect`, `priority:high`).
- **Run**: acceptance test at `status:pending-acceptance`, independent of the implementation leg
  (PR #899) — separate machine session, fresh browser profile, boxes re-read from pixels.

How and its limits: [notes.md](notes.md). Readings: [readings.md](readings.md). Verdict and what it
does not prove: [verdict.md](verdict.md).

## Environment and build

- **Environment** (`ENV.2`, Graphical): headless-rendered graphical session of the kind earlier runs
  in this repo recorded — Chrome for Testing **156.0.8078.4** (`--headless=new`, SwiftShader WebGL
  2.0), 390×844 CSS at DPR 3, CDP touch emulation, **no** autoplay-policy flag. Host: Linux x86_64
  (Ubuntu 24.04); its Chrome packaging needs a user-supplied `libasound.so.2` shim
  (`LD_LIBRARY_PATH`), not part of this run's artifacts.
- **Build under test**: the **published** client at `https://waigore.github.io/simplechessv2/`
  (ADR-0009 preferred source, per `procedures.md` Prep). At run time `index.pck` was
  `content-length: 9572540`, `last-modified: Sun, 25 Oct 2026 00:26:08 GMT`, `etag:
  "6add4ca0-9210bc"` — the same deployment the implementation leg named (`69a03d4`, page
  2026-10-25T00:26:00Z). The published tree has no playtest seams (ADR-0004): no `TEL.3` session id
  and no `DBG.*` handle, so every judgement is from pixels, the page-level gesture log, and
  `localStorage`.
- **Coverage**: not a coverage sweep. Rows judged are those the defect can change — `PTU-mode-pick`
  (P1, P2, P4; S1–S3) and the `PTU-controls` P3 pointer rule on `mode-pick`. `PTU-mode-pick` S5/S6
  and P3/P5 and `PTU-controls` S6 are `not-judged`.

## Results

| Protocol | Row / step | Outcome | Evidence |
|---|---|---|---|
| `PTU-mode-pick` | `UI-mode-pick.US1` — C1, C2 activate (S2, S3) | **pass** | impl log `logs/published-centre-readings.json`: 6/6 C1 at (195,163), 6/6 C2 at (195,204), 200 ms; frame digests `c20b06d2…` → `bbefbb38…` (`shared setup`) / `bb8d41b1…` (puzzle play), each corroborated by `last_mode` = `shared` / `puzzle` |
| `PTU-mode-pick` | P4 — mode pick interactive from a cold open, controls live | **pass** | `screenshots/mode-pick-published-00.png` (sha256 `c20b06d2…`, identical to the implementation leg's mode-pick frame) after a cold open on an empty `localStorage`; presses on it activate (row above) |
| `PTU-controls` | P3 — pointer on a named control fires `IN.point`, no other action | **pass** on `mode-pick` | box centres act, seam/off-panel presses do not (impl `logs/published-boundary-readings.json`: (195,180) and (195,187) act; (150,185), (195,183), (40,163), (195,400) do nothing); plain-mouse arms act 3/3 + 3/3 (`logs/published-mouse-readings.json`) |
| `PTU-mode-pick` | S5 (Switch locale), S6/P5 (phone-width legibility), P3 | **not-judged** | out of this defect's reach; not the delta under acceptance |

## Paths

- [notes.md](notes.md) — what was judged, how, and the limits
- [readings.md](readings.md) — per-frame and per-arm readings, re-derived here
- [verdict.md](verdict.md) — consequence for the defect and what this run does not prove
- `screenshots/mode-pick-published-00.png` — the cold-open mode-pick frame used for the box geometry
- `scripts/boxes.py` (box reader, from the implementation leg), `scripts/cdp.mjs` (CDP driver:
  per-target attach; Chrome 156 detaches a session when the game page reloads itself),
  `scripts/capture.mjs` (the cold-open capture)
- Implementation-leg evidence judged here:
  [`../graphical-20261025T005759Z/`](../graphical-20261025T005759Z/manifest.md) (PR #899, merged
  `8428459`)
