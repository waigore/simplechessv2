# Evidence manifest — issue #753, acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #753 — A pointer press is dropped when a play-screen repaint lands before its release (body re-derived as: the S3 `EX.error` gate refused all board gestures) |
| Environment | `ENV.1`: headless (`DisplayServer = headless`, no display), Godot `4.7.2.stable.official.ed1daf0bf` |
| Build | `origin/main` @ `4e50418` (**PR #798** merge, "Keep the Shared board playable in S3 (EX.error)"), clean detached worktree; `PlaytestGate.is_playtest() = true` (playtest build from source) |
| Session id (`TEL.3`) | `sess-1792867042715-55280-playtest-196988` (see `logs/drive.log`) |
| Protocols | `PTU-exceptions` (`EX.US1`, step S1 → `EX.US1.5`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`) |
| Coverage mode | `full` (intersected with issue scope: S3 board playability + the exception it sits in) |
| Defects | none |

## Results

Both protocols — **pass** on Headless. Graphical screenshots are waiting (see [the graphical run](../graphical-20261025T100000Z/manifest.md)).

| Story row | Judging protocol | Headless | Graphical |
|-----------|------------------|----------|-----------|
| `EX.US1` (`exceptions.md#US1`), reached `US1.5` — advice failure shows `EX.error`; Dismiss leaves shared-play usable for local moves | `PTU-exceptions` | pass | pass |
| `IN.US1` (`controls.md#US1`) — select, tap move, deselect by tap | `PTU-controls` | pass | pass |
| `IN.US2` (`controls-drag.md#US2`) — drag move and deselect on a bad drop | `PTU-controls` | pass | pass |
| `IN.US3` (`controls-point.md#US3`) — Web point fires `IN.point`, no other action, focus follows `F1` | `PTU-controls` | pass | pass |

`US1.5` is the row the defect touches: the gherkin is *"Given EX.error after Advice fetch failed on shared-play / When the actor dismisses / Then shared-play remains usable for local moves"*. The run therefore judges the stronger claim the defect makes — the board is usable **while** the error is up, not only after Dismiss.

## Steps

| Step | Observation | Result |
|------|-------------|--------|
| `PTU-controls` S1 (Shared S1) | `e2`→`e4` by tap-select + tap-place; side flipped to Black | pass |
| `PTU-controls` S4 / B10 (Shared S1) | `b8`→`c6` by pick-and-drag from an unselected piece | pass |
| `PTU-controls` S2 / B8 (Shared S1) | tapping the selected `a2` cleared the selection, no move | pass |
| `PTU-controls` S5 / B11 (Shared S1) | drag `g1`→`g2` (own pawn) refused; nothing placed, selection cleared | pass |
| `PTU-exceptions` S1 | a real advice failure (peer E2) put play in `S3`, `EX.error` up, service offline (FAIL.T1) | pass |
| `PTU-controls` S1 (S3) | `e2`→`e4` by tap-select + tap-place landed; `EX.error` stayed up; side flipped | pass |
| `PTU-controls` S4 / B10 (S3) | `b8`→`c6` by drag landed | pass |
| `PTU-controls` S2 / B8 (S3) | tap-select `e2` then tap it again cleared the selection | pass |
| `PTU-controls` S5 / B11 (S3) | drag `g1`→`g2` refused, selection cleared | pass |
| `PTU-exceptions` S1 Then | Dismiss → `S1`; `d2`→`d4` drag lands after Dismiss | pass |
| repeatability | second real advice failure (after the documented `resume` reconnect) → `S3`; the same C1/C2/B10/B11 drives pass again | pass |
| `IN.US3` | pointer over Dismiss fires `IN.point` (`advice_dismiss`) with no other action; Tab moves focus off it along `AdviceToggle → Resign → OfferDraw → …` | pass |

## Discriminating check (not a separate run)

The run only counts if a broken gate would fail it. With `UI_S3` removed from `SharedGameSession.gestures_available()` on this same build, an `InputEventScreenTouch` tap on `e2` in `S3` selects nothing and the gate reports `false`; with the fix restored the tap selects `e2` and the gate reports `true`. The shipped unit suite is the same pin: `shared_play_s3_test.gd` fails without `UI_S3` in the allow-list.

## Paths

- Drive script: [`drive_headless.gd`](drive_headless.gd)
- Session log (excerpt, `TEL.*` included): [`logs/drive.log`](logs/drive.log)
- Notes: [`notes.md`](notes.md)
- Screenshots: **waiting** on the graphical re-run of the same build — [`../graphical-20261025T100000Z/screenshots/`](../graphical-20261025T100000Z/screenshots/)
