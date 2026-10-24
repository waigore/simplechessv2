# Notes

## What this run is

Acceptance test for **#546** (`SIT.6` phone-width legibility, seam `S13`, op `O12`) on `origin/main`
`d707b7e`. It is the `PTU-mode-pick` **S6** judgement the earlier headless folder
(`../headless-20261024T190000Z/`) left open ("an `ENV.2` run through `PTU-mode-pick` S6 still owes the
390×844 screenshot"), plus enough of the protocol to judge it whole.

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`, graphical (`ENV.2`): `DisplayServer.get_name()` = `macOS`,
  Metal. The shipped playtest scene `game/main.tscn`.
- Build: `origin/main` `d707b7e`, containing the #593, #652 and #653 deliverables.

## What was judged

**S6 (Graphical, `SIT.6`)** — `SetViewport` was pressed on the debug panel, exactly as a runner drives
`O12`; the window resized to `390×844`. The seam reported
`{"applied":true,"frame_height_px":844,"rendered_text_scale":1.31875,"body_text_px":21}`. Against
`UIS.T2` for an 844 px frame (≥ 21 screen px) the render does not comply: every visible mode-pick
label and button draws **below** that size. `logs/graphical-s6.log`, `screenshots/s6-phone-390x844.png`.

**S1–S5 (Headless, `ENV.1`)** — `not-judged`; this run did not drive them. The #400 sweep judges them.

## Why S6 fails

See [findings.md](findings.md). In short: `UiChrome.frame_height_of` sizes text from a control's own
44 px height, not the frame, and `Presentation._on_frame_resized` hands panels a ratio from a
different frame than the one `O12` set. The seam's report is coherent; the render is not.

## Limits

- No browser / Web export was available. The frame was the shipped Godot playtest build in a real
  display, with the same `canvas_items` / `expand` layout code. A Web re-run is worth doing after
  the defect (#708) is fixed.
- `probe/zz_accept546_probe.gd` is a throwaway harness for this run; delete it when #708 closes.
