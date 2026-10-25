# Notes — issue #753 acceptance run (graphical)

**Build:** `origin/main` @ `4e50418` (PR #798 merge), same build as the headless run, native macOS window 720×1280, Metal.
**Protocols:** `PTU-exceptions` (`EX.US1`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`). Verdict: **pass**.

## What the screenshots prove

The headless run already judged the behaviour; this run answers the one question a headless run cannot — **does the rendered screen show the error and the playable board at the same time, as a person would see it?**

1. **`02-s3-exerror-panel`** — the `EX.error` panel is legible and calm: *"Advice unavailable. Play continues."* with a full-width **Dismiss** target, sitting under the play chrome. The board is drawn underneath at full strength (not dimmed like the S2/S4 unavailable states), and the `e4` pawn placed before the failure is still there. This is `EX.error` per `specs/ux/exceptions.md`, and the "play continues" wording is exactly the promise the defect said the game broke.
2. **`03-s3-selected-e2`** — a real tap on `e2` in that same S3 state selects the pawn: the selection highlight and its legal-target dots render while the panel stays up. Nothing about the error state suppresses the selection affordance.
3. **`04-s3-after-tap-and-drag-moves`** — after a tap-place and a drag, the board shows the moved pieces with `EX.error` and Dismiss still present. Playing does not clear or hide the exception.
4. **`05-s1-after-dismiss`** — Dismiss removes the panel and returns the playable `S1` state, the `EX.US1.5` "Then".

## Method

The drive runs the shipped `main.tscn` and reaches the game the way a player does: mode-pick C1 and shared-setup C5 clicked as `InputEventMouseButton` at their bound control. Board gestures use the production event shapes (`InputEventScreenTouch` press/release, `InputEventScreenDrag` past the threshold) through `Presentation.handle_gui_input`, and the advice failure is a real client failure through the ADR-0002 testable seam, not a hand-set flag. Every check in `logs/drive.log` is `ok:` and `FAILURES []`.

## Screenshot method

The host denies Screen Recording to the automation process, so `/usr/sbin/screencapture` returns an empty frame. The images are the **rendered framebuffer of the running Godot process** (`root.get_texture().get_image()`), saved at 720×1280 from a real Metal-backed window — the same rendered frame the window displayed, as in the #617 run.

The debug overlay is switched off (`PlaytestSeams.set_overlay(false, [])`) so the captures show the shipped screen. The overlay's button stack is still visible at the left edge in `02` and `04` because those panels render on the play screen beneath it; it is the playtest build's own debug UI and not part of the game screen.

## Non-blocking observations

1. **The play screen shows no advice chrome in S3 beyond the panel** — no stale eval or best-move marks survive the failure, which matches `FAIL.T1`.
2. **The title's withdrawn mechanism** ("repaint before release") is unchanged; retitling to the S3 gate remains an optional hygiene item, not an acceptance blocker.
3. **Board bottom margin**: the board sits in the lower body region as designed for this viewport; the margin above it is the R2–R4 chrome band, not clipping.
