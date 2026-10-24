# Setup and drives

Run on `main` `ea37581` (after PR #752). Graphical `ENV.2`, shipped release graph. Back to [`manifest.md`](manifest.md).

## Prep

- `godot --headless --path game --import --quit` — the probes are `SceneTree` scripts; no import change was needed.
- `python3 .github/scripts/gdscript_tests.py test` → 28 headless suites pass, including `advice_ui_test.gd` (verifier-run, on this branch, not read from the implementor's comment).

## Running

From the repo root, with `xvfb-run -a` when there is no display. The `.gd` sits in `logs/` so it can live in the repo; copy it into `game/` to run it, then delete the copy:

```
cp docs/playtest/evidence/issue-375/verify-20261024T045500Z/logs/verify_probe_s3_move.gd game/tmp_probe_run.gd
xvfb-run -a godot --path game -s tmp_probe_run.gd          # S3 move legs
cp docs/playtest/evidence/issue-375/verify-20261024T045500Z/logs/verify_probe_gesture.gd game/tmp_probe_run.gd
xvfb-run -a godot --path game -s tmp_probe_run.gd          # S3 pointer gesture
rm game/tmp_probe_run.gd
```

Each drive prints one `V375 {json}` line per check and leaves no game state behind.

## What the drives do

- `verify_probe_s3_move.gd` — enters Shared play with Advice On against the closed port, waits for the parked failure, then reads the S3 state and the player-facing move path (`play_gestures_available`, `can_place`, `handle_input_commit`) and the `EX.error` panel.
- `verify_probe_gesture.gd` — the same entry, then a real pointer tap pair (`_accept_pointer` press + release on g1, then on f3, one frame apart) through `Presentation`, the path a finger takes.

## Limits

- Desktop window, not the exported Web build (ADR-0004). The release scene graph is the one the Web Release export instantiates.
- A tap pair is driven with a frame between events; a same-frame press+release (the internal rule in #753's body) is not exercised here, and does not decide AC6, which is about playability, not a sub-frame race.
- `PER.R5` ink is not re-measured here: it was measured by the implementor's `ink_probe.gd` and by the 2026-10-24 verify before the fix, and its unit form (`_marks_fit_the_body_bound`) runs in the verifier's test run.
