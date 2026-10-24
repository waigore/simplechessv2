# Setup — #557 graphical run `20261024T204223Z`

Reproducible from this folder alone.

## Requirements

- Google Chrome 156.0.8078.47 at `/Applications/Google Chrome.app`.
- Node.js ≥ 20 and `puppeteer-core@23` (`npm install puppeteer-core@23` in this folder; `node_modules/` is git-ignored).

## Command

```sh
npm install puppeteer-core@23
node driver.mjs
```

`SETTLE_MS` overrides the 20 s per-open settle; `BUILD_COMMIT` and `BUILD_RUN` override the build fields recorded in `run.json`.

## What the driver does

Drives **only** the published URL `https://waigore.github.io/simplechessv2/`. It never builds, exports, or serves anything locally, and it edits no repo file.

One browser, one profile, so the origin store persists across every open and reopen. Before each tap the screen is classified from canvas pixels, and navigation goes through the build's own controls:

- mode pick: `Shared game` (C1) or `Puzzle stream` (C2), each of which commits `last_mode`
- shared setup: `Back`
- puzzle play: `Leave stream`, then the `Leave the puzzle stream?` confirm

1. **Leg 1** — cold open, settle, read the document and screenshot, enter Puzzle stream and attempt a result, leave and quit through the build, close the page, cold open again, re-read, screenshot.
2. **Leg 2** — cold open, reach mode pick, commit `shared`, press an uncommitted setup toggle, screenshot, kill the renderer by navigating it to `chrome://crash`, cold open again, re-read, screenshot.
3. **Leg 3** — cold open, reach mode pick, commit `shared`, install a `Storage.prototype.setItem` wrapper that silently drops writes to `simplechessv2.persist.v1` and counts them, commit `puzzle` (a changed value), read the wrapper state and screenshot, restore the native `setItem`, cold open again, re-read, screenshot.

## Judgement

The driver prints one line per leg (`pass` / `fail` / `not-judged`) and stores the same verdict in `run.json`. A leg is `pass` only when its comparison ran and held, `fail` when it ran and did not, and `not-judged` when the build never reached the state the leg compares. Leg 1 needs a dealt puzzle and a result commit; leg 2 needs a renderer that actually died; leg 3 needs the wrapper to have received at least one write *and* the build to have reported the failed write.

## Known limitation

The game draws into a WebGL canvas, so no game text is reachable from the DOM (`body_text_length: 0`). Screen observation rests on the screenshots, the measured pixel bands, and the console.
