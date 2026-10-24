# Setup — #557 graphical run `20261024T022315Z`

Reproducible from this folder alone.

## Requirements

- Google Chrome at `/Applications/Google Chrome.app` (the run recorded `headless` mode; no version pin beyond that, since the build's own console is the observation).
- Node.js ≥ 20 and `puppeteer-core@23`.

## Commands

```sh
cd docs/playtest/evidence/issue-557/graphical-20261024T022000Z
npm install puppeteer-core@23
node driver.mjs 20000
```

`driver.mjs` takes the per-open settle in milliseconds. It writes `run.json`, `logs/leg-{1,2,3}.console.log`, and `screenshots/*.png` into this folder and deletes its throwaway browser profile when it finishes. `BUILD_COMMIT` and `BUILD_RUN` override the build fields recorded in `run.json`.

## What the driver does

Drives **only** the published URL `https://waigore.github.io/simplechessv2/`. It never builds, exports, or serves anything locally, and it reads no repo code.

Per leg, in one browser with one profile so the origin store persists across reopens:

1. **Leg 1** — cold open, 20 s settle, read the persist document and screenshot, close the page, cold open again, re-read, screenshot.
2. **Leg 2** — cold open, settle, read/screenshot, kill the renderer by navigating it to `chrome://crash` (no quit path), cold open again, re-read, screenshot.
3. **Leg 3** — cold open, settle, read/screenshot, install a `Storage.prototype.setItem` wrapper that silently drops writes to `simplechessv2.persist.v1` and counts attempts, 20 s window, read/screenshot, restore the native `setItem`, cold open again, re-read, screenshot.

## Judgement

The driver prints one line per leg in `not-judged` / `pass` / `fail` form and stores the same verdict in `run.json`. A leg is `pass` only when a committed document existed before the open and survived unchanged; `fail` when it changed; `not-judged` when no committed document existed to compare. `manifest.md` explains why all three landed on `not-judged` for this build.

## Known limitation

The game draws into a WebGL canvas, so no game text is reachable from the DOM (`body_text_length: 0`). Screen observation rests on the screenshots and the console.
