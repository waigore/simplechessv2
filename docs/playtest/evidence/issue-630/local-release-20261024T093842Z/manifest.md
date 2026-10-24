# Manifest — #630 re-run of the reproduction, local `Web Release` build

- **Issue**: #630 — Shipped release never leaves the loading screen: `game_assets/` is not in the Web export
- **Environment**: `graphical` — Chrome 156.0.8078.47 headless via `puppeteer` 23.11.1, 390×844 CSS px, DPR 2, mobile + touch, WebGL 2.0 (SwiftShader). No seam, no playtest overlay
- **Build observed**: `Web Release` export of this worktree at `main` `eb72873`, exported with `python3 .github/scripts/web_export.py --preset "Web Release"` (Godot 4.7.2), served from `build/web/` with `python3 -m http.server`
- **Build also observed (control)**: the published release `https://waigore.github.io/simplechessv2/`, whose `index.pck` is still dated 2026-10-24 01:25 UTC — it predates `#647`'s merged route (`.github/scripts/web_export.py` loose-serving, `main` `e41a6f5`) and was never redeployed
- **Repeat count**: 2 cold opens of each build; identical result

## Results

| Observation | Local `Web Release` (`eb72873` + `#647`) | Published build (pck 2026-10-24 01:25 UTC) |
|---|---|---|
| `Preload boot` line | **none** — boot settles resolved | `ERROR: Preload boot left 9 approved IDs unresolved` at 6.87 s |
| `Error opening file` / `Can't open file` lines | **0** | **9** SVG + **5** WOFF2 |
| `Preload ambient` line | `Preload ambient left 2 approved IDs unresolved` (at 13.11 s) — #715's object, not the boot group | not reached |
| Screen at 390×844 | **mode pick** (OCR: `Choose how to play`, `Puzzle stream`, `Quit`, `English`) | `Loading...` still on screen after a 10 s settle |
| `index.pck` | **9 561 236** B | 252 144 B |
| `game_assets/` served loose beside `index.html` | **yes** — 39 files; `game_assets/fonts/noto-sans-latin-400.woff2` → `200`, 13 120 B | **no** — `game_assets/fonts/noto-sans-latin-400.woff2` → `404` |
| `--check-assets` | `35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)` | not applicable (not a `#647` tree) |
| `--check-boot` | `14 of 14 boot asset file(s) resolved` | reference: the same check on a tree with `game_assets/` removed reports `0 of 14 boot asset file(s) resolved — no route serves` (red), naming all 14 IDs |

## Paths

- `logs/local-release-cold-open.log` — local `Web Release` cold open, console with timestamps
- `logs/published-cold-open.log` — published build cold open, console with timestamps
- `screenshots/local-release-mode-pick-390x844.png` — local build at 20.08 s: mode pick
- `screenshots/published-loading-390x844.png` — published build at 17.71 s: `Loading...`

## Not claimed

- The published build's mode pick is **not** observed. It cannot be, until a `Web release` run on a `main` commit carrying `#647` publishes successfully; no such run exists yet, and the `Web release` workflow has not run at all on the current `main` tip.
- The acceptance criteria that are observations **of the published build** (`Preload boot left 0`, no asset error line on the published URL, mode pick on the published URL) are therefore unobserved from outside.
- Ambient audio (`music/cafe-ambient-a.ogg`, `music/cafe-ambient-b.ogg`) does not resolve on the local release build either — that is #715's object and does not hold the loading screen.
