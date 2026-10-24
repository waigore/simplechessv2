# Evidence manifest — issue #753, acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #753 — title names a withdrawn mechanism; the accepted defect is the S3 `EX.error` gate refusing all board gestures |
| Environment | `ENV.1`: headless (`DisplayServer = headless`, no display), Godot `4.7.2.stable.official.ed1daf0bf` |
| Build | `origin/main` @ `4e50418` (**PR #798** merge), clean detached worktree; `PlaytestGate.is_playtest() = true` |
| Session id (`TEL.3`) | `sess-1792867042715-55280-playtest-196988` (see `logs/drive.log`) |
| Protocols | `PTU-exceptions` (`EX.US1`, step S1 → `EX.US1.5`) and `PTU-controls` (`IN.US1`, `IN.US2`, `IN.US3`) |
| Coverage mode | `full`, intersected with issue scope |
| Defects | none |

## Results

Both protocols — **pass** on Headless; graphical ran on the same build ([its manifest](../graphical-20261025T100000Z/manifest.md)).

| Story row | Judging protocol | Headless | Graphical |
|-----------|------------------|----------|-----------|
| `EX.US1` (`exceptions.md#US1`), reached `US1.5` — advice failure shows `EX.error`; Dismiss leaves shared-play usable for local moves | `PTU-exceptions` | pass | pass |
| `IN.US1` (`controls.md#US1`) | `PTU-controls` | pass | pass |
| `IN.US2` (`controls-drag.md#US2`) | `PTU-controls` | pass | pass |
| `IN.US3` (`controls-point.md#US3`) | `PTU-controls` | pass | pass |

`US1.5` is the row the defect touches. The run also judges the stronger claim the defect makes: the board is usable **while** the error is up, not only after Dismiss.

## Steps

| Step | Observation | Result |
|------|-------------|--------|
| `PTU-controls` S1/S2/S4/S5, B8/B10/B11 (Shared S1) | baseline: tap move, drag move, deselect by tap, refused own-piece drop | pass |
| `PTU-exceptions` S1 | a real advice failure (peer E2) put play in `S3`, `EX.error` up, service offline (FAIL.T1) | pass |
| `PTU-controls` S1/S2/S4/S5, B8/B10/B11 (S3) | the same four drives, identical to the baseline, with `EX.error` still up | pass |
| `PTU-exceptions` S1 Then | Dismiss → `S1`; `d2`→`d4` drag lands after Dismiss | pass |
| `IN.US3` | pointer over Dismiss fires `IN.point` (`advice_dismiss`) with no other action; Tab moves focus off it along `AdviceToggle → Resign → OfferDraw → …` | pass |

## Discriminating check

A broken gate must fail the run. With `UI_S3` removed from `SharedGameSession.gestures_available()` on this build, a tap on `e2` in `S3` selects nothing and the gate reports `false`; restored, it selects `e2` and reports `true`. The shipped `shared_play_s3_test.gd` is the same pin.

## Paths

- Drive script: [`drive_headless.gd`](drive_headless.gd)
- Session log (excerpt, `TEL.*` included): [`logs/drive.log`](logs/drive.log)
- Notes: [`notes.md`](notes.md)
- Method and findings: [`method.md`](method.md)
- Screenshots: from the same build — [`../graphical-20261025T100000Z/screenshots/`](../graphical-20261025T100000Z/screenshots/)
