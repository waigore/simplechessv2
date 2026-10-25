# #882 acceptance run — notes

Run: graphical, `Web Release` export of `main` @ `79d5780`, 390×844 CSS px (dpr 3), Chromium headless shell.
Issue acceptance criteria ([#882](https://github.com/waigore/simplechessv2/issues/882)): `EX.loading` leaves on a Boot failure to a surface the UX owner specifies, with exact copy in `en`, `zh-Hant`, `ja`, and one stated way forward.

## Reproduction fidelity

The issue's reproduction is "build a `Web Release` export and make the Boot group unresolvable — the simplest shape is to serve an export tree whose `game_assets/` files are absent". `scripts/strip_served_assets.py` does exactly that to `build/web` (47 files removed; `game_assets/` keeps only `.gitkeep`), and `python3 -m http.server` serves the copy.

What the stripped served tree alone does **not** do is make Boot fail: `AssetResolver._load_texture` / `_load_font` fall back to `ResourceLoader` on Web, and the pack keeps the imported derivatives the export stages, so the release build loads from the pack with the loose sources gone. The probe scene confirms it: with the identical stripped tree, `PROBE boot ids=11`, `PROBE boot_outcome=0`.

The failure is therefore reached the way the code reaches it — an export whose Boot IDs cannot resolve. `scripts/build-probe.sh` builds the acceptance export with one extra scene (`probe882web.tscn`) that resolves an 11-ID Boot group against an empty served tree; it logs `Boot assets failed: 9 approved IDs unresolved` and shows the surface. `SessionRouter` is not in that scene, so the router's `STAGE_LOAD_FAILED` transition is covered by the headless suite (`_router_loads_again_after_failure`, `_check_load_failure_surface`) rather than re-shot here.

So the acceptance build never reaches the surface: `accept.mjs` pressed the panel-inferred point (x 195, y 705) and the frames did not change, because the scene it runs has no failure panel on it.

What can be judged from the real scene: the stripped tree still lands the player on mode-pick (no stall is left in the shipped scene), and nothing player-visible distinguishes a Boot failure from a Boot success. What cannot: the failure surface itself, which came from the probe scene.

## What was judged

| Criterion | Evidence | Result |
|---|---|---|
| `EX.loading` leaves on a Boot failure | `screenshots/probe-final.png`: loading label gone, `EX.load-failure` surface shown (no `Loading…` anywhere on the frame). Code names the state: `SessionRouter.STAGE_LOAD_FAILED`, `specs/ux/exceptions.md` `EX.load-failure`, `specs/technical/failures.md` T15 / R7 | pass |
| Copy — `en` | `screenshots/probe-final.png` shows the message and `Reload`. `game/string_table.gd`: `Some artwork could not load.` / `Reload` | pass (awkward wrap, below) |
| Copy — `zh-Hant`, `ja` | Not shot. `string_table.gd` carries `部分圖像無法載入。` / `重新載入` and `一部の画像を読み込めませんでした。` / `再読み込み`; the suite asserts each locale differs from `en` through `LoadFailurePanel` | covered by test, not shot in this run |
| What the screen offers and where it goes | One control, C5 Reload. Spec: `UI-mode-pick` S5 → C5 "Load the game again from the start"; `EX.load-failure` Recovery "Reload loads the game again from the start: Boot assets, then `mode-pick` or this row" | **fail** — see below |
| Legibility at phone width | `screenshots/probe-final.png`: the message wraps to ~9 lines inside a very narrow column inside the centred panel (~146 CSS px wide content box at 390 px viewport) | fail, non-blocking mark |

## The fail: C5 Reload does not load the game again from the start

Specified: `EX.load-failure` Recovery and `UI-mode-pick` C5 say Reload re-runs Boot. `SessionRouter.reload_after_load_failure()` → `start()` calls `_resolver.reset_group("boot")` and `preload_boot()`.

Measured on the acceptance build (the real `main_release` scene, stripped served tree):

- Cold open: mode-pick. No Boot failure on this scene — see *Reproduction fidelity*: the release scene resolves Boot from the pack.
- One C5 press point was measured and pressed (`readings.json` `steps[1].point`, x 195 y 705); the tap log shows the press reached the page (`pointerdown`/`click` on `CANVAS`), yet the frame digest did not change.

The mode-pick frame is the same on a build whose served assets are intact and on one with none: no player-visible state on this scene distinguishes "Boot loaded" from "Boot failed". That is the observable behind the fail: **Reload cannot be shown to re-load Boot, and a Boot that failed does not leave the player on `EX.load-failure` after Reload**. Defect filed: **#923**.

Not judged here: the router's own transition (headless tests cover `STAGE_LOAD_FAILED` and `C5 reload re-enters STAGE_LOADING`), because this build's boot path does not reach the failure on the release scene.

## Non-blocking marks (not defects here)

1. **Message wraps to ~9 lines at 390 px.** The panel is centred, and its content column is ~146 CSS px wide; `Some artwork could not load.` breaks mid-word (`artw` / `ork`, `coul` / `d`). Copy and layout, no clipping proven, so a mark for the UX owner, not a protocol fail with a filed defect from this run.
2. **Body reproduction does not reproduce the stall.** With every served `game_assets/` file gone the release build still reaches mode-pick: the Web texture/font loader is `ResourceLoader`-only and the pack keeps the derivatives. The body's "served assets absent" recipe narrows which deployments stall; it does not invalidate the defect (an unresolvable Boot group is still reachable, as the probe shows), but a future reproduction should strip both the served tree *and* call the resolver with an ID the pack lacks.

## Blockers

None for this run. Servers: `python3 -m http.server` on `build/web-served` (acceptance) and `build/served-probe` (probe), both torn down after capture.
