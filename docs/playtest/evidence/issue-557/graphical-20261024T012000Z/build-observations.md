# Build observations — `46cec71`

Reproduction and the raw mechanism behind the `not-judged` verdicts.

## Build under test

- URL: `https://waigore.github.io/simplechessv2/` → HTTP `200`.
- Deploy commit: `46cec71aaaa72439d9dce4fb19299f374efe2cdb`, `Web release` workflow run `40041185072`, 2026-10-23T23:42:44Z, conclusion `success`.
- `index.pck`: HTTP `200`, `251 904` bytes.
- `game_assets/fonts/noto-sans-latin-400.woff2` → HTTP `404` (the asset root is not shipped).

## Boot console (every cold open, identical)

Fifteen file failures, then the unresolved-group error:

```
ERROR: Error opening file 'game_assets/icons/style-anchor-sheet.svg'.
ERROR: Error opening file 'game_assets/interface-art/style-anchor-sheet.svg'.
ERROR: Can't open file from path 'game_assets/fonts/noto-sans-tc-400.woff2'.
ERROR: Can't open file from path 'game_assets/fonts/noto-sans-jp-400.woff2'.
ERROR: Can't open file from path 'game_assets/fonts/noto-sans-latin-400.woff2'.
ERROR: Can't open file from path 'game_assets/fonts/noto-sans-latin-500.woff2'.
ERROR: Can't open file from path 'game_assets/fonts/noto-sans-latin-600.woff2'.
ERROR: Error opening file 'game_assets/icons/quit.svg'.
ERROR: Error opening file 'game_assets/icons/mode-puzzle.svg'.
ERROR: Error opening file 'game_assets/icons/mode-shared.svg'.
ERROR: Error opening file 'game_assets/interface-art/panel-surface.svg'.
ERROR: Error opening file 'game_assets/icons/advice.svg'.
ERROR: Error opening file 'game_assets/interface-art/chip-surface.svg'.
ERROR: Error opening file 'game_assets/icons/back.svg'.
ERROR: Preload boot left 9 approved IDs unresolved
```

Engine banner on every open: `Godot Engine v4.7.2.stable.official.ed1daf0bf`, WebGL 2.0, Emscripten 4.0.20, single-threaded.

## Code path at the deployed commit

- `game/asset_resolver.gd::_preload` — on `missing > 0` it pushes the error and **returns**; `done.emit()` is skipped, so `boot_ready` never fires.
- `game/session_router.gd` — `_on_boot_ready` is the only transition out of `STAGE_LOADING`.

Net effect: `EX.loading` is permanent, mode pick never renders, and no persist write is ever attempted.

## Persist document

`localStorage` after a 25 s settle: **no keys at all** — `simplechessv2.persist.v1` is absent, not present-and-empty. Leg 3's `Storage.prototype.setItem` wrapper recorded `0` calls for the persist key.

## Reproduce

```sh
cd docs/playtest/evidence/issue-557/graphical-20261024T012000Z
npm install puppeteer-core@23
node driver.mjs . 25000
```

Requires Google Chrome at `/Applications/Google Chrome.app`. Writes `run.json`, `logs/`, `screenshots/` in place. The driver has no repo code dependency; it drives the published URL only.
