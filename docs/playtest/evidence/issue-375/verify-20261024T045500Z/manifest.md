# Manifest — verifier re-run of the 2026-10-24 fail findings

- **Issue**: 375 — advice UI: shared-play marks and toggle, setup row, S3 error state (epic #36)
- **Run**: `verify-project-issue`, unattended verify agent, 2026-10-24. Branch `main` `ea37581`.
- **Environment**: graphical (`ENV.2`), Godot 4.7.2.stable (`/home/waigore/godot-cache/Godot_v4.7.2-stable_linux.x86_64`), Linux x86_64, `xvfb-run -a` 1280×720.
- **Graph**: `main_release.tscn` (no `PlaytestSeams`), the shipped release scene graph. Advice endpoint `http://127.0.0.1:1/advice`, a closed port, so `AdviceStreamTransport` fails on its own — no simulated peer, no Stockfish.
- **Why this run exists**: the implementor's pass (PR #752) closed two must-fixes from the 2026-10-24 fail. This run re-measures the two findings and checks the claims that failed verification cannot be taken on the implementor's word.
- **Method**: the two probes in `logs/` are the verifier's own, written from the implementor's probe shape (`graphical-20261024T033000Z/logs/gesture_probe.gd`), not copies. Each prints one JSON line per check.

## Results

| Check | Result | Evidence |
|-------|--------|----------|
| Release graph has no seams; play reached; assets bound | pass | `logs/gesture-run.log`, `logs/s3-move-run.log` |
| A failed advice fetch raises S3 with the `EX.error` panel up | pass | both logs (`advice_error_raised`, `router_ui_state`, `ex_error_panel_up`) |
| S3 keeps a local move available (`gestures_available`, `can_place`, `handle_input_commit`) | pass | `logs/s3-move-run.log`: `g1f3` lands, side → black, panel still up, session offline |
| A real pointer tap-move in S3 lands the move | **pass** (contradicts the implementor's `fail`) | `logs/gesture-run.log`: `pointer_gesture_g1f3_in_s3` `true`, `selected_after_tap=g1`, side → black, still S3 |

## Relative paths

- [`notes.md`](notes.md), [`verdicts.md`](verdicts.md), [`setup.md`](setup.md)
- `logs/s3-move-run.log` + `logs/verify_probe_s3_move.gd`
- `logs/gesture-run.log` + `logs/verify_probe_gesture.gd`
