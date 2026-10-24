# Notes

## What this run is

Implementation evidence for **#837**, the defect that failed #546's acceptance at `PTU-mode-pick`
S6 (`../issue-546/graphical-20261025T090000Z/`). The failure there was not typography: every string
already cleared `UIS.T2`. The run's own debug panel
(`PlaytestDebug/DebugPanel`) drew its column over the mode-pick panel and fully covered
`Shared game · Last`, partly covered `Puzzle stream` and the title.

## Which reading of the cause was taken

The defect named two readings — (a) the panel must not overlap shipped screens at phone width, or
(b) the seam needs a way to hide it before a capture.

Both are satisfied by one change, and it does not depend on which reading the product owner
would prefer:

- The panel is **collapsed by default** in a playtest build (reading a): a runner reading or
  judging a screen no longer has the seam chrome over it.
- `O12 set_viewport` **collapses it before applying the frame** (reading b): a capture is clean
  even when the runner had expanded the panel to reach `SetViewport`.

The runner is never stranded: the collapsed panel draws a `Show seams` header that restores the
controls, and every seam node keeps its path (`PlaytestDebug/DebugPanel/Controls/<control>`),
so an address does not depend on the panel's state. `I3` (`verification.md`) is the reason the
collapsed state still draws a header — it names "debug UI" as one thing, present in playtest
builds and absent from release, not as a state that may disappear.

## Why the seam's report says so

`O12`'s report gains `debug_panel_visible`. A judge reading the report can tell a clean frame from
a covered one without inspecting pixels, and the `S13` unit guard fails a report that names a
frame while this run's chrome is still on it (`_application_matches`).

## Environment

- Godot `4.7.2.stable.official.ed1daf0bf`, graphical (`ENV.2`), `macOS` Metal display.
- Build: branch `defect/837-debug-panel-covers-mode-pick` on `origin/main` `906b8b3`.

## Judgement

S6 passes: nothing is covered, every string is ≥ 21 px at an 844 px frame, and nothing clips. The
board is not on this screen, so `S13`'s `UIS.T2` claim is judged on the mode-pick copy, as the
protocol asks.

## Limits

- S1–S5 of `PTU-mode-pick` were not driven here and stay with the #400 sweep.
- No Web export was run; `ENV.2` here is the shipped Godot playtest scene with the same
  `canvas_items` / `expand` layout code, as in the acceptance run this defect came from.
- The probe is throwaway and lives only in `probe/`; `game/` carries no probe.
