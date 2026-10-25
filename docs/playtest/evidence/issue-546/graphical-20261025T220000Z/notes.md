# Notes

## What this run is

Acceptance of **#546** (`SIT.6` / `S13` / `O12`), fifth attempt. It has failed acceptance twice, both
times on rendering, never on font-size numbers:

| Run | Verdict | Cause |
|---|---|---|
| `graphical-20261024T201500Z` | fail | body text drawn below `UIS.T2`; defect #708 |
| `graphical-20261025T090000Z` | fail | playtest debug panel painted over mode-pick copy; defect #837 |

So this run judges the **render**: the capture is read, and each control's rect is intersected with
the playtest chrome, so a string under opaque chrome cannot pass as legible.

## Environment

Godot `4.7.2.stable.official.ed1daf0bf`, graphical (`ENV.2`), `DisplayServer.get_name()` = `macOS`,
`Metal` (Apple M5) — a real display. Build `origin/main` **`aa16e09`** in a clean detached worktree;
it carries the #708 fix (`e91d6cf`), the #837 fix (`f320535`, `4de4459`) and the #546 verification
(`491554e`).

## What was driven

`O12` as a runner drives it: the `SetViewport` control on
`PlaytestSeams/PlaytestDebug/DebugPanel/Controls` was pressed, calling `set_viewport(390, 844, 1.0)`.

```
{"TEL.1":"set_viewport","TEL.4":"SIT.6","TEL.5":"pass"}
report={"applied":true,"body_text_px":21.0,"debug_panel_visible":false,
        "frame_height_px":844.0,"height":844,"rendered_text_scale":1.31875,
        "text_scale":1.0,"width":390}
window_after=(390, 844)   frame=(390, 844)   content_scale_size=(0, 0)
mode_pick._text_scale=1.31875 = 844/640
```

- The window really is `390×844` with content scaling off, so the reported frame is the drawn frame.
- `_text_scale` equals the rendered frame ratio, not the stale `4.328125` that failed on
  `20261024T201500Z` (#708).
- A repeated call is byte-identical; calling with `text_scale = 4.0` still reports
  `body_text_px = 21.0`, so the seam reports the render, not the argument (D2 / `S13`).
- `debug_panel_visible=false` before and after the press: the #837 fix holds. The only chrome on the
  frame is the collapsed `Show seams` header at the top-left.

## The render, string by string

`UIS.T2` for an 844 px frame is `16 × 844 / 640` = **21 screen px**.

| Control | Text | px | lines | rect | in frame | chrome overlap |
|---|---|---|---|---|---|---|
| `Title` | Choose how to play | 37 | 2/2 | (59,104) 272×111 | yes | 0.0 px² |
| `SharedGame` | Shared game · Last | 21 | 1/1 | (59,231) 272×54 | yes | 0.0 px² |
| `PuzzleStream` | Puzzle stream | 21 | 1/1 | (59,297) 272×54 | yes | 0.0 px² |
| `Quit` | Quit | 21 | 1/1 | (59,363) 82×54 | yes | 0.0 px² |
| `SwitchLocale` | English | 21 | 1/1 | (220,363) 111×54 | yes | 0.0 px² |

Every string clears 21 px; none clips; none leaves the frame; none is under chrome. The title at
37 px is not a violation (`T2` is a minimum) and not clipping — it is `AUTOWRAP_WORD_SMART` and
`get_line_count() == get_visible_line_count()` (2/2), its box growing `99 → 111 px`.

## Limits

- S1–S5 were **not driven** and stay `not-judged` with the #400 sweep, as earlier runs recorded.
- No Web export. The published URL (ADR-0009) does not serve `aa16e09`, so `ENV.2` is the playtest
  scene at that commit, with the same layout code.
- Coverage was not re-measured here; see `manifest.md`.
