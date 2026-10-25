# Notes — #845 board taps

## What this run judges

Whether a touch on the painted board selects and moves to the square painted under the finger, on the Release Web
build at a phone frame. Defect support for `CMP-presentation` R2, not a story-row run.

## What the run measured

At 390×844 CSS / DPR 2 the build paints the checkerboard at x 39–351, y 376.5–688.5, so one square is 39 CSS px;
White sits at the bottom.

| Check | Reading |
|---|---|
| Filing coordinate 219, 654 | ring on **e1** (that square spans y 649.5–688.5) |
| Painted e2 centre 214.5, 630 → e4 centre 214.5, 552 | ring on e2, then **e2–e4 commits**, pawn painted on e4 |
| d2→d4, b1→c3, g1→f3 | ring on the tapped source, **each move commits**, header flips to Black |

Every outcome is read from pixels: the selection ring's square and the header's side (`readback.mjs`), never from
the driver's belief.

## The confirmed cause

The filing placed the e2 pawn at CSS 219, 654. On this build e2's painted centre is 214.5, 630, and 654 is inside
**e1**, so a tap there correctly selects e1. Two effects made that read as an offset:

- Tapping an empty square with nothing selected paints nothing, so a miss reads as “the board ignored me”. With
  White to move only ranks 1–2 hold selectable pieces — the y 620–680 band the filing's sweep found.
- The destination attempt ran while e1 was selected, so the King had no e2–e4 move and nothing committed.

So the shipped conversion has no rank offset at this frame. An earlier run in this folder recorded the same three
taps, and the verifier read its `board-03` shot as a pawn on e4 with `ring: ""`; that shot is taken before the move
settles, and `board-04-after` is the committed board. This run replaces that folder with a driver that asserts the
outcome instead of leaving it to prose.

## The coupling removed

`Presentation` handed its own local event position to `BoardPresentation.screen_to_world`, which reads canvas
space — correct only while the presentation sits at the canvas origin. `Presentation._board_world_at` applies
`get_global_transform_with_canvas()` once; tap select, drag begin/move, promotion tap and the release square share
it. The current scene keeps the node at the origin, so no reading in this run changes.

## Regression coverage

- `game/board_presentation_test.gd` `_check_tap_round_trip` — painted centre → frame stretch → inverse → square,
  at 720×1280, 1280×720, 800×282 and 390×844, requiring a non-identity stretch.
- `game/presentation_test.gd` `_exercise_board_taps` — the pointer path at 390×844, judged on what the board
  **paints** (selection ring and piece ink) at an offset presentation and at the origin; a router-state assertion
  would pass while the pointer path pointed elsewhere.

## What this run does not prove

- One frame on one browser. The unit tests cover four aspects, not a device sweep.
- It does not judge drag or promotion gestures on the rendered build; they share the conversion.
