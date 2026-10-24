# Setup — #557 graphical run `20261024T012000Z`

Reproducible from this folder alone.

## Requirements

- Google Chrome at `/Applications/Google Chrome.app` (recorded version: `Chrome/156.0.8078.47`).
- Node.js (recorded: v25.8.0) and `puppeteer-core@23`.

## Commands

```sh
cd docs/playtest/evidence/issue-557/graphical-20261024T012000Z
npm install puppeteer-core@23
node driver.mjs . 25000
```

`driver.mjs` takes the output directory and the per-open settle in ms. It writes `run.json`, `logs/leg-{1,2,3}.console.log`, and `screenshots/*.png` into that directory.

## What the driver does

Drives **only** the published URL `https://waigore.github.io/simplechessv2/`. It never builds, exports, or serves anything locally, and it reads no repo code.

Per leg, in one browser with one profile so the origin store persists across reopens:

1. **Leg 1** — cold open, 25 s settle, read the persist document and screenshot, close the page, cold open again, re-read, screenshot.
2. **Leg 2** — cold open, 25 s settle, read/screenshot, kill the renderer with CDP `Page.crash` (no quit path), cold open again, re-read, screenshot.
3. **Leg 3** — cold open, 25 s settle, read/screenshot, install a `Storage.prototype.setItem` wrapper that silently drops writes to `simplechessv2.persist.v1` and counts them, 25 s window, read/screenshot, restore the original `setItem`, cold open again, re-read, screenshot.

## Flags and why

- `headless: true` — no display needed; the run is reproducible on any machine with Chrome.
- `390×844 @ DPR 2` — the mobile web target the issue's build is designed for.
- `25000` ms settle — the window #630's own reproduction used; the stall is permanent, so the exact value does not change the outcome.
- No `--enable-unsafe-swiftshader`: WebGL 2.0 initialises from the real GPU here, so the run does not depend on a software rasteriser.

## Known limitation

The game draws into a WebGL canvas, so `visible_text` (a DOM read) is empty in every leg. Screen observation rests on the screenshots and the console; `readings.md` says so explicitly.
