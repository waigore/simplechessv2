# Setup — #557 graphical run `20261023T230618Z`

Tooling ran from a temp directory outside the repo (`$TMPDIR/orc557`) and is not kept, matching the `issue-592` precedent. Everything reproducible is below.

## Environment

| Item | Value |
|---|---|
| Host | macOS arm64 |
| Browser | Google Chrome 156.0.8078.47 (`/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`) |
| Driver | `puppeteer-core` 23 (`npm i puppeteer-core@23`), `headless: true` |
| Browser flags | `--window-size=390,844`, `--enable-unsafe-swiftshader` |
| Viewport | 390×844 CSS px, `deviceScaleFactor: 2` |
| Build under test | `https://waigore.github.io/simplechessv2/` at `a68640a604aba249b93a1e61db44af7f28c3b5e0` |
| Settle window | 30 000 ms after `domcontentloaded` per cold open |

No engine build, export, or server was run: the run measures the **published** build, which is the build the issue names.

## Driver shape

Three cold opens against the published URL, each recording:

- every `console` message, `pageerror`, and HTTP response ≥ 400;
- `localStorage.getItem("simplechessv2.persist.v1")` before and after the leg's action;
- a screenshot of the screen at each judged moment.

Leg actions:

1. **Quit/reload** — read the document, close the page through the normal browser close (the quit path), open the URL again, read the document and screenshot.
2. **Crash** — read the document, kill the renderer with CDP `Page.crash` (no in-game quit), open the URL again, read the document and screenshot.
3. **Faulted session** — install `Storage.prototype.setItem` throwing for `simplechessv2.persist.v1`, read the prior document, attempt a commit, read the document again, restore the wrapper, open the URL again, read the document and screenshot.

## Commands (shape)

```bash
mkdir -p "$TMPDIR/orc557" && cd "$TMPDIR/orc557" && npm init -y && npm i puppeteer-core@23
node probe.js     "$PWD/docs/playtest/evidence/issue-557/graphical-20261023T230618Z"  # cold open + build observations
node mechanism.js > .../logs/leg-0-mechanism.log                                       # setItem trace, localStorage key set
node legs.js      "$PWD/docs/playtest/evidence/issue-557/graphical-20261023T230618Z"  # the three legs
```

`probe.js` and `legs.js` write their logs themselves; the transcripts saved here are the driver stdout captures (`logs/leg-0-driver.log`, `logs/legs-1-3.driver.log`).
