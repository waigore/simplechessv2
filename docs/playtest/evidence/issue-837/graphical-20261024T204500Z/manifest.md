# Manifest

- **Issue**: 837 — `O12`/`S13` phone-width render: playtest debug panel covers mode-pick strings (`S6` `F3`)
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, `macOS` Metal
  display (`DisplayServer.get_name()` = `macOS`), shipped playtest scene `game/main.tscn`.
- **Build / session id**: branch `defect/837-debug-panel-covers-mode-pick` on `origin/main`
  `906b8b3` (the build under acceptance for #546 was `f1a62f0`; the two differ only outside
  this defect's files). `TEL.3` session `sess-1792875739817-23590-playtest-640408` (see
  `logs/graphical-s6.log`).
- **Coverage mode**: partial — `PTU-mode-pick` S6 only. S1–S5 stay with the #400 sweep.
- **Screenshots**: `screenshots/s6-phone-390x844.png` — mode pick at a genuine 390×844 frame
  after `O12 set_viewport`, captured from this build, with the run's debug chrome collapsed.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `UI-mode-pick.US1` — S6 at 390×844 (`SIT.6`, `P5`/`F3`) | **pass** | Every label and body string is fully visible at ≥ `UIS.T2` (21 px): no string is covered by the run's chrome and none clips. `P5` holds and no `F3` leg fires. `logs/graphical-s6.log`, `screenshots/s6-phone-390x844.png` |
| `UI-mode-pick.US1` — S1–S5 | not-judged | Not driven in this run; the #400 sweep judges them |
| `PTU-mode-pick` protocol verdict | **pass** | S6 passed; S1–S5 out of scope here |

## What was measured

The seam report after `SetViewport`:

```
{"applied":true,"body_text_px":21.0,"debug_panel_visible":false,"frame_height_px":844.0,
 "height":844,"rendered_text_scale":1.31875,"text_scale":1.0,"width":390}
window_after=(390, 844)  screen_frame=(390, 844)  content_scale_size=(0, 0)
```

| Control | text | font px | rect (390×844 frame) | ≥ `UIS.T2` (21) | occluded | clips |
|---|---|---|---|---|---|---|
| `Title` | Choose how to play | 37 | (59,104) 272×111 | yes | no | two wrapped lines, both inside the box |
| `SharedGame` | Shared game · Last | 21 | (59,231) 272×54 | yes | **no** (#837 fixed) | no |
| `PuzzleStream` | Puzzle stream | 21 | (59,297) 272×54 | yes | no | no |
| `Quit` | Quit | 21 | (59,363) 82×54 | yes | no | no |
| `SwitchLocale` | English | 21 | (220,363) 111×54 | yes | no | no |

The only chrome on the frame is the `Show seams` header at (0,0) 104×31, which ends above the
mode-pick panel's top edge (104) and intersects no judged rect (`panel_overlaps_mode_pick=false`).

## Repeatability

Two runs of the same build gave the same report and the same render.

## Paths

- `notes.md`
- `logs/graphical-s6.log`
- `screenshots/s6-phone-390x844.png`
- `probe/zz_probe_837_s6.gd` — the harness that produced the readings (throwaway; never in `game/`)

## Defects

- None filed: the S6 leg this run judges now passes. This run implements #837.
