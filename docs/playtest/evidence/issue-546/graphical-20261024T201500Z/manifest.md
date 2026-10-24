# Manifest

- **Issue**: 546 — implement `SIT.6` phone-width legibility viewport (seam `S13`, op `O12`)
- **Environment**: graphical (`ENV.2`) — Godot `4.7.2.stable.official.ed1daf0bf`, `macOS` Metal
  display, shipped playtest scene `game/main.tscn`. A headless (`ENV.1`) pass of the same build
  judged S1–S5 as not judged (see Results).
- **Build / session id**: `origin/main` `d707b7e`; session `sess-1792803255974-15909-playtest`
  (`TEL.3`, see `logs/graphical-s6.log`).
- **Coverage mode**: partial — `PTU-mode-pick` only. The seam's own `S13` cases are judged in the
  headless sibling folder `../headless-20261024T190000Z/`; this run judges the protocol step S6
  those cases cannot reach.
- **Screenshots**: `screenshots/s6-phone-390x844.png` — mode pick rendered at a genuine 390×844
  frame after `O12 set_viewport`. `SIT.4` carries no timing report: this run does not judge the S1
  load-time step.

## Results

| Story / step | Outcome | Notes |
|--------------|---------|-------|
| `UI-mode-pick.US1` — S6 at 390×844 (`SIT.6`, `P5`/`F3`) | **fail** | Every mode-pick label and button renders below `UIS.T2` for an 844 px frame; `logs/graphical-s6.log` |
| `UI-mode-pick.US1` — S1–S5 | not-judged | Not driven in this run; #400 sweep judges them |
| `PTU-mode-pick` protocol verdict | **fail** | S6 failed; a protocol is never `pass` beside a failed story |

## Paths

- `notes.md`
- `findings.md`
- `logs/graphical-s6.log`
- `screenshots/s6-phone-390x844.png`
- `probe/zz_accept546_probe.gd` — the throwaway harness that produced the readings

## Defects

- #708 — `O12`/`S13` phone-width reflow does not size the rendered text to `UIS.T2`.
