# Notes — issue #528 graphical run

Same drive as the headless twin, run with a window and `SHOT_DIR` set, so every judged
state below comes from the same build and the same scripted steps.

## What was judged

- `PTU-puzzle-session` S1–S3 on the rendered screen: entry to `puzzle-play` with the dealt
  record's opening move applied, the leave confirm, and cancel returning to the board.
- `PTU-puzzle-play` S1–S4: required moves on the rendered board, the reveal-confirm failure
  followed by the next deal, the leave confirm / cancel, and the timed-move frame samples
  (`SIT.4`): 3 repeats of 60 frames, the solver's own move inside each.

## Frame samples (`SIT.4`)

Device: Apple M5, macOS arm64, Godot `4.7.2.stable.official.ed1daf0bf`, window 1280×720,
build `614746c`. Repeat count: 3 samples of 60 frames each, one judged move per sample.

| Sample | Worst frame | Move handler |
|--------|-------------|--------------|
| 1 | 1.77 ms | 3.18 ms |
| 2 | 1.15 ms | 3.19 ms |
| 3 | 1.14 ms | 3.24 ms |
| **Worst** | **1.90 ms** | **3.67 ms** |

Budget: 16.67 ms (one frame at 60 fps). No sample approaches it, and no catalog read is in
flight while a puzzle is open (`ACCEPT no catalog read is in flight while a puzzle is open`).

## Observations

- The debug layer in the captures is `PlaytestSeams`' own (a seam build mounts it; G2 keeps
  it out of the release scene). The empty row skeletons at the top of
  `01-puzzle-play-dealt.png` are that chamber, not a shipped strip.
- The `4 ObjectDB instances leaked at exit` warning also prints for a baseline that never
  reads a catalog (`../headless-20261023T212229Z/logs/baseline-30-frames-graphical.log`).