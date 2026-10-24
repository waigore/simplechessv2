# Method — issue #753 acceptance run (headless)

`drive_headless.gd` runs the shipped `res://main.tscn` and touches only public entry points:

- **Gestures** go through `Presentation.handle_gui_input` with the event shapes of the defect's reproduction step 3 — `InputEventScreenTouch{pressed=true}`, `InputEventScreenDrag` past `DRAG_THRESHOLD_PX`, `InputEventScreenTouch{pressed=false}` — and a tap as press+release. The press is dispatched exactly as `_accept_pointer` does for a finger, so `_on_pointer_down`'s gate is the code the run exercises. `handle_input_commit` is never called: the issue notes that path shared the same gate, so it cannot serve as a control.
- **S3 is real, not a fixture.** An advice failure is raised the way the app raises one: the shipped `AdviceClient` is pointed at a real endpoint and key, then the simulated peer (`FakeAdviceTransport`, the ADR-0002 Testability seam) pushes wire reason E2. The production path then sets `advice_error`, parks the client, and reports `advice.cleared` / `advice.error` / `shared.advice.error`. No field is poked to reach S3.
- **The comparison is internal.** The same drive runs three times on one session: at `S1` before the failure (baseline), at `S3` after it, and at `S3` again after Dismiss + a documented `resume()` reconnect + a second failure. Each phase re-loads the same starting position, so S1 and S3 results are directly comparable rather than asserted from memory.
- **Controls** (`mode-pick` C1, `shared-setup` C5) are clicked as `InputEventMouseButton` at their bound `control_id`, as in the #617 run.
- **Repeatability.** The second `S3` phase also answers whether a re-run reproduces: the same drives pass again after the second failure.

## What the run showed

- **S3 stays in S3.** Both moves and the deselect drives leave `advice_error` true, the service offline (FAIL.T1), and the `EX.error` panel up — the board plays *under* the error, which is what the spec asks.
- **S1 and S3 results are identical:** tap-select + tap-place, drag-to-move, deselect by tap, and a refused illegal drop all behave the same in both.
- **Dismiss still works** as `EX.US1.5` says: it returns `S1`, clears `advice_error`, and a drag move lands afterwards.
- **`IN.US3`**: a pointer over Dismiss fires `IN.point` only; Tab moves focus off it along `AdviceToggle → Resign → OfferDraw → SelectFocus → ClearFocus → PlaceFocus`. The play screen's named controls are reached in a stable order.
