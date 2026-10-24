# Notes — issue #793 defect run (graphical)

Index and results table: [`manifest.md`](manifest.md). Probe and logs: [`probe/`](probe/README.md).

## Symptom

On a display, the puzzle-play S2 `StreamConfirm` ("Leave the stream?") and S3
`SaveFailure` prompts never appeared: the board repainted over them. Every state check passed —
`ui_state == "S2"`, `_confirm_box.visible == true`, the box at `P:(500,220) S:(280,140)` — so the
defect was in what the renderer draws, not in the flow.

## Readings

Two faults, both found by reading drawn frames (`probe/run-after.log`):

1. **Paint band.** `BoardPresentation` draws board, pieces, and overlays in canvas layers above
   `z_index` 0 (`board_root` 1, `promote_root` 2, `pieces_root` 3, `overlay_root` 4, `AdviceMarks`
   5, a dragged piece 10), while both prompts were placed at `z_index` 0. Tree order cannot win
   against a higher canvas layer, so the board painted over the prompt.
2. **Focused label.** S2 grabs focus on entry (`wants_focus_on_show`), and
   `UiChrome.style_button` overrode only `font_color` / `font_disabled_color`. A focused button's
   label therefore painted in the default theme's `font_focus_color` `#f2f2f2` on the panel's
   `#f7f1e8` — 1.0 contrast, i.e. an invisible Confirm, the only control S2 shows focused.

Samples from the probe at the prompt's own drawn rect (`P:(500,220) S:(280,140)`):
centre `(640,290)` `(0.9098,0.8353,0.7098)` = the panel cream `#E8D5B5`, corner `(505,225)` the
same, copy line `(640,257)` the same, control centre `(585,307)` the C9 ink
`(0.5451,0.3529,0.2353)`. `SaveFailure` reads identically at `P:(500,220) S:(280,136)`
(centre `(640,288)`, control `(640,307)`). The shared-play `ResignConfirm` control, placed the old
way, still reads the same cream in its rect, so the shared-play band is unchanged by design.

## Fix

- `Presentation.OVERLAY_Z = 20` and `Presentation.place_centered_over_board(panel, top_px)`; both
  puzzle prompts use it, and each is reordered after the chrome so tree order agrees with the band.
- `UiChrome.style_button` writes `COLOR_INK` for `font_focus_color`, `font_hover_color`,
  `font_pressed_color`, and `font_hover_pressed_color`.
- Guards: new `game/chrome_paint_test.gd` (`ChromePaintTest`) reads the drawn band against every
  visible board layer, the drawn copy and controls inside the opaque `panel_style()` panel, and the
  `PAL.K4` contrast of every label state; `chrome_placement_test.gd` also checks the copy and
  controls draw inside the panel.

## Reading limit

The saved frames are not trustworthy for the puzzle band on this machine: with the playtest seams
driving the flow, the presented frame that `root.get_texture().get_image()` returns does not repaint
the puzzle panel (state `mode-pick` is still drawn behind the dealt board in `after-01`/`after-02`,
and the S2/S3 frames keep the pre-flow board). The band, rects, and pixel samples in the logs are
read from the live tree and are unaffected. A capture that repaints correctly needs a headless-free
screen recorder or a manual playthrough; that remains the open visual confirmation for review.
