# #882 acceptance run — notes

Run: graphical, `Web Release` export of `main` @ `79d5780`, 390×844 CSS px (dpr 3), Chromium headless shell. Build detail: [`reproduction.md`](reproduction.md).

Criteria ([#882](https://github.com/waigore/simplechessv2/issues/882)): `EX.loading` leaves on a Boot failure to a surface the UX owner specifies, with exact copy in `en`, `zh-Hant`, `ja` and one stated way forward.

## What was judged

| Criterion | Evidence | Result |
|---|---|---|
| `EX.loading` leaves on a Boot failure | `screenshots/probe-final.png`: no `Loading…`, `EX.load-failure` shown. Code: `SessionRouter.STAGE_LOAD_FAILED`; spec: `exceptions.md` `EX.load-failure`, `failures.md` T15 / R7 | pass |
| Copy — `en` | Same screenshot: `Some artwork could not load.` and `Reload` | pass (wrap mark below) |
| Copy — `zh-Hant`, `ja` | Not shot. `string_table.gd` carries both; `asset_resolver_test.gd` asserts each differs from `en` through `LoadFailurePanel` | pass |
| What the screen offers, where it goes | One control, C5 Reload; spec says "Load the game again from the start"; measured: it lands on mode-pick with Boot still unresolved | **fail — #923** |
| Legibility at 390 px | `probe-final.png`: message wraps to ~9 lines in a ~146 px column, breaking mid-word | mark, not a filed defect here |

## The fail: C5 Reload does not load the game again from the start

`exceptions.md` `EX.load-failure` Recovery and `UI-mode-pick` C5 both say Reload re-runs Boot. `SessionRouter.reload_after_load_failure()` → `start()` resets the Boot group and preloads it again; measured, the reload settles on mode-pick while the Boot group is still unresolved. Two player-visible consequences, both in #923: Reload drops the player into a mode-pick with no art, and a stripped served tree never shows the failure at all (so the body's own reproduction does not reach the surface).

`accept.mjs` ran the real `main_release` scene under the stripped tree: it opened on mode-pick and the panel-inferred press point (x 195, y 705) changed nothing, because no failure panel was on that scene. The surface itself came from the probe scene, not the shipped scene.

## Non-blocking marks (not defects from this run)

1. **Message wraps to ~9 lines at 390 px**, breaking mid-word (`artw` / `ork`, `coul` / `d`). Copy and layout, so the UX owner owns it; recorded in #923's context.
2. **The body's reproduction does not reproduce the stall.** With every served `game_assets/` file gone the release build still reaches mode-pick: the Web texture/font loader is `ResourceLoader`-only and the pack keeps the derivatives. The defect still holds — an unresolvable Boot group is reachable, as the probe shows — but the recipe should strip the served tree *and* use an ID the pack lacks.

## Blockers

None. Local servers on `build/web-served` (acceptance) and `build/served-probe` (probe) were torn down after capture.
