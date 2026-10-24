# Manifest — #630 re-run of the reproduction on the published release build

- **Issue**: #630 — Shipped release never leaves the loading screen: `game_assets/` is not in the Web export
- **Environment**: `graphical` — Chrome 156 headless via `puppeteer` 23.11.1, 390×844 CSS px, DPR 2, mobile + touch, WebGL 2.0 (SwiftShader). No seam, no playtest overlay (ADR-0004: release build only)
- **Build observed (primary)**: the **published** release `https://waigore.github.io/simplechessv2/` after `Web release` run [`40096272525`](https://github.com/waigore/simplechessv2/actions/runs/40096272525) (workflow_dispatch, `main` `a5b35ae`, concluded `success`; `Release export` **success**, `Deploy to Pages` **success**). `index.pck` on the served tree: `200`, **9 561 236 B**, `last-modified: Sat, 24 Oct 2026 13:00:58 GMT`
- **Build observed (secondary)**: a fresh `Web Release` export of `main` `a5b35ae` (`python3 .github/scripts/web_export.py --preset "Web Release"`, Godot 4.7.2 stable `ed1daf0bf`), served from `build/web/` with `python3 -m http.server`
- **Control (the defect as filed)**: the same published URL before that run deployed — `index.pck` `252 144` B, `last-modified: Sat, 24 Oct 2026 01:25:16 GMT`
- **Coverage mode**: release build, cold open, no seam. Screenshots are graphical; the console capture is headless in the same browser process
- **Repeat count**: 1 cold open per build per phase (before / local / after). The boot result was identical to the previous recorded re-run (`docs/playtest/evidence/issue-630/local-release-20261024T093842Z/`) on the local build

## Results

| Observation | Published, **before** redeploy (control) | Fresh `Web Release` of `main` `a5b35ae` | Published, **after** redeploy |
|---|---|---|---|
| `Preload boot left N approved IDs unresolved` | **`ERROR: Preload boot left 9 approved IDs unresolved`** (3.80 s) | **no line** — boot group settles resolved | **no line** — boot group settles resolved |
| Asset open failures in the `boot` group | **14** (`Error opening file` ×2 SVG, `Can't open file` ×5 WOFF2, plus the remaining icon/interface-art files) | **0** | **0** |
| `Error opening file 'game_assets/…'` line | **present** | **absent** | **absent** |
| `Preload ambient left N` | not reached (boot stalls first) | `Preload ambient left 2 approved IDs unresolved` (6.90 s) — #715's object | `Preload ambient left 2 approved IDs unresolved` (4.10 s) — #715's object |
| Screen at 390×844 | `Loading...` still on screen after a 12 s settle | **mode pick** — `Choose how to play`, `Puzzle stream`, `Quit`, `English` | **mode pick** — identical |
| `index.pck` | 252 144 B | 9 561 236 B | **9 561 236 B** |
| `GET /game_assets/fonts/noto-sans-latin-400.woff2` | **404** | 200, 13 120 B | **200, 13 120 B** |
| `GET /game_assets/icons/quit.svg` | **404** | — | **200, 1 402 B** |
| `--check-assets` | n/a (not a `#647` tree) | `35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`, rc 0 | n/a (check runs in CI, not on the published URL) |
| `--check-boot` | n/a | `14 of 14 boot asset file(s) resolved`, rc 0 | n/a |

The `boot` group has **14** asset IDs and the log only prints a failure line, so a resolved boot group is silent. "`Preload boot left 0`" is therefore observed as **the absence of any `Preload boot` line together with a rendered mode pick** — the ready event fired and `SessionRouter` left `STAGE_LOADING`. Recorded this way rather than quoting a line the build does not print.

## `#647`'s `Web release` check, red and green by run URL

| Direction | Run | Result |
|---|---|---|
| **Green** — shipped tree carries the cataloged assets | [`40096272525`](https://github.com/waigore/simplechessv2/actions/runs/40096272525) (`main` `a5b35ae`) | `Release export` **success** → published. Both `--check-assets` and `--check-boot` passed inside *Export Web release* |
| **Red** — shipped tree carries no cataloged asset file | [`40096643098`](https://github.com/waigore/simplechessv2/actions/runs/40096643098) (branch `probe/630-assetless-probe`, `232bfa0`) | `Release export` **failure** at *Export Web release*, rc 1, message **`the shipped tree carries no game_assets/ asset file`** |

The red run's branch carries the same tree as `main` `a5b35ae` with every file under `game_assets/` removed (the directory itself retained, so the failure is the check's, not the staging step's). It is a throwaway probe branch, not a candidate change: it was pushed only to exercise the gate and is deleted after this run. An earlier attempt that removed the directory entirely failed one step earlier (`missing asset directory: game_assets/`, run [`40096532811`](https://github.com/waigore/simplechessv2/actions/runs/40096532811)) and is **not** cited as the red direction, because it does not test the assets check.

## ADR route observation (recorded, not graded)

`specs/adr/decisions/0014-web-asset-root-route.md` **exists**, `Status: Accepted`, dated 2026-10-24.

It records the shipped location as **packed into `index.pck`** under `res://game_assets/…`. Measured on the served pack this run: `res://game_assets/icons/quit.svg`, `res://game_assets/fonts/noto-sans-latin-400.woff2` and 7 `res://audio_runtime/` entries are present in the published `index.pck`.

The observation also shows what ADR-0014 does **not** record: the resolved-over-HTTP copy. The published tree serves `game_assets/` **loose beside `index.html`** as well (`quit.svg` → `200`, `woff2` → `200`), and `web_export.py`'s `prepare_asset_root` is what puts it there. On Web the resolver reads through `ResourceLoader`, which succeeds from either location. So the route **as recorded** (packed) is present and correct but is not by itself what the browser served this run; the **loose copy** is. This is an observation for `#636` (ADR owner) and `#647`, not a grading of AC5.

## Not claimed

- **No `quality.md` row is claimed cleared by this defect.** Two rows became *reachable* (the screen renders), not *measured*: see the outcome comment.
- The `ambient` group still leaves 2 IDs unresolved on both the local and the published build (`music/cafe-ambient-a.ogg`, `music/cafe-ambient-b.ogg`). That is **#715**'s object and does not hold the loading screen.
- The "Shared game" button renders with very low label contrast in both mode-pick screenshots. Not measured here and not this issue's object; recorded for whoever next grades `#640`/`#641`.
- The boot result on the published URL is a single cold open. It is not a soak; `#626` owns that.

## Paths

- `logs/published-before-redeploy.log` — published URL before the redeploy: 9 unresolved boot IDs, `Loading...`
- `logs/published-after-redeploy.log` — published URL after run `40096272525`: boot resolved, mode pick
- `logs/local-release-cold-open.log` — fresh `Web Release` export of `main` `a5b35ae`, served locally
- `screenshots/published-before-redeploy-loading-390x844.png` — `Loading...` (control)
- `screenshots/published-mode-pick-390x844.png` — published build at 22.63 s: mode pick
- `screenshots/local-release-mode-pick-390x844.png` — local release build at 26.03 s: mode pick

## Defects

- **#715** — `ambient` group (2 IDs) unresolved; visible in every log here as `Preload ambient left 2 approved IDs unresolved`.
