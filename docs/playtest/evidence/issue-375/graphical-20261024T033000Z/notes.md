# Notes

Back to [`manifest.md`](manifest.md). Issue #375, epic #36.

## What this run exists for

The 2026-10-24 verify pass failed #375 on two acceptance criteria found on a graphical run of `origin/main` `fb1e57e`:

1. **AC4 / `PER.R5`** — the rendered advice marks covered **58.6%** of a piece body against a 10% bound.
2. **AC6 / AC10** — with the S3 `EX.error` panel up after a failed advice fetch, `g1f3` was refused (`shared.move … illegal`).

This run re-measures both on the shipped release scene graph, on the fix branch, in a real 1280×720 window. It does not re-open anything the verify passed (AC1, AC2, AC3, AC5, AC7, AC8, AC11) and does not attempt the graphical halves of `shared-play` / `shared-setup`, which remain owed exactly as the headless run recorded.

## AC4 — how the ink was measured

`logs/ink_probe.gd` loads `main_release.tscn`, enters Shared play with Advice Off, and for each of the twelve piece types renders the same position three ways: empty square, piece only, piece plus the `show_advice` arrow e4→e2. Frame pixels are read back after `RenderingServer.frame_post_draw`:

- **ink** = pixels that differ between *piece only* and *piece + advice*;
- **body** = pixels that differ between *empty* and *piece only* — the opaque silhouette `PER.R1` and `PER.R5` measure against (FRM.P1: the body inside the 0.85 SPC.E1 box, not the square and not the canvas);
- **coverage** = ink pixels that also fall on body pixels ÷ body pixels.

Result (worst of twelve): **1.73%** — white King 1.66%, black King 1.73%, queens ≈ 0.9%, every narrower body 0.00%. The 58.6% reading is gone because the brackets no longer ring the square at arm length 0.26 / stroke 0.08; they now sit in the square's corner margin (ring at 0.335 from the centre, outside the widest body half-width of 0.20), and only the arrow can touch a body, from 0.32 to 0.60 along the move. `PER.R1` improves too: no bracket crosses a silhouette.

A first pass of this same probe reported 0 ink for every piece — the probe's own bug: it called `render_advice` before `render_position`, and the presentation re-applies the advice fields whenever it renders a position (`presentation.gd` `_show_advice_update`). The probe now sets the marks after the position and the log shows the expected 583 ink pixels per frame.

## AC6 / AC10 — what the S3 leg showed

`logs/gesture_probe.gd` enters Shared play with Advice On and T9 aimed at `http://127.0.0.1:1/advice` so the shipped transport fails on its own (no simulated peer, no Stockfish). Observed:

- the failed fetch parks the client (`online == false`, `advice_client.failed()`), the session reads `S3`, and the **`EX.error` panel is up** — it was *not* up before this branch's fix;
- pressing Dismiss hides the panel and returns `S1`;
- **real pointer gestures do not move a piece** — `g1f3`, `g8f6`, `e2e4` as drags and taps were all refused, side to move unchanged, while `input_commit("g1","f3")` in the same session at the same moment succeeds.

The pointer half is filed on its own `type:defect`: `_on_pointer_down` sets `_press_active` and a frame-boundary reset clears it, so a press and release that arrive inside one frame reach the release with no press. That is what this probe does, and it is also what a finger's tap does. It is not specific to S3 (after Dismiss the same drag was refused too), but it is the remaining obstacle to judging S3's "board still playable" leg by gesture the way the verify attempted.

## Findings the branch fixes

- **`game/session_router.gd`**: the router re-rendered the play screen only when the advice values changed, so entering or leaving `EX.error` never repainted the panel and the S3 panel never appeared. `_advice_shown` now carries `advice_error`. The headless twin never caught it because it read the session's state, not the panel.
- **`game/advice_marks.gd`**: the ink sizing above, with `bracket_inner_edge()` and `body_coverage()` as the unit-checkable form of both bounds.
- **`game/advice_ui_test.gd`**: `_marks_fit_the_body_bound` (new, PER.R5), an S3 leg that moves *after* the client is parked, by the side to move, on both sides, and asserts the service stays offline and the error stays up; `_leave_clears_marks` now continues from the right side.

## Not judged here

`PAL.C7` / `PAL.K5` contrast and `UIS.T2` eval size were re-measured by the verify and unchanged by this branch; no new ink colour or text size was introduced. No sound plays for advice in any phase. The graphical `shared-play` (marks and toggle) and `shared-setup` (Advice row) legs were exercised only incidentally: the run is about ink and S3.
