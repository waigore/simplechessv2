# Notes — #795 acceptance, headless PTU-puzzle-play S4/S6 (C6)

## Scope

The defect asked for one thing: each S4 promotion option carries its visible C6 name
(`specs/ux/screens/puzzle-play.md` copy table), legible and not clipped, beside the sprite
(`UI-puzzle-play` S4/S6; `US3.1`, `US3.4`, `US3.8`, `US3.9`). This run judges exactly that
step on `origin/main` after PR #810 merged, in all three shipped locales, and re-checks that
each option still commits the piece it names.

Not judged here: the rest of `PTU-puzzle-play` (S1–S3, S5, S7, S8), which the #333 run and the
screen's own tests cover; `PTU-puzzle-play` P3 frame time (`SIT.4`) — no sample taken.

## What was driven

`probe/zz_accept795_headless.gd` boots the shipped `res://main.tscn`, enters the stream through
the real `mode-pick` C2 control, and deals the last-rank promotion fixture (`DBG.3`, the same
record `game/puzzle_play_test.gd` uses), then places `g7`→`g8` to enter S4.

- **Locales.** The player's own path — `mode-pick` C4 cycles `en` → `zh-Hant` → `ja` →
  `en` (`session_router.gd:627`) — re-entering C2 between each. The run asserts the router *and*
  the panel report the expected locale, so a stale locale cannot pass silently.
- **Names.** For each locale and each of `PuzzleSession.PROMOTE_ORDER`, it asserts: the label
  exists, is visible in the tree, carries `StringTable.puzzle_play(kind, locale)`, is
  `AUTOWRAP_OFF`, is at least `UiChrome.BODY_PX` (UIS.T2), its box is not smaller than its
  combined minimum size (not clipped), it sits inside the `PuzzleChrome` (R2) rect, and it
  intersects no board square (`PRJ.A1`).
- **Commits.** It taps each of the four chooser sprites by hit-testing
  `BoardPresentation.promotion_kind_at` at the sprite's own world position and committing
  through `SessionRouter.handle_promotion_commit` — the same two calls `Presentation`'s
  pointer-up makes for a C6 tap (`presentation.gd:751-756`).

The harness child that quits a headless boot (`PlaytestHarness`) is removed first, as the #753
acceptance drive does; otherwise the process exits before the drive runs.

## Result

`FAILURES=[]` — 105 checks pass, 0 fail (`logs/headless-run.log`).

- Names read `Queen`, `Rook`, `Bishop`, `Knight` in `en`, `zh-Hant`, and `ja`. Identical text is
  correct, not a locale bug: the copy table marks piece names as the one key that does not vary
  by locale (`specs/ux/screens/puzzle-play.md` "All keys vary by locale except piece names").
- Every name measures exactly its minimum size — 57/43/58/56 × 27 px at the headless text
  scale — so nothing is clipped at the current frame.
- Each sprite hit-tests to the kind it draws, and each tap commits and leaves S4 (S4 → S1).

## Notes on the probe's first attempts (recorded, not defects)

- Driving `handle_control("puzzle-play", "C6:<kind>")` does **not** commit: `PuzzlePlayFlow.control`
  handles only `C3`–`C5`/`confirm`/`cancel`/`dismiss`, and `PuzzlePlayPanel._on_activate`
  deliberately declines `C1`/`C2`/`C6:*` because those are board surfaces whose gestures the
  router owns. That is the documented design (`puzzle_play_panel.gd:489-492`), not a routing
  bug; the run uses the sprite-tap path above instead.
- Forcing `state["locale"]` onto an emitted state does not change the panel, because
  `Presentation._show_puzzle_play` re-emits with the router's own locale. The run therefore
  cycles locale through C4, which is what a player does.
- `docs/playtest/evidence/issue-795/graphical-20261024T164559Z/` (the implementer's run) supplies
  the required graphical screenshots for this same defect. This folder adds the independent
  headless judgement, which that folder did not include.
