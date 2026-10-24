# Notes — #478 graphical run `20261024T193922Z`

Unattended `issue-workflow-implement-agent` run (parallel id 3, `Assigned issue: 478`).

One `Web Playtest` build, one `TEL.3` session id, one row set. This run re-runs the
nine UX protocols on the same build as the
[headless run](../headless-20261024T193902Z/manifest.md) and writes the
screenshots; the design protocols are headless-only. Rows: [manifest.md](manifest.md).

## Result

**18 pass, 0 fail, 2 not-judged** over the 20 UX story rows; 7 of 9 protocols
`pass`, 2 `not-judged` (`PTU-controls`, `PTU-localization`). `errors=[]`,
87 `TEL.*` lines, 11 screenshots under `screenshots/`. No story failed, so AC 6
needs no defect for a failing story.

## Build

Identical to the headless run: `Web Playtest` export into `build/web/` from
`8cdfd45`, pck sha256 `17a820b6…75550`, `Godot 4.7.2.stable.official.ed1daf0bf`,
session `sess-20261025-478-wave1-playtest`. ADR-0009 publishes only the seam-free
`Web Release` build, and AC 7 needs the `DBG.*`/`TEL.*` surface, so this is the
`procedures.md` fallback, recorded as such.

## AC 8 — art opened at run time

From `static.json` (`TEL.*` `report.assets`):

- boot group: **11 of 11 opened**, unresolved `0`, `boot_outcome` `0`
- wave-1 `play` group: **19 of 19 opened**, unresolved `0`

Same reading as the headless run, so the screenshots above are of a build whose
piece and board art actually opened, not merely of files that exist.

## The two `not-judged` rows

| Row | Why it could not be judged |
|---|---|
| `controls-point.md#US3` | US3.5 runs on **puzzle-play** (Wave 2), so no wave-1 step reaches it; US3.1–US3.4 passed. |
| `localization.md#US1` | US1.2/US1.3 passed; US1.1 is a **spec review** of key names, which no run can judge. |

`not-judged` never counts as `pass`: `PTU-controls` and `PTU-localization` are
`not-judged` and gate on another run.

## Defect filed

**#833** — a focused control paints its label in the engine theme's light focus
colour instead of `COLOR_INK`, so on the cream fill it is invisible. Visible in
[`01-mode-pick-S1.png`](screenshots/01-mode-pick-S1.png) (C1 "Shared game") and
[`10-mode-pick-zh-Hant.png`](screenshots/10-mode-pick-zh-Hant.png) (`共用對局`);
the browser export shows the same 10 s and 14 s after load, so it is not the
0.45 s reveal tween. `game/ui_chrome.gd` `style_button` overrides `font_color`
but leaves `font_focus_color` at the theme default.

No story verdict changed: no `mode-pick` scenario asserts label contrast (US1.1
checks `C1`–`C4` are *available*, US1.9 checks copy *values*). Filed from
observation rather than turning an unasserted property into a fabricated `fail`.

The localization captures were mislabelled in earlier scratch runs because the
driver forced the shared-play stage while on `mode-pick`; `10`/`11` here are
mode-pick in `zh-Hant`/`ja`. Details: [driver-notes.md](driver-notes.md).
