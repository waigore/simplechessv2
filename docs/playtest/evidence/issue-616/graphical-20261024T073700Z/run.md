# Run — issue #616, graphical acceptance run (re-recorded for #742)

Index: [`manifest.md`](manifest.md) · Checkable claims: [`checks.md`](checks.md) · Notes:
[`notes.md`](notes.md) · Paths: [`paths.md`](paths.md).

## Build under test

`origin/main` `cbce7cd`, read in a clean worktree. Source: the shipped playtest tree `game/main.tscn`
run in a rendered session. No published build serves this commit, so this is the local-playtest-build
reading and no release-export fallback was used. No `TEL.3` id: it is not a web build.

## What was run

`run_graphical.sh` runs `drive_graphical.gd` — the drive from the superseded run, with the two changes
[`checks.md`](checks.md) *Drive* records — in a rendered Godot session under `xvfb-run`
(`--rendering-driver opengl3`). It boots the shipped `game/main.tscn`, drops the debug overlay, and
drives every judged panel open **through `SessionRouter` controls** — `C1`, `C5`, `C4` + `cancel`,
`C4` + `confirm`, `C2` + `C5` + `cancel`, and one failed puzzle commit (`force_write_failure` + a
committing move) — never by forcing visibility. Each state is captured only after the tree reports
that panel visible (`tree panel visible=…` in the log), so a screenshot cannot name a state the build
is not in.

Frames: 1280×720 and 1600×900 via `set_viewport` on the running window, then the `SIT.6` phone frame
390×844 through `O12` — the same seam `PTU-mode-pick` S6 uses on the Web build. `O12` reports
`frame_height_px=844`, `rendered_text_scale=1.31875`, so the smallest shipped label draws at 21 px.

## Geometry

`get_global_rect()` of each panel against its parent rect, which is the frame at every size
(`ScreenHost` for the three screens, full-rect `SharedPlayPanel` / `PuzzlePlayPanel` for the dialogs).

| Frame | `ModePick` | `SharedSetup` | `SharedResult` | `ResignConfirm` | `StreamConfirm` | `SaveFailure` |
|---|---|---|---|---|---|---|
| 1280×720 | x 480, top 80 | x 480, top 60 | x 480, top 120 | x 500, top 200 | x 500, top 220 | x 500, top 220 |
| 1600×900 | x 640, top 80 | x 640, top 60 | x 640, top 120 | x 650, top 200 | x 650, top 220 | x 660, top 220 |
| 390×844 | x 35, top 80 | x 35, top 60 | x 35, top 120 | x 52.5, top 200 | x 52.5, top 220 | x 55, top 220 |

`centre_dx` = 0.0 and top delta = 0.0 on all 18 rows; `RESULT fails=0`. The dialogs are wider at
1600×900 (300 px) and narrower at 390×844 (285 px): frame-driven reflow, not a reposition. These are
the same 18 rows the superseded run recorded, from a clean tree.

## Overflow and text

`outside_frame=0` on all 18 rows: no visible descendant control of any judged panel draws outside the
frame at any size. The smallest shipped string on each panel draws at 18 px at 1280×720, 23 px at
1600×900 and 21 px at 390×844.
