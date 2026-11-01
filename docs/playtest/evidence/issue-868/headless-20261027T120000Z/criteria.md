# Criteria — #868 acceptance

Build `origin/main` `a1fa8e3`, Godot `4.7.2`. Deliverable: PR #873 (merged
`36997a6`), one file, `game/presentation_test.gd`. Read in this run, not taken
from the implementation or verify prose.

## AC1 — White `c7→c8` drives the screen to S4

`_exercise_promotion_choice()` → `_promotion_screen("white", "c7", "c8", "queen")`
(`game/presentation_test.gd:146`). Asserts `play_ui_state == "S4"`,
`pending_promote_from == "c7"`, `pending_promote_to == "c8"`, the pawn still on
`c7`, and `c8` empty. The four sprites are checked against
`SharedGameSession.PROMOTE_ORDER` at the 2×2 slots by `_chooser_sprites()`, which
also asserts each slot resolves to its own kind through `promotion_kind_at`.

## AC2 — Black `c2→c1` gives the same observables

`_promotion_screen("black", "c2", "c1", "queen")` (`:148`), same assertions with
`pending_promote_to == "c1"` and the pawn still on `c2`. Kings are placed so
neither side is in check (`e1`/`h8` White case, `a1`/`e8` Black case), matching
the fixture pattern the body names.

## AC3 — a painted tap on the Queen commits through C6

`_tap_promotion_sprite()` → `_tap_world()` → `_tap_frame()`, which pushes a real
`InputEventScreenTouch` press/release through `root.push_input` (`:327-338`), so
the tap reaches `Presentation.handle_gui_input` → `_on_pointer_up`. No direct
`show_promotion_choice()` or `commit_promotion()` call exists in the file
(grep: the only hits are two comments). After the tap the check asserts
`occupancy_at(dest).kind == "queen"` with the placing side's colour, the origin
empty, `side_to_move()` flipped, `play_ui_state == "S1"`, and
`promotion_kind_at(framed_center(dest)) == ""` so the overlay is proven cleared.

## AC4 — the deselect leg drops the choice

`_promotion_screen("white", "c7", "c8", "")` taps the destination centre between
the sprites and asserts `S1`, both pending fields cleared, the destination empty,
the pawn still on `c7`, `selected_piece == "c7"`, and the overlay cleared.

## AC5 — named in the PR and fails when the seam breaks

Named: `_exercise_promotion_choice()`, PR #873, wired into the CI-enforced suite
from `_after_boot` (`:62`). Break-and-restore runs in `logs/mutations.txt` show
each of the three legs failing by name:

| Broken leg | Failure |
|---|---|
| render (`_apply_choice_overlays`) | `#868 white c7→c8: no chooser overlay at c8` |
| commit (`_on_pointer_up` C6) | `#868 white c7→c8: a tap on the queen sprite placed (nothing)` |
| deselect (`clear_selection` S4) | `#868 white c7→c8: deselect left state S4` |

## Scope

PR #873 changes `game/presentation_test.gd` only. No production file and no
`specs/` file is touched, so no playable behavior changes.

`PTU-localization` S3/P5 is not judged here by the body's own instruction
("then unblocks … judged on the `#334`/`#333` side, not here").
