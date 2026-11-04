# Reproduction — the committed graphical folder, re-run on today's main branch

#742's judgement was that `graphical-20261024T073700Z` is "a headless session labelled graphical".
That is a claim about reproduction, so this run tested it by reproduction rather than by reading the
logs.

## What was run

Clean detached worktree at `origin/main` `4e4b724`, imported once (`--import --quit`), then the
committed drive and wrapper unchanged:

```
bash docs/playtest/evidence/issue-616/graphical-20261024T073700Z/run_graphical.sh <worktree> Godot_v4.7.2-stable_linux.x86_64
```

`DISPLAY` is unset on this host, so the wrapper ran under `xvfb-run -a -s "-screen 0 1920x1080x24"`
with `--rendering-driver opengl3`. Exit 0, `RESULT fails=0`, log in
[`logs/graphical-drive-rerun.log`](logs/graphical-drive-rerun.log).

## Results

1. **The environment line is the engine's.** The drive's first `STEP env` row on this machine reads
   `display=X11 adapter=llvmpipe (LLVM 20.1.2, 256 bits) api=4.5 (Core Profile) Mesa
   25.2.8-0ubuntu0.24.04.2 method=gl_compatibility headless=false` — the same adapter, Mesa build and
   method the committed log claims. `headless=false`, and the drive fails instead of capturing when
   `DisplayServer.get_name() == "headless"`.
2. **All 19 screenshots reproduce byte-for-byte.** `md5sum` of every committed PNG equals the file this
   run wrote, including the pair #742 flagged. A headless or fabricated folder cannot produce identical
   pixels from an independent rendered run; a real framebuffer capture of the same build can.
3. **The pixels place the panels where the geometry rows do.** In this run's `w1280-01-mode-pick.png`
   the card's text content starts at x = 480 in a 1280 frame (`w1600`: x = 640 of 1600;
   `phone-01`: x ≈ 35 of 390), measured from the decoded image, not from the log. A fixed 40 px inset
   would have put that content at x ≈ 40–80.
4. **The duplicate pair is one state captured twice.** `phone-01-mode-pick.png` and
   `caps-frame-3239.png` share an md5 because the caps capture runs immediately after the phone pass,
   whose last visible panel is `ModePick` (the log's `tree panel visible=ModePick` line). The other 17
   files are pairwise distinct.

## Geometry on this build

`get_global_rect()` of each panel against its parent rect (the frame at every size):

| Frame | `ModePick` | `SharedSetup` | `SharedResult` | `ResignConfirm` | `StreamConfirm` | `SaveFailure` |
|---|---|---|---|---|---|---|
| 1280×720 | x 480, top 80 | x 480, 60 | x 480, 120 | x 500, 200 | x 500, 220 | x 500, 220 |
| 1600×900 | x 640, 80 | x 640, 60 | x 640, 120 | x 650, 200 | x 650, 220 | x 660, 220 |
| 390×844 | x 35, 80 | x 35, 60 | x 35, 120 | x 52.5, 200 | x 52.5, 220 | x 55, 220 |

`centre_dx = 0.0` and `top_dy = 0.0` on all 18 rows.
