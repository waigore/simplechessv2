# Manifest

- **Issue**: 546 — implement `SIT.6` phone-width legibility viewport (seam `S13`, op `O12`)
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, `macOS` Metal
  display (`DisplayServer.get_name()` = `macOS`), shipped playtest scene `game/main.tscn`.
- **Build / session id**: `origin/main` `f1a62f0`, clean detached worktree. The #708 fix
  (`e91d6cf`) and the #708 acceptance evidence (`9707cc3`) are ancestors. `TEL.3` session
  `sess-1792871760302-90228-playtest-434200` (see `logs/graphical-s6.log`). Three runs of the
  same build produced the same readings and the same render.
- **Coverage mode**: partial — `PTU-mode-pick` S6 only. S1–S5 were not driven here and stay with
  the #400 sweep; this run judges the phone-width legibility step.
- **Screenshots**: `screenshots/s6-phone-390x844.png` — mode pick at a genuine 390×844 frame after
  `O12 set_viewport`, captured from this build.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `UI-mode-pick.US1` — S6 at 390×844 (`SIT.6`, `P5`/`F3`) | **fail** | Every string clears `UIS.T2` (≥ 21 px), but the playtest debug panel renders over the mode-pick panel: two strings are fully covered and one is partly covered. Hidden by debug chrome is not legible, so `F3` fires. `logs/graphical-s6.log`, `screenshots/s6-phone-390x844.png` |
| `UI-mode-pick.US1` — S1–S5 | not-judged | Not driven in this run; the #400 sweep judges them |
| `PTU-mode-pick` protocol verdict | **fail** | S6 failed |

## What was measured

| Control | text | font px | own height | resolves frame | ≥ `UIS.T2` (21) | own clipping | visible |
|---|---|---|---|---|---|---|---|
| `Title` | Choose how to play | 37 | 111 | 844 | yes | 2 wrapped lines, both inside the box | yes |
| `SharedGame` | Shared game · Last | 21 | 54 | 844 | yes | none | **fully covered** by the debug panel |
| `PuzzleStream` | Puzzle stream | 21 | 54 | 844 | yes | none | **partly covered** by the debug panel |
| `Quit` | Quit | 21 | 54 | 844 | yes | none | yes |
| `SwitchLocale` | English | 21 | 54 | 844 | yes | none | yes |

## Repeatability

Measured twice on this build, in two separate runs, with the same readings and the same render.
The readings above come from the archived probe in this folder; the second run, which additionally
intersected each control's `get_global_rect()` with the debug panel's, agreed with them and with
the screenshot.

## Paths

- `notes.md`
- `logs/graphical-s6.log`
- `screenshots/s6-phone-390x844.png`
- `probe/zz_accept546_legibility_probe.gd` — the harness that produced the readings

## Defects

- Filed from this run; see `notes.md` and the acceptance comment on #546.
