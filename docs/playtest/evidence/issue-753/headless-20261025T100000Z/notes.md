# Notes — issue #753 acceptance run (headless)

**Build:** `origin/main` @ `4e50418` (PR #798 merge), clean detached worktree, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.1` headless.
**Protocols:** `PTU-exceptions` (`EX.US1`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`). Verdict: **pass**.

## What was judged

The defect's title still carries a withdrawn mechanism ("a pointer press is dropped when a repaint lands before its release"), but the body, both reviews, and the accepted fix agree on the real one: **S3 (`EX.error`) refused every board gesture**, so a person whose advice fetch failed could not move until Dismiss, against `specs/ux/screens/shared-play-states.md` S3 ("Error; board still playable / C1–C5 as S1") and `shared-play-controls.md` C1/C2 ("not S2 or S4").

So acceptance asked: **in a real advice failure, does the board play exactly as S1?**

## How the run was driven

`drive_headless.gd` runs the shipped `res://main.tscn` and touches only public entry points:

- **Gestures** go through `Presentation.handle_gui_input` with the event shapes of the defect's reproduction step 3 — `InputEventScreenTouch{pressed=true}`, `InputEventScreenDrag` past `DRAG_THRESHOLD_PX`, `InputEventScreenTouch{pressed=false}` — and a tap as press+release. The press is dispatched exactly as `_accept_pointer` does for a finger, so `_on_pointer_down`'s gate is the code the run exercises. `handle_input_commit` is never called: the issue correctly notes that path shared the same gate, so it cannot serve as a control.
- **S3 is real, not a fixture.** A genuine advice failure is raised the way the app raises one: the shipped `AdviceClient` is pointed at a real endpoint and key, then the simulated peer (`FakeAdviceTransport`, the ADR-0002 Testability seam) pushes wire reason E2. The production path then sets `advice_error`, parks the client, and reports `advice.cleared` / `advice.error` / `shared.advice.error`. No field is poked to reach S3.
- **The comparison is internal.** The same drive runs three times on one session: at `S1` before the failure (baseline), at `S3` after it, and at `S3` again after Dismiss + a documented `resume()` reconnect + a second failure. Each phase re-loads the same starting position, so the S1 and S3 results are directly comparable rather than asserted from memory.
- **Controls** (`mode-pick` C1, `shared-setup` C5) are clicked as `InputEventMouseButton` at their bound `control_id`, as in the #617 run.

## What the run showed

- **S3 stays in S3.** Both moves and the deselect drives leave `advice_error` true, the service offline (FAIL.T1), and the `EX.error` panel up — the board plays *under* the error, which is what the spec asks.
- **S1 and S3 results are identical:** tap-select + tap-place, drag-to-move, deselect by tap, and a refused illegal drop all behave the same in both.
- **Dismiss still works** as `EX.US1.5` says: it returns `S1`, clears `advice_error`, and a drag move lands afterwards.
- **`IN.US3`**: a pointer over Dismiss fires `IN.point` only; Tab moves focus off it along `AdviceToggle → Resign → OfferDraw → SelectFocus → ClearFocus → PlaceFocus`. The play screen's named controls are reached in a stable order.

## The one thing worth flagging to reviewers (not a defect)

The earlier note in the issue thread — that `advice_ui_test.gd:254` "passes for the wrong reason" — is now moot in the direction that matters: with `UI_S3` removed from the allow-list, `shared_play_s3_test.gd` **fails**, so the regression pin is honest. I confirmed the same discriminating behaviour end-to-end (a real S3 tap selects nothing without `UI_S3`, and selects `e2` with it), which is why this run is evidence rather than a formality.

## Screenshots

This is the headless run, so it records screenshots as **waiting**. The graphical run of the same build (`../graphical-20261025T100000Z/`) captures the `S1` start, the `S3` `EX.error` panel, an `S3` selection, the board after the `S3` tap and drag moves, and the post-Dismiss state from the real framebuffer.

## Non-blocking observations

1. **The title still names the withdrawn mechanism.** Renaming it to the S3 gate was called optional at review; it does not affect acceptance and is left to a planner/hygiene pass.
2. **Drag-off-board (B11) was judged on an own-piece drop** (`g1`→`g2`), which is deterministic on the board; releasing off-board reaches the same `IN.deselect` branch but depends on board geometry at the window edge, so it was not used as the pin.
3. **The second failure needed the documented reconnect** (`AdviceClient.resume()`), because FAIL.T1 parks the client until then. That is expected behaviour, not a gate quirk, and is recorded so a re-run is reproducible.
