# Notes

## What this run is

Acceptance of **#546** (`SIT.6` / `S13` / `O12`). The S6 leg failed once before
(`../graphical-20261024T201500Z/`, defect #708), the fix landed (`e91d6cf`), #708 was accepted on its
own S6 re-run, and #546's verification passed (`e47b8ef`). This run judges S6 on current `origin/main`.

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`, graphical (`ENV.2`): `DisplayServer.get_name()` =
  `macOS`, `Metal` — a real display, not `Xvfb`.
- Build: `origin/main` `f1a62f0`, clean detached worktree.

## What was driven

`O12` was driven as a runner does: `SetViewport` pressed on the playtest debug panel, which calls
`set_viewport(390, 844, 1.0)`. The seam reported

```
report={"applied":true,"body_text_px":21.0,"frame_height_px":844.0,"height":844,
        "rendered_text_scale":1.31875,"text_scale":1.0,"width":390}
window_after=(390, 844)   screen_frame=(390, 844)   content_scale_size=(0, 0)
```

`UIS.T2` for an 844 px frame is `16 × 844 / 640` = **21 screen px**. `mode_pick._text_scale` is
`1.31875` = `844/640`, so text is sized from the frame that renders — #708 cause 2 stays fixed — and
no control resolves its size from its own box — cause 1 stays fixed.

## Why S6 still fails

The typography is right; the render is not legible anyway:

- The playtest **debug panel** (`PlaytestDebug/DebugPanel`) draws over the mode-pick panel at phone
  width. In the capture it fully covers `Shared game · Last` and partly covers `Puzzle stream` and
  the title.
- S6 asks that every label and body string be legible at the phone-width viewport; `P5` requires
  legibility without clipping and `F3` fires on clipped text at phone width. A string under opaque
  debug chrome is legible by neither.
- So `P5` fails and `F3` fires although every `font_size` is ≥ 21 px. Reading font sizes alone —
  all the earlier #708 re-run did — cannot see this. The screenshot can.

This is a **game/interface** failure in the playtest build's rendering, so it is filed as a defect,
not raised as a spec question.

## What passed

- `O12` applies width, height and text scale on `ENV.2`: the window really is `390×844`.
- The report is coherent and read from the rendered frame.
- The seam sets and clamps no font size.
- One reflow path, no phone-width theme, no parallel layout.
- Release absence of `O12` is covered by the `S13`-named release cases and `release_scene_test`.
- Tests, coverage, lint and spec lint are green on this build; this run changed no code.

## Limits

- S1–S5 of `PTU-mode-pick` were not driven here (`not-judged`); they belong to #400.
- The debug panel is playtest-only. If S6 is instead meant to be judged on a render without it, the
  defect is about the seam's chrome rather than the shipped layout — the observable failure is the
  same, and either way the seam cannot supply S6 evidence while it covers the screen it measures.
- No Web export was run; `ENV.2` here is the shipped Godot playtest scene, the same
  `canvas_items`/`expand` layout code.
