# Manifest — #856 cold open to mode pick, acceptance run

- **Issue**: #856 — Release Web: cold open to mode pick is 3.0–4.4 s, over the 3 s bar
  (`type:defect`, `status:pending-acceptance` at the time of the run).
- **Environment**: `ENV.2` Graphical — headless Chrome 144 (`--headless=new`), 390×844 CSS,
  DPR 2, touch emulation, HTTP cache disabled, one fresh profile per cold run. Renderer
  `ANGLE (Apple, ANGLE Metal Renderer: Apple M5)`, i.e. the hardware-accelerated path a
  player's browser uses. `ENV.3` is the same frame under
  `--use-angle=swiftshader` (software rasteriser), recorded as a cross-check only.
  macOS 27 arm64, 10 cores; host load average 5–11 during the hardware runs and 17–24
  during the software-rasteriser runs.
- **Builds under test** (three, one arm each):
  - **published release** — `https://waigore.github.io/simplechessv2/`, `Web release` run
    `40146630737` on `69a03d4`. Served `index.html` / `index.js` / `index.wasm` /
    `index.pck` all `last-modified 2026-10-25 00:26:08Z`, etag prefix `6add4ca0`,
    `index.wasm` 39,514,754 B, `index.pck` 9,572,540 B. This is what a player opens now;
    it does **not** carry #877 (merged 01:03:55Z, not yet republished).
  - **base export** — `Web Release` export of `69a03d4` served from `127.0.0.1:8098`, so the
    same bytes as the published arm without the Pages transfer — the A/B partner for the
    fix arm.
  - **fix export** — `Web Release` export of `origin/main` `79d5780`, which carries #877
    (`game/session_router.gd` `_start_music_after_paint`), served from `127.0.0.1:8099`.
    Godot `4.7.2.stable.official.ed1daf0bf`; exported with
    `python3 .github/scripts/web_export.py --preset "Web Release"`.
- **Timing (`SIT.4` runs)**: cold open 4 per arm (published, base, fix), warm open 1 per arm,
  software-rasteriser cross-check 3 per arm. Each run is one page load; one sample is not
  evidence.
- **Coverage mode**: `critical-only` — `PTU-mode-pick` S1 and its `P4` only. S2–S6 are
  `not-judged` here and stay with the #400 sweep; #546 owns S6.
- **Screenshots**: `screenshots/`, from the graphical leg of each judged build
  (`pub-*` = published release, `fix-*` = fix export).
- **Defects**: none filed by this run. #856 is itself the defect under acceptance.

## Results

`PTU-mode-pick` S1 / `P4` (load time) — **pass on `ENV.2`**. Story row
`screens/mode-pick.md#US1` judged for its S1 timing only; S2–S6 `not-judged`.
Verdict reasoning: [`notes.md`](notes.md).

## Paths

- [`notes.md`](notes.md) — what was judged, the three-way read of an open, and independence
- [`results.md`](results.md) — the protocol verdict and the story rows
- [`readings.md`](readings.md) — the per-run table and how to read it
- [`fix-effect.md`](fix-effect.md) — the base-export ↔ fix-export comparison for #877
- [`renderer.md`](renderer.md) — the software-rasteriser cross-check and what this run does
  not settle
- `logs/published-release-hardware-cold.json`, `logs/published-release-hardware-warm.json`
- `logs/base-export-hardware-cold.json`, `logs/base-export-hardware-warm.json`
- `logs/fix-export-hardware-cold.json`, `logs/fix-export-hardware-warm.json`
- `logs/swiftshader-crosscheck.json` — `ENV.3`, not the judging leg
- `logs/pub-drive.json`, `logs/fix-drive.json` — the S1 drive (timings + taps)
- `logs/pub-drive-console.log`, `logs/fix-drive-console.log` — page console for those drives
- `screenshots/` — 10 images (`pub-*`, `fix-*`), each build's loading state, mode pick, warm
  mode pick, Shared game setup, puzzle stream
- `scripts/probe.mjs` — the cold/warm reading (`node probe.mjs <url> <outDir> <label>
  [--warm] [--swiftshader]`)
- `scripts/drive.mjs` — the S1 drive that taps and screenshots
- `scripts/summarize.py` — prints the per-run table from the merged arm files
