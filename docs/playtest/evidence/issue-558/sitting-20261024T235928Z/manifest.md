# Manifest — #558 sitting soak and the Advice-Off / offline observation

- **Issue**: #558 (`type:task`, epic #37). Feeds #402's **Reliability — sitting soak** row and
  ADR-0002's Every-release advice row.
- **Build**: local **`Web Release`** export of `origin/main` `c4202bb` (*Record the #626 phone
  reading…*), `python3 .github/scripts/web_export.py --preset "Web Release"`, served at
  `http://127.0.0.1:8765/`. The published URL served `c5b8189`, which predates #793's `advice_off`
  focus paint and carries #845/#856; #558's Deliverables allow the local release export.
- **Environment**: `ENV.2` — macOS 27.0.1 / arm64; headless Chrome over CDP, 390×844 CSS,
  DPR 2, touch, `--use-angle=swiftshader`.
- **Sitting window**: start **2026-10-25T00:09:57.886Z**, end **2026-10-25T00:25:19.411Z**,
  **921.5 s = 15 min 22 s**. Inside the quality row's 15–40 min window. Five idle bands saved.
- **Crash / forced exit**: none. 26 heartbeats, all `alive:true`; no error row in
  `logs/sitting.log`. The one browser relaunch is the deliberate quit-and-reopen leg.

## Screen sequence

| Wall clock (Z) | Screen / event |
|---|---|
| 00:09:58 | cold open → mode pick |
| 00:10:44 | mode pick → Shared setup |
| 00:10:48 | Advice toggled **Off** (`advice_off` copy) → Start |
| 00:10:57–00:11:18 | Shared play: `1. f3 e5 2. g4 Qh4#` (fool's mate) |
| 00:11:21 | game over — "Game over / Black wins / Shared game" |
| 00:12:52 | Stop → mode pick |
| 00:12:56 | Puzzle stream → dealt puzzle, one move attempted |
| 00:14:09 | Leave stream → confirm → mode pick |
| 00:14:15–00:14:35 | **quit and reopen** (relaunch, same profile) → mode pick |
| 00:16:36 | build set **offline** |
| 00:16:40 | Shared setup, Advice **On** → Start |
| 00:16:47–00:17:00 | Shared play `1. e4 e5`, Advice On, build offline |
| 00:19:02 | Resign → confirm → "Game over / Black wins" |
| 00:19:12 | Stop → mode pick |
| 00:25:19 | end of sitting (idle on mode pick) |

## Results

| Claim | Verdict |
|---|---|
| Reliability — sitting soak (`quality.md`) | **pass** — 15:22, no crash, no forced exit |
| `F-move-advice.R2` / `R9` — Advice Off renders no marks | **pass** |
| `F-move-advice.R2` / `R9` — offline and On, no backend | **pass** |
| Reopen inside the sitting | **pass** — mode pick, stored document identical |

**Story rows**: `F-move-advice.R2`, `F-move-advice.R9` — `pass` each.
**Protocol verdict**: not applicable — a quality-row and ADR-row observation, not a playtest
protocol. No `TEL.*` row is claimed: the release emits no telemetry by specification.

Judgement text: [notes.md](notes.md). Values: [readings.md](readings.md). Method limits:
[dbf2.md](dbf2.md).

## Paths

- `logs/sitting.log` (JSONL timeline), `logs/browser-events.log` (CDP events)
- `logs/probe_release_state.gd`, `logs/probe-release-state.log` — release-graph probe, 26
  checks, 0 failures
- `screenshots/sitting-*` — 57 images; judged states: `sitting-02-advice-off-setup`,
  `sitting-06-g4-after`, `sitting-08-game-over`, `sitting-10-puzzle-open`,
  `sitting-reopen-20-reopen-mode-pick`, `sitting-reopen-33-offline-after-wait`,
  `sitting-reopen-36-result-after-resign`, `sitting-reopen-39-final-mode-pick`
- Drivers: `sitting.mjs`, `ui.mjs`, `drive.mjs`, `pnglib.mjs`

## Defects

None. Both legs and the soak passed; no `type:defect` was filed against a
[`quality-regression-owners.md`](../../../../../specs/definition/quality-regression-owners.md) owner.
