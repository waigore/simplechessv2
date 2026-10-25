# Notes — #845 board taps

## What this run judges

Whether a real touch on the painted board selects the square painted under the finger on the Release Web build at
a phone frame. It is defect support for `CMP-presentation` R2, not a story-row run.

## What the run measured

At 390×844 CSS / DPR 2 the build paints the checkerboard at x 39–351, y 376.5–688.5, so one square is 39 CSS px.
White sits at the bottom. Three taps:

| Tap (CSS) | Painted square under the point | Reading after the tap |
|---|---|---|
| 219, 654 | e1 (that square spans y 649.5–688.5) | ring on e1 — the square under the finger |
| 214.5, 630 | e2 | ring on e2 |
| 214.5, 552 | e4 | e2–e4 commits; header `Black to move`, pawn painted on e4 |

Both halves hold: the selected square is the painted square under the point, and the move that follows uses it.

## The confirmed cause

The filing placed the e2 pawn at CSS 219, 654. On the shipped build e2's painted centre is 214.5, 630, and 654 is
inside e1. A tap there correctly selects e1. Two effects made it read as an offset:

- Tapping an empty square with nothing selected produces no visible change, so a tap that misses a pawn reads as
  “the board ignored me”. With White to move only the White pieces on ranks 1–2 can select, which is exactly the
  y 620–680 band the filing's sweep found; ranks 3–8 hold no White piece to select.
- The “one rank above” destination tap was made while e1 was selected, so the King had no e2–e4 move and nothing
  committed. The 97 CSS px in the filing is the distance between its two coordinates, not one square.

The shipped conversion has no rank offset, and the canvas stretch adds none: the control's
event space and the board's canvas space coincide while `Presentation` fills the canvas at the origin.

## The latent coupling this work removes

`Presentation` handed its own local event position to `BoardPresentation.screen_to_world`, which expects canvas
space. That is correct only while `Presentation` sits at the canvas origin. `Presentation._board_world_at` now
applies `get_global_transform_with_canvas()` once; tap select, drag begin, drag move, promotion tap and the release
square all share it. The current scene keeps the node at the origin, so this changes no reading in this run —
confirmed by the byte-identical control run on unmodified `main`. Regression coverage is
`game/board_presentation_test.gd` (`_check_tap_round_trip`) and `game/presentation_test.gd`
(`_exercise_board_taps`), under a non-identity canvas stretch at 720×1280, 1280×720, 800×282 and 390×844.

## What this run does not prove

- One frame on one browser. The unit tests cover four aspects, not a device sweep.
- It cannot show the filing's run: that folder was never committed. The fresh capture above is the record.
- It does not judge drag or promotion gestures on the rendered build; their conversion is shared and covered by
  the pointer test.
