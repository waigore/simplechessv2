# Manifest — #557 crash, reload, and faulted-session durability

- **Issue**: #557 — Exercise crash, reload, and faulted-session durability of Player Elo and Last mode
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: published release build `https://waigore.github.io/simplechessv2/` at commit `a68640a604aba249b93a1e61db44af7f28c3b5e0`, deployed by the `Web release` workflow on 2026-10-23T22:44:44Z. No `TEL.3` session id is reported: `TEL.3` lives on `CMP-playtest-seams` (`game/playtest_seams.gd:229`), which `main_release.tscn` does not carry (ADR-0004 `G2`), so a release export has no session id and none is invented here.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. Device and browser for the record: macOS/arm64 desktop, Google Chrome 156.0.8078.47 (`puppeteer-core` 23, headless, `--enable-unsafe-swiftshader`), viewport 390×844 CSS px at DPR 2. Each leg is one cold open with a fixed 30 s settle window; the reproduce counts below are separate cold opens, not timing samples.
- **Coverage mode**: `critical-only`, scoped to the three legs this issue names (quit/reload, crash, faulted session).
- **Cited design/UX protocol**: none in scope. This is a `quality.md` durability check, not a design or UX protocol, so there are no story rows and no protocol verdict — the rows below are the three legs plus the two quality claims they support.

## Results

| Row | Claim | Outcome | Basis |
|---|---|---|---|
| Leg 1 — quit/reload | A `SEQ-puzzle-result-commit` S1–S4 commit survives close-and-reopen; mode pick shows the committed Player Elo and Last mode | `not-judged` | `puzzle-play` never opened, so no result commit ran and there is no R2 Elo to read before the close |
| Leg 2 — crash | Mid-session uncommitted Last-mode selection is dropped; reopen shows the last committed Elo and Last mode | `not-judged` | mode pick never rendered, so no uncommitted selection could be made or abandoned before the kill |
| Leg 3 — faulted session | Forced failed write through the devtools `localStorage.setItem` wrapper leaves the prior document intact (`CTR-persist-document` `G2`, `I2`) and shows `EX.save-failure`; reopen shows the committed values | `not-judged` | no commit was attempted on the build, so the wrapper received no write and the save-failure surface was never reached |
| Quality — Reliability (recovery half) | "After a failure, next open is mode pick with the last committed Player Elo and Last mode" | `not-judged` | all three legs are `not-judged`; a leg that never reached mode pick cannot support a pass |
| Quality — Save durability | "Committed Player Elo and Last mode survive quit, crash, and reload; a failed write leaves the previous commit intact" | `not-judged` | no commit path was reachable, so survival and prior-commit integrity are both unobserved |

**Why every row is `not-judged` and not `fail`**: the build under test never gets past `EX.loading`. `game/presentation.gd` shows that label only from `_show_loading()` and hides it at `:364`, which runs once mode pick becomes ready; when a boot group preload fails, `game/asset_resolver.gd` returns without emitting `boot_ready`, so mode pick is never entered and `EX.loading` stays on screen. That is a screen-wide defect outside this task's scope (below), not a durability behavior that ran and misbehaved. Per `specs/playtest/evidence.md`, `not-judged` "never counts as `pass`" and never stands in for one.

## What each leg recorded

Every leg read the document with `localStorage.getItem("simplechessv2.persist.v1")` (`PersistStore.STORAGE_KEY`) and the screen by screenshot. Values are verbatim.

| Leg | Document before | Document after reopen | Mode pick reached | Screenshots |
|---|---|---|---|---|
| 1 — quit/reload | `null (absent)` | `null (absent)` | no | `leg-1-before-close.png`, `leg-1-after-reopen.png` |
| 2 — crash (CDP `Page.crash`) | `null (absent)` | `null (absent)` | no | `leg-2-after-reopen.png` |
| 3 — faulted session | `null (absent)` prior, `null (absent)` after the wrapped fault | `null (absent)` | no | `leg-3-forced-failure.png`, `leg-3-after-reopen.png` |

