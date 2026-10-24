# Findings

Readings from a genuine 390×844 frame after `O12 set_viewport` on `origin/main` `d707b7e`
(`logs/graphical-s6.log`):

```
uis_t2_need_px_for_screen=21
what_seam_claims_body_text_px=21.0
mode_pick._text_scale=4.328125
name=Title font_px=16 own_h=24 resolves_frame=24 below_t2=true
name=SharedGame font_px=1 own_h=44 resolves_frame=44 below_t2=true
name=PuzzleStream font_px=1 own_h=44 resolves_frame=44 below_t2=true
name=Quit font_px=1 own_h=44 resolves_frame=44 below_t2=true
name=SwitchLocale font_px=1 own_h=44 resolves_frame=44 below_t2=true
```

No label is clipped (the "clipped" half of `F3` does not fire); every one is sub-`UIS.T2`, the other
half of `F3` and of `P5`.

## Cause 1 — a control's own height is taken for the frame

`game/ui_chrome.gd` `frame_height_of` returns `control.size.y` before it reads the tree root. A
mode-pick button is 44 px tall, so `responsive_text_scale` computes `44 / 640` and
`scaled_px(16, 0.06875)` rounds to **1**. Four buttons then draw at the theme fallback.

## Cause 2 — the reflow ratio comes from another frame

`game/presentation.gd` `_on_frame_resized` gives the panels `text_scale()`. In this run
`mode_pick._text_scale = 4.328125` (a desktop frame) while the screen renders into 844 px, which
needs `1.31875`. The restyled sizes do not describe the render.

The seam report itself is coherent — it names the frame and the `UIS.T2` size for it. What renders
is not that, so `S13` can claim compliance the screen does not have. That gap is #708.

## Not new in this task

At a 1280×900 desktop window **before** `O12`, the same `frame_height_of` path draws `Title` at 5 px.
It is not introduced by the resize, but it is what makes the S6 leg fail, and it contradicts the "one
place `UIS.T2` sizes are applied" statement at `game/ui_chrome.gd:191`.
