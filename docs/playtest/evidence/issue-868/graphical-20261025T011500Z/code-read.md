# Code read — the merged check against the AC

`game/presentation_test.gd` at `36997a6` (PR #873) adds `_exercise_promotion_choice()` and `_promotion_screen(...)`.

| AC | Where it is asserted |
|----|----------------------|
| White `c7→c8` → S4 fields, pawn on `c7`, `c8` empty | `_promotion_screen("white", "c7", "c8", "queen")` |
| Chooser holds `PROMOTE_ORDER` at the 2×2 slots | `_chooser_sprites(...)` |
| Black `c2→c1` → same with `pending_to == "c1"` | `_promotion_screen("black", "c2", "c1", "queen")` |
| Painted Queen tap commits through C6 | `_tap_promotion_sprite(...)`, then `occupancy_at(dest).kind == "queen"` |
| `IN.deselect` leg keeps the pawn | `_promotion_screen("white", "c7", "c8", "")` |
| Fails when the seam breaks | the verification comment's two break-and-restore runs |

Scope: this is a unit-level pointer path (`root.push_input` → `handle_gui_input`) run headless. It exercises the
S4→render→C6 seam the issue says nothing covered, and it is wired into the CI-enforced suite. It is not a graphical
run: it asserts on the session router rather than on pixels, and it never renders in a browser. Whether that is
enough to close #868 is a judgement the acceptance criteria leave open — they ask for the check, and the check
exists in the merge — but the graphical half of the protocol still has no evidence from this session.
