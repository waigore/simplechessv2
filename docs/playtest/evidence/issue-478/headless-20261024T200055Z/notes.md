# Notes — #478 headless run `20261024T200055Z`

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 478`).

One `Web Playtest` build, one `TEL.3` session id, one row set. This run judges the
eight design protocols and the nine UX protocols; the
[graphical run](../graphical-20261024T200132Z/manifest.md) re-runs the nine UX
protocols on the same build and writes the screenshots. Rows:
[manifest.md](manifest.md).

## Result

**45 pass, 0 fail, 5 not-judged** over 50 story rows; 14 of 17 protocols `pass`,
3 `not-judged` (`PTD-mode-and-config`, `PTU-controls`, `PTU-localization`).
`errors=[]`. No story failed, so AC 6 has no failing story to link.

## Build

`Web Playtest` export into `build/web/` from `34ac59e`, pck sha256
`6e8f99c3…cdaa90`, `Godot 4.7.2.stable.official.ed1daf0bf`. ADR-0009 publishes
only the seam-free `Web Release` build, and AC 7 needs the `DBG.*`/`TEL.*`
surface, so no published URL serves this preset; per `procedures.md` Prep this is
the recorded fallback and never stands in for a published reading. Both manifests
name the same commit, binary, pck hash and session id.

## AC 8 — art opened at run time

From `static.json` (`TEL.*` `report.assets`), before protocol step 1:

- boot group: **11 of 11 opened**, unresolved `0`, `boot_outcome` `0`
- wave-1 `play` group: **19 of 19 opened**, unresolved `0`

The file-side checks in `logs/` agree (`35/35 cataloged game_assets/ file(s)`;
`14 of 14 boot asset file(s) resolved`) but prove presence, not opening. Every
piece and board row is judged on what rendered; no art row is `pass` on a
source-tree file alone and none is `not-judged` for an unresolved asset.

## The five `not-judged` rows

| Row | Why it could not be judged |
|---|---|
| `controls-point.md#US3` | US3.5 runs on **puzzle-play** (Wave 2); US3.1–US3.4 passed. |
| `difficulty-tunables.md#PS1` | `DIF.*` tunables are Wave 2 puzzle-stream. |
| `conditions-puzzle.md#PS1` | `END.W1`/`L4`/`L5`/`L6` are Wave 2 puzzle-stream. |
| `fields-play-puzzle.md#PS1` | Puzzle-play fields are Wave 2. |
| `localization.md#US1` | US1.2/US1.3 passed; US1.1 is a **spec review** of key names, which no run can judge. |

`not-judged` never counts as `pass`: the three protocols above are `not-judged`
and gate on another run.

## The one visual finding

On the earlier build `8cdfd45` a focused control painted its label in the engine
theme's light focus colour, invisible on the cream fill. That is **accepted
#793** (the same chrome defect, fixed in `game/ui_chrome.gd` by overriding
`font_focus_color` plus the hover and pressed colours to `COLOR_INK`). This build
does not reproduce it, so nothing new is filed: see the graphical
[`01-mode-pick-S1.png`](../graphical-20261024T200132Z/screenshots/01-mode-pick-S1.png).
No story verdict changed — no `mode-pick` scenario asserts label contrast (US1.1
checks `C1`–`C4` are *available*, US1.9 checks copy *values*).

Capture and measurement corrections made before this run:
[driver-notes.md](driver-notes.md).
