# Notes — headless (`ENV.1`)

## What was judged

- The `S11` unit cases (`game/playtest_seams_measure_test.gd`) exist and pass inside the 32-suite run, including both `frame_times` close predicates and their negatives (the even-length puzzle advance, the refused `S5` → `S1` move), the missing-key refused arm, cold and warm `loading_ready`, and the report shape.
- The release answer (`D3`) is exercised by the shared `_check_release()` leg in `game/playtest_seams_test.gd`, which builds its own `playtest_override = 0` instance.
- `spec_lint.py`, `gdformat`, `gdlint`, and the headless smoke are green on `1894f31`.

## What this run cannot judge

`S11`'s actual product — a frame-time reading over a move and an `EX.loading` span — is `ENV.2` work by `tools-situational.md` ("Timing is sampled on Graphical, where a browser renders"). The headless smoke exits on its first frame by design (`PlaytestHarness`), so it proves the seam loads, not that a window closes. That judgement is in `../graphical-20261024T203114Z/notes.md`.

## Non-blocking marks

- The two ACs that are unit-test-shaped (AC 9, AC 10) are met as written. Meeting them is not the same as `S11` producing a reading: the live run in the graphical folder is the evidence for that, and it fails.
