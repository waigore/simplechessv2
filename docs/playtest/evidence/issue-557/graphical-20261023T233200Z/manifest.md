# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/`; the `deployments` API reports Pages serving `3f81b59578fda7280d6ddf858f8f44feb308156d`, published by the `Web release` run of 2026-10-23T23:30:48Z. `index.pck` measured at `251 904` bytes. No `TEL.3` session id is reported: `TEL.3` lives on `CMP-playtest-seams`, which `main_release.tscn` does not carry (ADR-0004 `G2`), so a release export has no session id and none is invented here.
- **Timing (`SIT.4`)**: not a `SIT.4` run. macOS arm64, Google Chrome `156.0.8078.47`, `puppeteer-core` 23, headless with `--enable-unsafe-swiftshader`; viewport 390×844 CSS px at DPR 2. One cold open per leg, 20 s settle.
- **Coverage mode**: `critical-only`, scoped to the three legs this issue names.
- **Cited design/UX protocol**: none in scope. This is a `quality.md` durability check, not a design or UX protocol: no story rows, no protocol verdict. Rows below are the three legs plus the two quality claims they support.

## Results

| Row | Outcome | Basis |
|---|---|---|
| Leg 1 — quit/reload | `not-judged` | `puzzle-play` never opened and mode pick never rendered, so no result commit could run and no R2 Elo or Last-mode affordance existed to read |
| Leg 2 — crash | `not-judged` | mode pick never rendered, so no uncommitted selection could be made and abandoned before the kill |
| Leg 3 — faulted session | `not-judged` | no commit was reachable, so `PersistStore._web_set` was never entered and `EX.save-failure` was never reached |
| Quality — Reliability (recovery half) | `not-judged` | all legs `not-judged`; a leg that never reached mode pick cannot support a `pass` |
| Quality — Save durability | `not-judged` | no commit path reachable, so survival and prior-commit integrity are both unobserved |

**Defects**: none filed here. The blocker is the build-wide boot stall already tracked by **#630** (`status:pending-verification`, with its own rerun on this same build) and **#662**. This task files against **#35** only for a failing leg; a leg that never ran is `not-judged`, so none is invented.

`notes.md` records why every untouched row is `not-judged` rather than `fail`, and why a seeded-document check is not reported as a leg.

## Paths

- `screenshots/leg-0-cold-open-390x844.png` — build still on `EX.loading` after the settle window
- `logs/leg-0-cold-open.log` — cold-open console and HTTP capture from the driver
- `logs/driver.log` — leg-by-leg record including the skip reason
- `probe-summary.json` — machine-readable outcome (`modePickReachable: false`, three legs `not-judged`)
- `build-observations.md` — bundle size, `404` asset paths, and the repeated cold open
- `readings.md` — verbatim document and screen readings per leg
- `notes.md` — judgement text, blocker, and what the legs need to become judgeable
- `probe557.mjs` — the driver that reproduces this run
