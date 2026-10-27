# Notes — #868 acceptance, headless run

Build `origin/main` `a1fa8e3`, Godot `4.7.2`. Per-criterion mapping:
`criteria.md`. Logs: `unit-tests.txt`, `mutations.txt`.

## Why this run accepts where two earlier ones waited

Two prior acceptance runs stayed on `pending-acceptance` because a graphical
`PTU-shared-play` S8 reading could not be produced: the published build
predated the diff, then the browser harness could not keep painting the canvas.
Both left the diff unjudged.

This run judges it, on three grounds read from the contract:

1. **The deliverable changes no playable behavior.** PR #873 changes exactly one
   file, `game/presentation_test.gd`. `accept-project-issue` step 3 requires
   playtesting only "when the issue's deliverables change playable behavior
   (game or code)" and says plainly: "Do not require playtest evidence when the
   issue does not change playable behavior." A test file adds a check; it does
   not alter what a player sees or does.
2. **The body defers the graphical row.** Its `PTU-localization` S3/P5 sentence
   reads "then unblocks … an observation that follows from the above, not a
   checkbox this defect's implementer ticks. It is judged on the `#334`/`#333`
   side, not here."
3. **Every "Done when" item is a statement about the check**, not about pixels:
   the S4 fields, the painted-tap commit, the deselect leg, and "fails on a
   build where the S4→render→C6 seam is broken". All are judged below.

The prior folders stay in the tree under `evidence.md` §Retention; this run does
not delete them, and a reader can see the graphical question was attempted twice.

## What was independently re-derived

- The suite on a clean `origin/main` worktree: 33 passed.
- The input route: `_tap_frame()` pushes real `InputEventScreenTouch` events via
  `root.push_input`, so `Presentation.handle_gui_input` → `_on_pointer_up` is the
  path under test. No direct `show_promotion_choice()` / `commit_promotion()`
  call exists in the test file.
- Non-vacuity, by breaking each leg in turn (see `mutations.txt`): the render
  leg, the C6 commit leg, and the S4 deselect leg each fail the check by name,
  then each file was restored and diffed clean.
- Scope: PR #873 touches one test file; no `specs/` or production change.

## Non-blocking observations

- `spec_lint.py` reports one pre-existing warning (`specs/view/glossary.md`
  duplicate `Diagram`), unrelated to this defect.
- The `#845` acceptance note about `presentation_test.gd` reading paint rather
  than the router holds here too: `_chooser_sprites()` asserts node positions
  and `promotion_kind_at()` hit-testing, not only session fields.
