# Notes — issue #753 acceptance run (headless)

**Build:** `origin/main` @ `4e50418` (PR #798 merge), clean detached worktree, Godot `4.7.2.stable.official.ed1daf0bf`, `ENV.1` headless.
**Protocols:** `PTU-exceptions` (`EX.US1`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`). Verdict: **pass**.

## What was judged

The defect's title still carries a withdrawn mechanism ("a pointer press is dropped when a repaint lands before its release"), but the body, both reviews, and the accepted fix agree on the real one: **S3 (`EX.error`) refused every board gesture**, so a person whose advice fetch failed could not move until Dismiss, against `specs/ux/screens/shared-play-states.md` S3 ("Error; board still playable / C1–C5 as S1") and `shared-play-controls.md` C1/C2 ("not S2 or S4").

So acceptance asked: **in a real advice failure, does the board play exactly as S1?** How the run was driven and what each phase showed: [`method.md`](method.md).

## The one thing worth flagging to reviewers (not a defect)

The earlier note in the issue thread — that `advice_ui_test.gd:254` "passes for the wrong reason" — is now moot where it matters: with `UI_S3` removed from the allow-list, `shared_play_s3_test.gd` **fails**, so the regression pin is honest. The same discriminating behaviour was confirmed end-to-end (see the manifest), which is why this run is evidence rather than a formality.

## Screenshots

This is the headless run, so it records screenshots as **waiting**. The graphical run of the same build (`../graphical-20261025T100000Z/`) captures the `S1` start, the `S3` `EX.error` panel, an `S3` selection, the board after the `S3` tap and drag moves, and the post-Dismiss state from the real framebuffer.

## Non-blocking observations

1. **The title still names the withdrawn mechanism.** Renaming it to the S3 gate was called optional at review; it does not affect acceptance and is left to a planner/hygiene pass.
2. **Drag-off-board (B11) was judged on an own-piece drop** (`g1`→`g2`), which is deterministic on the board; releasing off-board reaches the same `IN.deselect` branch but depends on board geometry at the window edge, so it was not used as the pin.
3. **The second failure needed the documented reconnect** (`AdviceClient.resume()`), because FAIL.T1 parks the client until then. That is expected behaviour, not a gate quirk, and is recorded so a re-run is reproducible.
