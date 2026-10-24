# Notes

## Independence

This session is an unattended `issue-workflow-accept-agent` run (parallel id 1). It posted no
implementation or verification comment on #427, and it took no measurement from the implementation
or verification comments. The numbers in `manifest.md` come from the two logs in `logs/`, which this
run produced.

The current implementation summary (PR #642) was authored by a different identity than the one that
dispatched this run, but authorship is not what independence rests on here: the checks were re-run
against the tree.

## How the measurements were taken

- Both runs are the demo's own autodrive (`DEMO_AUTODRIVE=1`), which scripts the full exercise and
  mate sequences and fails the process on any illegal move, over-budget travel, or layout problem.
- Piece bodies, coordinate typography, bevel geometry and the end panel are printed by the demo's
  built-in probes (`measure_piece_bodies`, `measure_typography`, `measure_coord_labels`,
  `_check_end_panel`).
- The rendered coordinate ink probe (`DEMO_COORD_PROBE=1`) reads back the real framebuffer in the
  graphical run and applies the `PER.R7` rules to actual pixels. The headless run skips it, which is
  why both environments were run.
- Frames in `screenshots/` were written by the graphical run via `DEMO_SHOT_DIR`.

## Environment notes for a human re-run on macOS

- The first graphical attempt hung indefinitely: the demo awaits `RenderingServer.frame_post_draw`,
  which never arrives while the window is not being presented. Relaunching without a redirected
  stdout-to-pipe combination completed normally (`logs/autodrive-graphical-try2.log`). Recorded so a
  future runner does not read the hang as a demo defect.
- `godot --headless --path demos/shared-game --import --quit` was run once beforehand.

## Scope of this run

- No human played a game; the autodrive is the reference run, and tap/drag share its input path.
- Item 2 (select cue) is #570's deliverable and was not judged.
- In the mate frame the end panel covers rank-1 numerals 3–5. It is a game-over modal, so no live
  coordinate reading is lost; recorded as a cosmetic observation, not a fail.
