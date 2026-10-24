# Notes

## What this run is

Acceptance test for **#708** — `O12`/`S13` phone-width reflow does not size the rendered text to
`UIS.T2`. The defect was found during acceptance of #546 at `origin/main` `d707b7e`; this run
re-judges the same `PTU-mode-pick` S6 step on a build that carries the fix.

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`, graphical (`ENV.2`): `DisplayServer.get_name()` = `X11`
  under `Xvfb` (`DESKTOP`), Mesa llvmpipe OpenGL 4.5.
- Build: `origin/main` `ffc5094`, in a clean detached worktree. The fix `e91d6cf`
  ("Render the S13 phone frame at its own size and reflow it (#546/#708)") is an ancestor.

## What was judged

**S6 (Graphical, `SIT.6`)** — `SetViewport` was pressed on the debug panel, exactly as a runner
drives `O12`; the running window resized to `390×844`. The seam reported

```
report={"applied":true,"body_text_px":21.0,"frame_height_px":844.0,"height":844,
        "rendered_text_scale":1.31875,"text_scale":1.0,"width":390}
```

`UIS.T2` for an 844 px frame is `16 × 844 / 640` = **21 screen px**. Against that:

| Control | Text | font px | own height | resolves frame | clipped | ≥ `UIS.T2` |
|---|---|---|---|---|---|---|
| `Title` | Choose how to play | 37 | 111 | 844 | no (2 wrapped lines, both visible, content height 111 = rect 111) | yes |
| `SharedGame` | Shared game · Last | **21** | 54 | 844 | no | yes |
| `PuzzleStream` | Puzzle stream | **21** | 54 | 844 | no | yes |
| `Quit` | Quit | **21** | 54 | 844 | no | yes |
| `SwitchLocale` | English | **21** | 54 | 844 | no | yes |

The panel sits at `(35, 80)` with size `320 × 361` inside the 390×844 frame, so nothing overflows
the viewport.

## Why this is a pass and the #546 run was a fail

#546 measured, at `d707b7e`, `mode_pick._text_scale = 4.328125` (a desktop ratio) and four buttons at
`font_px = 1` with `resolves_frame = 44` — each sizing text from its own 44 px height. Both causes
filed in #708 are gone on this build:

1. `UiChrome.frame_height_of` now resolves the **tree root** (844) for every control and falls back
   to the project height only when headless; no control sizes from its own box (`own_h` 54/111 vs
   `resolves_frame` 844).
2. `mode_pick._text_scale` is now `1.31875` = `844/640`, i.e. the frame the screen renders into, not
   the desktop ratio.

The seam report still claims 21 px, and now the render delivers exactly 21 px — the report and the
render agree, which is the property `S13` exists to guarantee.

## Limits

- This is a Godot graphical session under `Xvfb`, **not** a Web export. `ENV.2` is the required
  environment and the layout path exercised is the same `canvas_items`/`expand` code. The fix turned
  content scaling off for the `O12` frame (`content_scale_size = (0, 0)` in this run), which is what
  removed the export-dependent elastic scaling. A Web confirmation remains a reasonable follow-up on
  #402's release sweep, but it is not a gate for this defect.
- S1–S5 of `PTU-mode-pick` were not driven here (recorded `not-judged`); they belong to #400.
- `probe/zz_accept708_probe.gd` is a throwaway harness. It is archived with this evidence and was
  never committed to `game/`.
