# Run — issue #616, acceptance run (graphical)

Index: [`manifest.md`](manifest.md) · Notes: [`notes.md`](notes.md) · Rendering reading and checks:
[`readings-and-checks.md`](readings-and-checks.md) · Artifact paths: [`paths.md`](paths.md).

## Build under test

`origin/main` `4aa6aba` — the branch tip when this run started — read in a detached worktree. Source: the
shipped playtest tree `game/main.tscn` run in a rendered session. The published URL (ADR-0009) does not
serve this commit (it is not yet on `main`-published Pages), so this is the local-playtest-build reading,
and no release-export fallback was used. No `TEL.3` id: it is not a web build.

## What was run

`drive_graphical.gd` boots the shipped `game/main.tscn` in a rendered Godot session
(`root.get_texture().get_image()` capture, the same in-process grab `#617`'s graphical run used, because
this host denies Screen Recording to the automation process). It drops the debug overlay and drives
every judged panel open **through `SessionRouter` controls** — `C1`, `C5`, `C4` + `cancel`, `C4` +
`confirm`, `C2` + `C5` + `cancel`, and one failed puzzle commit (`force_write_failure` + a committing
move) — never by forcing visibility. Each state is captured only after the tree reports that panel
visible (`tree panel visible=<Panel>` in the log), so a screenshot cannot name a state the build is not in.

Frames: 1280×720 and 1600×900 via `set_viewport` on the running window, then the `SIT.6` phone frame
390×844 through `O12` — the same seam `PTU-mode-pick` S6 uses on the Web build.

## Geometry

`get_global_rect()` of each panel against its parent rect, which is the frame at every size
(`ScreenHost` for the three screens, full-rect `SharedPlayPanel` / `PuzzlePlayPanel` for the dialogs).

| Frame | `ModePick` | `SharedSetup` | `SharedResult` | `ResignConfirm` | `StreamConfirm` | `SaveFailure` |
|---|---|---|---|---|---|---|
| 1280×720 | x 480 top 80 | x 480 top 60 | x 480 top 120 | x 500 top 200 | x 500 top 220 | x 500 top 220 |
| 1600×900 | x 640 top 80 | x 640 top 60 | x 640 top 120 | x 650 top 200 | x 650 top 220 | x 660 top 220 |
| 390×844 | x 35 top 80 | x 35 top 60 | x 35 top 120 | x 52.5 top 200 | x 52.5 top 220 | x 55 top 220 |

`centre_dx` = 0.0 and top delta = 0.0 on all 18 rows; `RESULT fails=0`. The dialogs are wider at
1600×900 (300 px) and narrower at 390×844 (285 px), which is the frame-driven reflow, not a reposition.

## Overflow and text

- `controls … outside_frame=0` on all 18 rows: no control of any judged panel draws outside the frame.
- Smallest rendered label per panel: 18 px at 1280×720, 23 px at 1600×900, 21 px at 390×844. The
  phone frame needs 21 px for `UIS.T2` (`16 × 844 / 640`) and `O12` reports
  `{"applied":true,"frame_height_px":844,"rendered_text_scale":1.31875,"body_text_px":21}`.

The first drive attempt these numbers supersede is [`first-attempt.md`](first-attempt.md).