- **No R2 Elo on screen** in any leg: `playerElo` renders only inside the `puzzle-play` R2 region (`game/puzzle_play_panel.gd:179`), which this build never opens.
- **No Last-mode affordance** in any leg: `FL-mode-pick.N1` is drawn by `game/mode_pick_panel.gd` (`_is_last_shared()` / `_is_last_puzzle()`), which this build never renders.
- **Leg 3's wrapper was exercised as far as the build allows**: `Storage.prototype.setItem` was replaced for `simplechessv2.persist.v1` to throw, the prior document was read, no write reached it, and the wrapper was restored before the reopen. The `G2` / `I2` comparison could not be made because no commit was attempted.

## Build observations

- Cold open, 30 s settle (`logs/leg-0-driver.log`): WebGL context and Godot banner present; `ERROR: Preload boot left 9 approved IDs unresolved`; screen still reading "Loading…" (`screenshots/leg-0-cold-open-390x844.png`).
- `localStorage` holds **no key at all** after 30 s (`logs/leg-0-mechanism.log`: `localStorage keys: []`, `setItem calls after 30 s open: []`). The release export therefore never writes a persistence document on this build, which is why every leg starts and ends with an absent document rather than a default one.
- The published `index.pck` is **252 080 bytes**. It carries the catalog's asset *paths* as manifest text (11 `.svg`, 5 `.woff2` strings) but no asset bytes, and `GET game_assets/icons/quit.svg` answers **404** (`logs/leg-0-driver.log`).
- No DOM surface exposes the engine: `Engine` and `JavaScriptBridge` are undefined in page scope, so a leg cannot be driven past the canvas by script. That is a property of the release export, not a finding.

## Reproduce

Three cold opens of the published URL, 30 s settle each, in Chrome with a viewport of 390×844 @ DPR 2:

1. Open the URL; read `localStorage.getItem("simplechessv2.persist.v1")` → expected default document. **Observed `null`.**
2. Screenshot the screen → expected mode pick. **Observed `Loading…`.**
3. Confirm a panel is reachable: `fetch('game_assets/icons/quit.svg')` → expected 200. **Observed 404.**

The three legs each stop at step 2: no mode pick means no puzzle result, no commit, no reopen comparison.

## Paths

- `manifest.md` (this file), `notes.md`, `setup.md` (driver commands and flags)
- `screenshots/leg-0-cold-open-390x844.png` — cold open stuck on `Loading…`
- `screenshots/leg-1-before-close.png`, `screenshots/leg-1-after-reopen.png` — quit/reload leg
- `screenshots/leg-2-after-reopen.png` — crash leg reopen
- `screenshots/leg-3-forced-failure.png`, `screenshots/leg-3-after-reopen.png` — faulted-session leg
- `logs/leg-0-driver.log` — cold open, console and network, 30 s window
- `logs/leg-0-mechanism.log` — `Storage.prototype.setItem` call trace and `localStorage` key set
- `logs/legs-1-3.driver.log` — per-leg document reads, stop reasons, results, and the full driver transcript for the three legs

## Defects

- **#630** — "Shipped release never leaves the loading screen: `game_assets/` is not in the Web export". This is the sole cause of all five `not-judged` rows: it is why no level is reachable, so no durability value can be committed or observed. Already open, already native-blocking #402; not re-filed here (see `notes.md` §Defects).
- **#648** / **#479** — the `T9`/`T10` catalog-route answer and its delivery mechanism. Even with #630 fixed, the shipped path sets neither value (`game/session_router.gd:33-34`), so `CatalogDealClient.is_available()` is false and no puzzle is dealt, so no result commit exists. This is the second, independent reason the three legs cannot pass on the shipped build. Consulted, not re-filed (measured once as #655).
