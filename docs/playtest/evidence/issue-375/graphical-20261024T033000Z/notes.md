# Notes

Back to [`manifest.md`](manifest.md). Issue #375, epic #36.

## What this run exists for

The 2026-10-24 verify pass failed #375 on two criteria found on a graphical run of `origin/main` `fb1e57e`: AC4 — rendered advice marks at **58.6%** of a piece body against `PER.R5`'s 10% — and AC6/AC10 — `g1f3` refused with the S3 `EX.error` panel up. Both are re-measured here on the shipped release graph, on the fix branch. Everything the verify passed stays passed; the graphical halves of `shared-play` and `shared-setup` stay owed as the 2026-10-23 headless run recorded.

## AC4 — the ink

`logs/ink_probe.gd` renders each of the twelve piece types on e4 three ways (empty, piece only, piece plus the arrow e4→e2) and reads the frames back, classifying pixels as ink (appears only with advice), body (`PER.R1`'s opaque silhouette, FRM.P1 inside the 0.85 SPC.E1 box) and overlap. Worst of twelve: **1.73%** — black King 1.73%, white King 1.66%, queens ≈ 0.9%, all narrower bodies 0.00%. Method: [`setup.md`](setup.md).

The 58.6% reading is gone because the brackets no longer ring the square at arm 0.26 / stroke 0.08: their ring now starts 0.335 from the centre, outside the widest body half-width (knight, 0.20), and only the arrow can touch a body, from 0.32 to 0.60 along the move. `PER.R1` improves with it — no bracket crosses a silhouette.

An early pass of this probe measured 0 ink for every piece: it set the marks *before* rendering the position, and the presentation re-applies the advice fields on every position render. The probe now sets them after, and the log shows 583 ink pixels per frame.

## AC6 / AC10 — the S3 leg

`logs/gesture_probe.gd` enters play with Advice On and T9 on `http://127.0.0.1:1/advice`, a closed port, so the shipped transport fails on its own — no simulated peer, no Stockfish. Observed: the client parks (`online == false`, `failed()`), the session reads `S3`, the **`EX.error` panel is up**, Dismiss hides it and returns `S1`.

**Pointer gestures do not move a piece** — `g1f3`, `g8f6`, `e2e4` as drags and taps were refused, side unchanged, while `input_commit("g1","f3")` in the same session at the same moment succeeds. Filed on its own `type:defect`: `_on_pointer_down` sets `_press_active` and a frame-boundary reset clears it, so a press and release inside one frame reach the release with no press — what a finger's tap does and what this probe does. It is not S3-specific (the drag after Dismiss was refused too), but it is what blocks judging S3's "board still playable" leg by gesture, the way the verify attempted.

## Fixed on the branch

`game/session_router.gd` — the router repainted the play screen only when the advice values changed, so entering or leaving `EX.error` never repainted and the S3 panel never appeared; `_advice_shown` now carries `advice_error`. `game/advice_marks.gd` — the ink sizing, with `bracket_inner_edge()` and `body_coverage()` as the unit-checkable form. `game/advice_ui_test.gd` — `_marks_fit_the_body_bound`, and an S3 leg that moves after the park, by the side to move, on both sides, asserting the service stays offline and the error stays up.

## Not judged here

`PAL.C7` / `PAL.K5` contrast and `UIS.T2` were re-measured by the verify and are unchanged — no ink colour or text size moved. No sound plays for advice in any phase.
