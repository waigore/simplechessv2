# Notes

Back to [`manifest.md`](manifest.md). Issue #375, epic #36.

## What this run exists for

The 2026-10-24 fail named two must-fixes on a graphical run of `fb1e57e`: `PER.R5` ink at 58.6% of a piece body, and S3 refusing a local move. PR #752 claims both fixed, and records the remaining S3 pointer leg as `fail` because of a separate defect (#753). This run checks the fixes on the same shipped graph, and checks the #753 explanation against what #753 says.

## S3 and a local move

With the fetch failed and parked (`online == false`, `advice_error == true`), the router reads `S3`, `gestures_available()` is true, `can_place("g1","f3")` is true, and `handle_input_commit("g1","f3")` lands the move: the side goes to black while the `EX.error` panel stays up and the session stays offline. A real pointer tap pair does the same — the tap on g1 selects, the tap on f3 moves, and the screen stays S3. The 2026-10-24 refusal (`shared.move … illegal` with the client parked) does not reproduce on this branch.

## Why #753 does not decide AC6

The implementor's verdicts record the S3 pointer leg as `fail`, on #753: `_reset_gesture()` on a repaint clears `_press_active` before the release arrives. #753's own reproduction is narrower — a press and release **with no rendered frame between them**. Its triggering gesture log shows refusals with a frame between events too, so on the evidence available the cause is either wider than its description or the implementor's probe shape differs from a player's. Either way it is not reproduced here: a tap pair one frame apart moves a piece in S3 on the shipped graph, so S3's "board still playable" holds for a finger's normal timing, and #753 stays a real defect on its own terms.

## Not re-judged here

`PER.R5` ink (the unit bound runs in this branch's suite; the pixel measurement is the implementor's `ink_probe.gd`), `PAL.C7` / `UIS.T2`, "Advice ready", copy keys, sound, and AC11's reachable-backend run (the 2026-10-23 headless run stands). Those legs were judged on earlier runs of the same code paths, unchanged here.
