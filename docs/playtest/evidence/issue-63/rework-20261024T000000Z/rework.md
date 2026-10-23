# Rework — what changed and what it measured

## Changed (`demos/shared-game/`)

- `board_view.gd`
  - `RIM_OUTER` 0.10 → 0.26: the 0.16-unit band now lies entirely outside the 8×8.
  - `spots()` and `_build_bevel()` take their rectangles from one helper
    (`_canvas_rect(lo, hi)`, board units), so the band the ink is centred in and
    the band drawn cannot drift apart.
  - `text_rect()` documents its canvas-pixel unit; its box is placed by the
    board → frame transform.
  - `measure_coord_labels()` reads the bands back from the drawn
    `BevelLipLeftInk` / `BevelLipBottomInk` polygons (`_drawn_band_rects()`) and
    fails a band that overlaps the 8×8 — it no longer reuses the placing geometry.
  - New `coord_ink_problems(image)`: hides pieces, reads the frame, fails on any
    cream `PAL.C10` pixel inside the 8×8 or off the two bands, or on a band with
    no ink.
- `main.gd` — the autodrive runs `coord_ink_problems()` on a graphical frame
  (before the mate end panel) and, with `DEMO_COORD_PROBE=1`, writes the same
  drawing for a headless run to `DEMO_COORD_PROBE_OUT`.
- `README.md` — the `PER.R7` row, D13 and the Run note state what the build
  draws and what the autodrive checks.

## Result

| Check | Outcome |
|-------|---------|
| `--import --quit` | exit 0 — `logs/import.log` |
| `DEMO_AUTODRIVE=1` headless | `[demo] PASS` — `logs/autodrive.log` |
| `DEMO_COORD_PROBE=1` headless | `[demo] PASS` — `logs/autodrive-probe.log`, `logs/coord-probe.txt` |
| `check_coord_probe.py logs/coord-probe.txt` | `PASS` — `logs/coord-probe-check.log` |
| Same run with the old left-band geometry | autodrive exit 1 (8 × "leaves its coordinate band"), checker exit 1 — `logs/*-before.*` |

Measured drawing (frame 720×1280, 8×8 at x 72–648, y 352–928):

| Label | Ink box (frame px) | Band (frame px) |
|-------|--------------------|-----------------|
| files a–h | y 936.5–945.5; x centres 108 / 180 / 252 / 324 / 396 / 468 / 540 / 612 (±0.5 px of each file centre) | bottom, y 935.2–946.7, x 53.3–666.7 |
| ranks 1–8 | x 57.5–60.5; per rank (1: y 887.5–896.5 … 8: y 383.5–392.5) | left, x 53.3–64.8, y 333.3–946.7 |

All 16 boxes sit inside their bands and no band touches the 8×8. Ink is cream
`#F7F1E8` on `#6E4430` = **7.38:1**; on the light `PAL.C1` square it would be
1.28:1, the contrast the fix keeps the ink away from.

## Guard self-tests (throwaway scenes, not committed)

- `coord_ink_problems()` on stub frames: ink in a band → pass; ink inside the
  8×8 → "N rendered coordinate-ink pixels inside the 8x8"; ink on the table
  margin or an empty band → "off their coordinate bands" / "no rendered
  coordinate ink in …".
- `measure_coord_labels()` with the old left-band geometry → 8 failures,
  recorded in `logs/autodrive-probe-before.log`.
