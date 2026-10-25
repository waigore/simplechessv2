# Manifest — #879 acceptance run (independent, published build)

- **Issue**: #879 — Release Web: mode-pick presses are delivered but never activate Shared game or
  Puzzle stream (`type:defect`, `priority:high`).
- **Run**: acceptance test at `status:pending-acceptance`, independent of the implementation leg
  (PR #899) — separate machine session, fresh browser profile, boxes re-read from pixels.
- **Environment**: `ENV.2` (Graphical), read as a headless-rendered graphical session, the same kind
  earlier runs in this repo recorded: Chrome for Testing **156.0.8078.4** (`--headless=new`,
  SwiftShader WebGL 2.0), 390×844 CSS at DPR 3, CDP touch emulation, **no** autoplay-policy flag.
  Host: Linux x86_64 (Ubuntu 24.04). The host's Chrome packaging needs a user-supplied
  `libasound.so.2` shim (`LD_LIBRARY_PATH`); it is not part of this run's artifacts.
- **Build under test**: the **published** client at `https://waigore.github.io/simplechessv2/`
  (ADR-0009 preferred source, per `procedures.md` Prep). At run time it serves `index.pck`
  `content-length: 9572540`, `last-modified: Sun, 25 Oct 2026 00:26:08 GMT`, `etag:
  "6add4ca0-9210bc"` — the same deployment the implementation leg named (`69a03d4`,
  page 2026-10-25T00:26:00Z). The published tree carries no playtest seams (ADR-0004), so there is
  no `TEL.3` session id and no `DBG.*` handle: every judgement below is from pixels, the page-level
  gesture log, and `localStorage`.
- **Coverage**: not a coverage sweep. Protocol rows judged are those the defect can change:
  `PTU-mode-pick` (P1, P2, P4; S1–S3) and the `PTU-controls` P3 pointer rule on `mode-pick`.
  `PTU-mode-pick` S5/S6 and P3/P5 and `PTU-controls` S6 are **not judged by this run**
  (`not-judged`), because the deltas under acceptance are the two mode controls.

## Results

| Protocol | Row / step | Outcome | Evidence |
|---|---|---|---|
| `PTU-mode-pick` | `UI-mode-pick.US1` — C1, C2 activate (S2, S3) | **pass** | impl log `logs/published-centre-readings.json`: 6/6 C1 at (195,163), 6/6 C2 at (195,204), 200 ms; frame digests `c20b06d2…` → `bbefbb38…` (`shared setup`) / `bb8d41b1…` (puzzle play), each corroborated by `last_mode` = `shared` / `puzzle` |
| `PTU-mode-pick` | P4 — mode pick interactive from a cold open, controls live | **pass** | `screenshots/mode-pick-published-00.png` (sha256 `c20b06d2…`, identical to the implementation leg's mode-pick frame) after a cold open on an empty `localStorage`; presses on it activate (row above) |
| `PTU-controls` | P3 — pointer on a named control fires `IN.point`, no other action | **pass** on `mode-pick` | box centres act, seam/off-panel presses do not (impl `logs/published-boundary-readings.json`: (195,180) and (195,187) act; (150,185), (195,183), (40,163), (195,400) do nothing); plain-mouse arms act 3/3 + 3/3 (`logs/published-mouse-readings.json`) |
| `PTU-mode-pick` | S5 (Switch locale), S6/P5 (phone-width legibility), P3 | **not-judged** | out of this defect's reach; not the delta under acceptance |

## Independent checks made in this run (not taken from the implementation comment)

1. **The published frame is the issue's frame.** The cold-open frame this run captured is sha256
   `c20b06d2ce78…4b90`, byte-identical to `boardtap-69a03d4-00-mode-pick.png` cited by the issue and
   to the implementation leg's `published-00-mode-pick.png` and `export-00-mode-pick.png`.
2. **Box geometry, measured here from pixels.** `scripts/boxes.py` on that frame: painted panel rows
   at CSS y 24.5, 144.83, 181.67, 185.83, 223.0, 271.5 — C1 y 144.83–181.67, C2 y 185.83–223.00, a
   **4.16 px seam** between them; panel x 87.3–302.3 from a dark-row scan. The issue's 0/8 core
   point `(150,185)` and the export hold arms' `(195,185)`, `(240,185)` fall in that seam;
   `(60,185)`/`(330,185)` fall outside the panel's x range.
3. **The arm logs are internally consistent.** Every published-touch, export-touch and mouse arm has
   `preSha = c20b06d2…`, a post digest equal to the corresponding committed frame (`bbefbb38…` for
   C1, `bb8d41b1…` for C2) exactly when `advanced` is true, matching `last_mode`, and a page gesture
   log in every arm (`pointerdown`/`touchstart`/`pointerup`/`touchend`; `pointerdown`/`pointerup`/
   `click` on the mouse leg).
4. **The cited frames exist and agree.** The committed screenshots fetched from `origin/main`
   reproduce the digests in the arm logs: `published-01-shared-advanced` = `bbefbb38…`,
   `published-02-puzzle-advanced` = `bb8d41b1…`, `published-03-seam-150-185-unmoved` =
   `c20b06d2…`, `published-06-mouse-shared-advanced` = `bbefbb38…`.
5. **The deployment is current.** `curl -I` on `index.pck` during acceptance returned the same
   `content-length` the implementation leg measured (9 572 540 B) with `last-modified`
   2026-10-25T00:26:08 GMT.

## Defects

None filed. Every press inside a painted mode-pick control activated on the published build; the
presses recorded as lost are in the seam or outside the panel.

## What this run does not prove

- **No real phone.** All readings are CDP touch emulation at a 390×844 DPR-3 frame. A phone-specific
  delivery fault is not excluded; the seam explains every reading on record without one.
- **Not a bytes-level re-derivation of the pack.** The deployment was checked by HTTP headers and by
  the byte-identical frame, not by re-downloading and diffing `index.pck` against a local export; the
  implementation leg's `logs/pack-comparison.json` covers that (both 9 572 540 B, 158 routes,
  `index.html`/`index.wasm` identical).
- **S5/S6/P3/P5** of `PTU-mode-pick` and S6 of `PTU-controls` are not judged here.

## Paths

- [notes.md](notes.md) — what was judged, how, and the limits
- `screenshots/mode-pick-published-00.png` — the cold-open mode-pick frame used for the box geometry
- `scripts/boxes.py` — the box reader (as used, from the implementation leg)
- `scripts/cdp.mjs` — the CDP driver used to take the cold-open frame (per-target attach; Chrome 156
  detaches a session when the game page reloads itself)
- `scripts/capture.mjs` — the cold-open capture that produced the frame
- Implementation-leg evidence judged here:
  [`../graphical-20261025T005759Z/`](../graphical-20261025T005759Z/manifest.md) (PR #899, merged
  `8428459`)
