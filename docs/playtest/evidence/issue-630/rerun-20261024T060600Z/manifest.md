# Manifest — #630 reproduction re-run on the published release build

- **Issue**: #630 — Shipped release never leaves the loading screen: `game_assets/` is not in the Web export
- **Environment**: `graphical` — Google Chrome (puppeteer-core, headless) at 390×844 CSS px, DPR 2, SwiftShader WebGL; no seam, no playtest build
- **Build observed**: published release `https://waigore.github.io/simplechessv2/`; `deployments` API reports Pages serving `a68640a604aba249b93a1e61db44af7f28c3b5e0`, published by `Web release` run [`40035516341`](https://github.com/waigore/simplechessv2/actions/runs/40035516341) (completed 2026-10-23T22:44:50Z). Not the `98d3473` build #402 measured; the stall is unchanged across the two.
- **Repeat count**: 1 cold open of the published URL, 25 s wait (the original run repeated 4×; identical result)

## Reproduction steps re-run (unchanged)

| Step | Result |
|---|---|
| 1. Pages enabled, `build_type=workflow` | confirmed (`#510` still fixed; the build is published) |
| 2. Open the URL at 390×844 | `1096ms [nav] status=200` |
| 3. Engine finishes loading | `Godot Engine v4.7.2.stable.official` prints; WebGL canvas up |
| 4. Console | **14** `Error opening file 'game_assets/…'` / `Can't open file from path 'game_assets/…'` lines, then `ERROR: Preload boot left 9 approved IDs unresolved` |
| 5. Screen | `Loading…` persists the full 25 s; no transition to mode pick |
| 6. Asset root not shipped | `curl https://waigore.github.io/simplechessv2/game_assets/fonts/noto-sans-latin-400.woff2` → `404` |

## Shipped tree carries no cataloged asset file

- `index.pck` served size: **252 080 bytes** (`content-length`), i.e. still in the asset-less band — the `98d3473` build measured 221 228 bytes. Neither carries `game_assets/`.
- The browser issued **no** request for any `game_assets/` path during the run; the only asset-adjacent response logged was `200 index.pck`.

## `#647` units observed

- ADR-0014 (`specs/adr/decisions/0014-*.md`): **absent** on `main` `b4cc13e` (`specs/adr/decisions/` runs `0001`–`0013`). Owner `#636` (`status:pending-review`).
- `#647`'s route implementation, `Web release` asset-presence check, S1 spec correction, `_preload` surfaced failure and inverted `_check_preload_gap`: **none landed**; `#647` is `status:pending-implementation` and natively blocks this defect.
- No red/green `Web release` asset-presence check runs exist to cite.

## Paths

- `logs/release-cold-open-rerun.log` — published build, cold open, 25 s wait
- `screenshots/release-cold-open-rerun-390x844.png` — published build after 25 s: `Loading…`

## Defects

- #630 — `game_assets/` missing from the Web export: the release build never leaves `EX.loading` (unchanged; blocked on #647)
