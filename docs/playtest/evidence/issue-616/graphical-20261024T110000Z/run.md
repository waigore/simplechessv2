# Run — issue #616, acceptance run (graphical)

Index: [`manifest.md`](manifest.md) · Notes: [`notes.md`](notes.md)

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

## Live loop

`render fps=118.0 process_ms=91.46 draw_calls=28` at 390×844 with `caps-frame-3239.png` captured on that
same frame. This is a liveness reading — the per-state captures came from a running loop, not a frozen
first frame — and not an `O10`/`SIT.4` timing claim.

## Checks

| Check | Result |
|---|---|
| `gdscript_tests.py test` | 26 headless unit test(s) passed, exit 0 |
| `gdscript_tests.py coverage` | 86.4% (4500/5211), threshold 80, exit 0 |
| `gdlint game` | Success: no problems found |
| `gdformat --check game` | 59 files would be left unchanged |
| `spec_lint.py` | 0 errors, 1 pre-existing glossary warning |

The coverage run needs `gdtoolkit`, which on this machine lives in `/Library/Frameworks/Python.framework/Versions/3.11`;
the script's default `python3` is the repo's `agent-orc/.venv`, which does not carry it.

## First attempt, and why it is in the folder

`logs/graphical-drive-first-attempt.log` is the run before the drive was corrected. It read
`RESULT fails=0` and wrote 12 screenshots that were **not evidence**: the shared result's `confirm`
ends the session, and from then on `handle_control` ignores every control (`session_ended`), so the
puzzle legs measured hidden dialogs (which the visibility requirement caught) and the 390×844 frame
never applied (`set_viewport` needs a live tree). Captures were all identical because the capture
buffer lagged the state by one frame.

What the correction changed, in the drive only — no `game/` file was touched:

- a fresh instance per sitting for the legs the ended session could not reach, fitted to the running
  viewport so no resize is re-applied (that would emit `resized` and bypass the `#708` reflow path);
- 20 frames of settle before each capture, plus `tree panel visible=` logged beside each shot;
- every new sitting sets `force_write_failure` deliberately, and the store clears
  it on the attempt. The drive does not reset it afterwards: doing so once left
  the flag latched on a later sitting and failed a commit that was meant to
  succeed, which changed that frame's state mid-pass.

The corrected run is `logs/graphical-drive.log` and the 19 screenshots the manifest lists.
