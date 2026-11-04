# Acceptance references — issue #506

Citation check for the rows in [`accept-506-criteria.md`](accept-506-criteria.md). Each row was read in the tree at `origin/main` `0d41a56`, not taken from the verification comment.

## Citations that resolve

| Cited | Where it is read |
|-------|-----------------|
| `SIT.4`–`SIT.6` rows, seam cells | [`specs/playtest/tools-situational.md`](../../../../specs/playtest/tools-situational.md) |
| `S11`–`S13` registrations and invariant `I6` | [`specs/technical/verification.md:23–25`](../../../../specs/technical/verification.md) |
| `PTU-mode-pick` S1, P4, F2, S6 | [`specs/playtest/ux/mode-pick.md`](../../../../specs/playtest/ux/mode-pick.md) |
| `EX.loading` end state | [`specs/ux/exceptions.md:11`](../../../../specs/ux/exceptions.md) |
| `PER.R1`, `PER.R9` | [`specs/view/perception.md:11`](../../../../specs/view/perception.md) |
| `PAL.K1`, `PAL.K2`, `PAL.K9` | [`specs/aesthetics/palette.md:12–13`](../../../../specs/aesthetics/palette.md) |
| `C7` band, `C10` ticks | [`specs/aesthetics/palette/swatches.md:15,18`](../../../../specs/aesthetics/palette/swatches.md) |
| `UIS.T2` | [`specs/aesthetics/ui-style.md:12`](../../../../specs/aesthetics/ui-style.md) |
| Timing and build-id fields | [`specs/playtest/evidence-manifest.md:11–12`](../../../../specs/playtest/evidence-manifest.md) |

## Playtest gate

[`specs/playtest/playtest.md`](../../../../specs/playtest/playtest.md) §Gate requires a playtest run only when an issue's deliverables change playable behavior. The three landings (#547, #644, #832) change `specs/` files only, so no run folder is written and no protocol verdict is owed.

## Outcome

All eleven criteria pass, no defect is filed, and #506 moves `status:pending-acceptance` → `status:accepted`. The issue stays open; closure belongs to the planner.
