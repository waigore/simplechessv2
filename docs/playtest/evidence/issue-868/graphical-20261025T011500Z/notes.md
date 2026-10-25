# Notes — #868 acceptance, graphical

## What this run is

Acceptance testing for #868 on the published Web client at `https://waigore.github.io/simplechessv2/`, in `ENV.2`
(headless Chrome 144, `--headless=new`, SwiftShader WebGL 2.0, frame 390×844 CSS px, DPR 2, CDP touch emulation).
Protocol leg: `PTU-shared-play` S8 (`US3.3`, `US3.4`).

Independence: this session wrote none of #868's code. It read `game/presentation_test.gd` at PR #873's head
(`36997a6`) and drove the browser itself.

## Build under test, and why the AC cannot be judged on it

The published tree serves CI's release export of `main` at `69a03d4`. PR #873 merged later (`589ed41`) and nothing
republished since, so **the published client predates the diff under acceptance**. The release preset also omits
the playtest seams (ADR-0004 `G2`), so there is no `DBG.3` jump to load the fixture (`c7` pawn, `c8` empty).

Two routes into S4 were tried; both die before the first fixture move:

1. **By taps** — the route every earlier run in this repo used. A tap pair places nothing on this build:
   `exp3/A-selected-e2.png` and `exp3/A-after-e2e4.png` show the board unchanged with no selection, while a
   press-drag on the same board does select (`exp4/after-drag-e7e5.png`, `e7` ringed). The same driver on a fresh
   local export of the same commit reproduces it (`exp3-control/`). So the harness cannot tap a pawn to its last
   rank.
2. **By the real pointer path** — exports expose no scene handles: `Engine` carries only its module table and
   `Godot` is empty, so the run cannot push an `InputEventScreenTouch` into `Presentation.handle_gui_input`.

Criteria 1–3 (White `c7→c8`, Black `c2→c1`, painted Queen tap) are therefore `not-judged` in `ENV.2` — not pass,
not fail. Nothing here is a fail against the diff: the diff is not in the build.

The 12-tap shot (`screenshots/white-stage-12.png`) is still the standard set and the full sequence ends mid-`Resign`
confirm (`screenshots/white-ready.png`), so the run records that route rather than judging from it.

## What the merged check covers (code read)

`_exercise_promotion_choice()` / `_promotion_screen(...)` assert the White and Black fixtures, `PROMOTE_ORDER` at
the 2×2 slots, the painted Queen commit (`occupancy_at(dest).kind == "queen"`), and the `IN.deselect` leg. That is
a unit-level pointer path (`root.push_input` → `handle_gui_input`) that does cover the S4→render→C6 seam, but it
asserts on the session router rather than pixels and never renders in a browser. See [code-read.md](code-read.md).

## Verdict

**Waiting — not accepted, not failed.** What closes #868 is a graphical run of a build containing PR #873; the
published client is older and carries no seams, so S8 cannot run here. #868 stays `status:pending-acceptance`; no
defect is filed, because the gap is the build under test.

## What would unblock

1. Publish `main` at or after `589ed41` (the `Web release` workflow), so a graphical run reads the diff.
2. Or run acceptance on a `Web Playtest` build where `DBG.3` and a scripted probe can enter the fixture — as every
   prior #333/#334 run did. That needs a person or a build job, not the published URL.

## Files

`manifest.md` indexes the artifacts; `readings.json` and the `exp*` folders hold the measurements.
