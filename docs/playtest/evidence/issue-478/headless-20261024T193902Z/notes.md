# Notes — #478 headless run `20261024T193902Z`

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 478`).

One `Web Playtest` build, one `TEL.3` session id, one row set. This run judges the
eight design protocols and the nine UX protocols; the
[graphical run](../graphical-20261024T193922Z/manifest.md) re-runs the nine UX
protocols on the same build and writes the screenshots. Rows: [manifest.md](manifest.md).

## Result

**45 pass, 0 fail, 5 not-judged** over 50 story rows; 14 of 17 protocols `pass`,
3 `not-judged` (`PTD-mode-and-config`, `PTU-controls`, `PTU-localization`).
`errors=[]`. No story failed, so AC 6 needs no defect for a failing story.

## Build

`Web Playtest` export into `build/web/` from `8cdfd45`, pck sha256
`17a820b6…75550`, `Godot 4.7.2.stable.official.ed1daf0bf`. ADR-0009 publishes only
the seam-free `Web Release` build, and AC 7 needs the `DBG.*`/`TEL.*` surface, so
no published URL serves this preset; per `procedures.md` Prep this is the recorded
fallback and never stands in for a published reading. Both manifests name the same
commit, binary, pck hash and session id.

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

## Defect filed

**#833** — a focused control paints its label in the engine theme's light focus
colour instead of `COLOR_INK`, so on the cream fill it is invisible ("Shared
game" / `共用對局` on `mode-pick` S1). Seen in the graphical run's
[`01-mode-pick-S1.png`](../graphical-20261024T193922Z/screenshots/01-mode-pick-S1.png)
and
[`10-mode-pick-zh-Hant.png`](../graphical-20261024T193922Z/screenshots/10-mode-pick-zh-Hant.png),
and in the browser export 10 s and 14 s after load, so it is not a tween
mid-flight. `game/ui_chrome.gd` `style_button` overrides `font_color` but leaves
`font_focus_color` at the default.

No story verdict changed: no `mode-pick` scenario asserts label contrast (US1.1
checks `C1`–`C4` are *available*, US1.9 checks copy *values*). The defect is
filed from observation rather than turning an unasserted property into a
fabricated `fail`. A contrast row would belong to `specs/view/perception.md`,
which covers squares (R2) and side-to-move (R6) only — a spec gap, not this
task's.

Capture and measurement corrections made before this run: [driver-notes.md](driver-notes.md).
