# Headless notes — #545

Build: `origin/main` `16e197b` (deliverable `5a7541b` / PR #595), Godot 4.7.2 headless (`ENV.1`).

## Drive

`probe/accept545_probe.gd` loads `main.tscn`, frees the smoke harness so only this run's events land in the buffer, then drives: mode pick `C1` → shared set-up `C5` → play `C3` (Advice) → `C4`/`confirm` (resign) → `C5`/`confirm` (offer draw) → `C8` (decline). All controls are player-facing (`DBG.3` was not needed).

## What the run emitted

```
{"TEL.1":"shared.start","TEL.3":"sess-…-playtest","TEL.4":"UI-shared-play.US1","TEL.5":"ok"}
{"TEL.1":"shared.advice","TEL.3":"sess-…-playtest","TEL.4":"UI-shared-play.US1.4","TEL.5":"toggled"}
{"TEL.1":"shared.resign","TEL.3":"sess-…-playtest","TEL.4":"UI-shared-play.US1.1","TEL.5":"confirm"}
{"TEL.1":"shared.resign","TEL.3":"sess-…-playtest","TEL.4":"UI-shared-play.US1.1","TEL.5":"end"}
{"TEL.1":"shared.end","TEL.3":"sess-…-playtest","TEL.4":"NAV.T6","TEL.5":"END.L2"}
```

`TEL.2` is present on every line; elided here only for width.

## Judgement

`S6`/`P4` — pass. The scenarios this drive reached are `US1` (enter shared play), `US1.4` (Advice toggled), `US1.1` (resign confirm → end). `assert_telemetry` over exactly those three returned `verdict=pass` with `matched=3`, and each matched payload carries `TEL.1`/`TEL.2`/`TEL.3`/`TEL.5` — `TEL.4` present exactly when a story id was passed, which keeps field shape with `_tel_complete`.

`F3` — pass. Adding an expectation for `UI-shared-play.US9-never-judged` (never emitted) turns the verdict to `fail` and names that story alone in `missing`; the matched expectation still reports its event. The fail is a verdict, not a warning.

`SIT.5` log window — pass. `session_id` equals `TEL.3` and `event_count` equals the buffer length, so the protocol can cite the window it read (D3).

D1 no-`story_id` — pass. An empty `story_id` does not match the `US1` event (which carries `TEL.4`), and does match a story-less `anon_marker` event emitted for the check.

`AC3` release absence — pass, in `probe/accept545_release_probe.gd`: with `playtest_override = 0`, `playtest_build` is false and `assert_telemetry` returns `verdict=fail`, empty `matched`, empty `missing`, `event_count=0` without touching the buffer.

## Scope note

`S1`/`S2` (seat operation) and `S5`/`P3` (timed move) are marked not-judged here: the deliverable adds a read over emitted events and a debug button, and touches no start position, seat rule, gesture, or clock. The protocol verdict is pass because every row this change can move is pass; the untouched rows carry no new risk.

A first pass of this probe reported a false fail of its own making: it expected `UI-shared-play.US2` (`outcome=shown`), which this drive never reaches because no check is shown. The seam correctly reported it in `missing`; the probe was corrected to judge only the scenarios the drive actually entered.
