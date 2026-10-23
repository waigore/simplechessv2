# Notes

## What this run is

`#546`'s seam landed with PR #593 (`3cd5c81`), but the issue stayed open. This run closes the
residual gap the landed code left — the report could name a frame the runner never rendered:

- `set_viewport` reported `body_text_px` from the **requested** text scale even when the resize
  was refused, so a headless call at 390×844 answered "21 px" while the frame stayed `100×100`.
  That is the failure mode `S13` exists to forbid: a report that does not match what renders.
- The report carried no frame size, so nothing tied `body_text_px` to a frame height.

## What changed

- `game/playtest_seams.gd` — the report gains `frame_height_px`; `body_text_px` is the shipped
  ratio for **that** frame, `0` when the seam holds no frame. A bound `CMP-presentation` still
  supplies the size and names the frame it measured.
- `game/presentation.gd` — `scaled_body_px()` and `frame_height_for_body_px()`, the two static
  ends of the one `UIS.T2` ratio; `body_text_screen_px()` reads through them.
- `game/playtest_gate.gd` — `has_display()`, `in_frame()`, `frame_height()`: the `I6` limbs the
  seam asks about, so no seam code reads `DisplayServer` or the tree directly.
- `game/playtest_seams_test.gd` — `S13` body/ENV boundary follows the limb the runner really is;
  the seam's own `body_text_px` must equal the presentation ratio of its own `frame_height_px`.

## Limits of this run

- **Environment.** The unit-test binary is `--headless`, and this repo's tests build the seam
  outside the running tree (they instantiate it and never wait a frame), so `in_frame()` is
  `false` for them and the "seam names its own frame" limb is not exercised here. The bound
  presentation limb and the ratio maths are. An `ENV.2` run through `PTU-mode-pick` S6 still
  owes the 390×844 screenshot.
- **`I6` wording.** `I6` expects headless and graphical to "both expose `S11`–`S13`". A headless
  session can expose `O12` and its report, but cannot apply a viewport — `DisplayServer` has no
  window to resize. The seam treats that as "no applied viewport, no frame claim" rather than
  inventing a height. If `I6` means a headless `S13` must still report the requested frame's
  ratio, that is a spec decision against #506; it is not made in this PR (`#546` D5: no `specs/`
  edit).

## How it was measured

- `godot --headless --path game --import --quit`
- `python3 .github/scripts/gdscript_tests.py test` and `coverage`
- `python3 .github/scripts/spec_lint.py`
- `gdformat --check game`, `gdlint game` (gdtoolkit 4.5.0)
- `godot --headless --path game`, stopped after 20 s
