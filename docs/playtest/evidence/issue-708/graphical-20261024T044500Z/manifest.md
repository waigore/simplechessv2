# Manifest

- **Issue**: 708 — `O12`/`S13` phone-width reflow does not size the rendered text to `UIS.T2`
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, X11 display
  under `Xvfb` (Mesa llvmpipe OpenGL 4.5), shipped playtest scene `game/main.tscn`. A headless
  (`ENV.1`) pass is not owed: `PTU-mode-pick` S6 is Graphical-only and every story this defect
  touches is the phone-width legibility leg.
- **Build / session id**: `origin/main` `ffc5094` ("Record the #703 acceptance run (spec-only)"),
  run in a clean detached worktree. `TEL.3` session
  `sess-1792817196901-2166027-playtest-2113854` (see `logs/graphical-s6.log`).
- **Timing (`SIT.4` runs)**: **not judged** — this defect is typography/frame resolution, not load
  or frame timing; `SIT.4` is out of scope for #708. The run read no device/browser/repeat count
  because no `SIT.4` sample was taken (`PTU-mode-pick` S1 is #400's sweep).
- **Coverage mode**: partial — `PTU-mode-pick` S6 only (the step this defect repairs). S1–S5 are
  `not-judged` here and stay with the #400 quality sweep.
- **Screenshots**: `screenshots/s6-phone-390x844.png` — mode pick rendered at a genuine 390×844
  frame after `O12 set_viewport`, from this build.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `UI-mode-pick.US1` — S6 at 390×844 (`SIT.6`, `P5`/`F3`) | **pass** | Every visible label and body string ≥ `UIS.T2` (21 px for an 844 px frame); none clipped; `logs/graphical-s6.log` |
| `UI-mode-pick.US1` — S1–S5 | not-judged | Not driven in this run; the #400 sweep judges them |
| `PTU-mode-pick` protocol verdict | **not-judged** | S6 passes; S1–S5 were not judged here, so this folder cannot carry the whole protocol |

The S6 leg is what #708 owns. This folder supplies the repaired-legibility evidence acceptance
needs; it does not claim the full protocol, which stays with #400.

## Paths

- `notes.md`
- `logs/graphical-s6.log`
- `screenshots/s6-phone-390x844.png`
- `probe/zz_accept708_probe.gd` — the harness that produced the readings (derived from #546's probe)

## Defects

- None. This run closes #708's defect: both causes it filed are repaired on `main` (`e91d6cf`) and
  re-measured here.
