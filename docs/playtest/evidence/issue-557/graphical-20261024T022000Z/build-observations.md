# Build observations — #557 run `20261024T022315Z`

## What was checked before the legs ran

| Question | Answer on 2026-10-24T02:19Z | Source |
|---|---|---|
| Does the published URL serve a release? | yes — HTTP 200, `index.pck` 252 144 bytes | `curl -o /dev/null -w '%{http_code}'` |
| Which commit does it serve? | `fb1e57e` — the last `Web release` run to succeed on `main` (`40053375882`, 2026-10-24T02:14:59Z) | `gh run list --workflow web-release.yml` |
| Is #630's repair publishable yet? | **no** — `407`'s merge (`bccdb1c`) makes `Web release` **fail** at its own `Check the shipped tree carries the asset root` step (`find: build/web/game_assets: No such file or directory`), so no later commit has published | `gh run view 40053375882 --log-failed` |
| Does the build reach mode pick? | **no** — `Preload boot left 9 approved IDs unresolved` on every open; `EX.loading` persists | `logs/leg-*.console.log` |
| Can the build deal a puzzle? | **no** — `T9`/`T10` unset, so `CatalogDealClient.is_available()` is false and `PuzzleStream` refuses every deal | #655, #648, #479 (open) |

## What the run measured

Six cold opens, 20 s settle each, one profile so the origin store persists across the legs. Every open produced the same 102 console lines and the same `Loading…` screen (`md5 7ba3b2c7…`, one distinct image in seven captures).

- Leg 1: close after the settle, cold open again → `localStorage` empty both times.
- Leg 2: `chrome://crash` in place of the quit path, cold open again → `localStorage` empty both times; no mode-pick selection existed to abandon.
- Leg 3: `Storage.prototype.setItem` wrapped to silently drop writes to `simplechessv2.persist.v1` before the settle window, then restored → the wrapper counted **0** attempts, so the build never called `_web_set` and `_web_set`'s round-trip check was never reached.

## Reproduce

```sh
cd docs/playtest/evidence/issue-557/graphical-20261024T022000Z
npm install puppeteer-core@23
node driver.mjs 20000
```

Requires Google Chrome (`/Applications/Google Chrome.app`) and Node ≥ 20. The driver reads only `https://waigore.github.io/simplechessv2/`; it builds nothing and reads no repo code. `BUILD_COMMIT` / `BUILD_RUN` override the recorded build fields if Pages has moved.

## What would change the result

Nothing this task can do. All three legs need a build that renders mode pick (#630, repaired by #677 and not publishable) and a dealt puzzle (#655 / #648 / #479). Re-running the same driver at that point produces the comparisons this folder records as `not-judged`.
