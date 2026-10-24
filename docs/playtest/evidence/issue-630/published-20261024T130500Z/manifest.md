# Manifest — #630 re-run on the published release build

- **Issue**: #630 — shipped release never leaves the loading screen
- **Environment**: `graphical` — Chrome 156 headless (`puppeteer` 23.11.1), 390×844 CSS px, DPR 2, WebGL 2.0 (SwiftShader), release build, no seam (ADR-0004)
- **Primary build**: published release `https://waigore.github.io/simplechessv2/` after `Web release` run [`40096272525`](https://github.com/waigore/simplechessv2/actions/runs/40096272525) (`main` `a5b35ae`, `success`; `index.pck` 9 561 236 B)
- **Secondary build**: fresh `Web Release` export of `main` `a5b35ae` (`web_export.py --preset "Web Release"`, Godot 4.7.2), served from `build/web/`
- **Control**: the same URL before that deploy — `index.pck` 252 144 B, `last-modified` 01:25:16 GMT
- **Repeat count**: one cold open per build per phase

## Results

| Observation | Before redeploy | Local release `a5b35ae` | After redeploy |
|---|---|---|---|
| `Preload boot left N` | **9 unresolved** (3.80 s) | no line — resolved | **no line — resolved** |
| Asset open failures in `boot` | **14** | 0 | **0** |
| `Preload ambient left N` | not reached | 2, #715 | 2, #715 |
| Screen at 390×844 after 12 s | `Loading...` | **mode pick** | **mode pick** |
| `GET /game_assets/icons/quit.svg` | **404** | — | **200**, 1 402 B |
| `--check-assets` / `--check-boot` | n/a | 35/35 files; 14/14 boot IDs | n/a (CI only) |

The `boot` group has 14 IDs and the log prints only failures, so a resolved group is silent: it is observed as the absence of a `Preload boot` line plus a rendered mode pick.

## `#647`'s check, red and green

- **Green**: [`40096272525`](https://github.com/waigore/simplechessv2/actions/runs/40096272525) (`main` `a5b35ae`) — `Release export` success, both asset checks passed.
- **Red**: [`40096643098`](https://github.com/waigore/simplechessv2/actions/runs/40096643098) (`probe/630-assetless-probe`, `232bfa0`) — `main` `a5b35ae` minus every file under `game_assets/`; failed at *Export Web release* with `the shipped tree carries no game_assets/ asset file`. Throwaway branch, not a candidate change. An earlier probe that removed the directory failed one step earlier and is not cited.

## ADR-0014 observation (not graded)

`specs/adr/decisions/0014-web-asset-root-route.md` (Accepted) records the packed location, `res://game_assets/…`, which the served pack does carry. The published tree *also* serves `game_assets/` loose beside `index.html` (`prepare_asset_root`), and that is the copy the browser fetched this run. The route as recorded is present but is not by itself what the browser served. For #636 and #647.

## Not claimed

- No `quality.md` row is cleared. The board became *reachable*, not *measured*; the timed, sitting, save-durability and localization rows need their own runs.
- The `ambient` group's 2 IDs remain unresolved on both builds — #715.
- The "Shared game" label contrast is low in both screenshots; recorded for #640/#641, not measured.
- One cold open per phase; not a soak (#626).

## Paths

- `logs/published-before-redeploy.log` — control: 9 unresolved boot IDs, `Loading...`
- `logs/published-after-redeploy.log` — after run `40096272525`: mode pick
- `logs/local-release-cold-open.log` — fresh local `Web Release` export
- `screenshots/published-before-redeploy-loading-390x844.png` — control
- `screenshots/published-mode-pick-390x844.png` — published build, 22.63 s
- `screenshots/local-release-mode-pick-390x844.png` — local build, 26.03 s

## Defects

- **#715** — `ambient` group (2 IDs) unresolved.
