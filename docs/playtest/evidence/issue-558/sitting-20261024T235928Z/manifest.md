# Manifest — #558 sitting soak and the Advice-Off / offline observation

- **Issue**: #558 (`type:task`, epic #37). Feeds #402's **Reliability — sitting soak** row and
  ADR-0002's Every-release advice row.
- **Build**: local **`Web Release`** export of `origin/main` `c4202bb`
  (*Record the #626 phone reading…*, 2026-10-25), `python3 .github/scripts/web_export.py --preset
  "Web Release"`, served at `http://127.0.0.1:8765/`. The published URL served `c5b8189`, which
  predates #793's `advice_off` focus paint (the Off label did not render) and carries #845/#856;
  #558's Deliverables allow the local release export until the commit is published.
- **Environment**: `ENV.2` — macOS 27.0.1 / arm64; headless Chrome over CDP, 390×844 CSS,
  DPR 2, touch, `--use-angle=swiftshader`.
- **Coverage**: one continuous sitting, all four legs of the task. Not a playtest protocol run.
- **Sitting window**: start **2026-10-25T00:09:57.886Z**, end **2026-10-25T00:25:19.411Z**,
  **921.5 s = 15 min 22 s** (`logs/sitting.log`, `sitting.start` / `sitting.end`). Inside the
  quality row's 15–40 min window. Five idle bands were saved.
- **Crash / forced exit**: none. 26 heartbeats, all `alive:true`
  (`01-mode-pick-idle`, `08-game-over-idle`, `11-puzzle-idle`, `20-reopen-idle`,
  `34-offline-idle`, `38-sitting`). `logs/browser-events.log` holds protocol events only; no
  renderer crash, no `error` row in `logs/sitting.log`. The one browser relaunch is the
  *deliberate* quit-and-reopen leg, not a failure.

## Screen sequence

| Wall clock (Z) | Screen / event |
|---|---|
| 00:09:58 | cold open → mode pick |
| 00:10:44 | mode pick → Shared setup |
| 00:10:48 | Advice toggled **Off** (`advice_off` copy) → Start |
| 00:10:57–00:11:18 | Shared play: `1. f3 e5 2. g4 Qh4#` (fool's mate), one move with Advice Off |
| 00:11:21 | game over — "Game over / Black wins / Shared game" |
| 00:12:52 | Stop → mode pick |
| 00:12:56 | Puzzle stream → dealt puzzle, one move attempted |
| 00:14:09 | Leave stream → confirm → mode pick |
| 00:14:15–00:14:35 | **quit and reopen** (browser relaunch, same profile) → mode pick |
| 00:16:36 | build set **offline** (`Network.emulateNetworkConditions`) |
| 00:16:40 | Shared setup, Advice **On** → Start |
| 00:16:47–00:17:00 | Shared play `1. e4 e5` with Advice On and the build offline |
| 00:18–00:19 | offline idle band |
| 00:19:02 | Resign → confirm → "Game over / Black wins" |
| 00:19:12 | Stop → mode pick |
| 00:25:19 | end of sitting (idle on mode pick) |

## Results

| Claim | Method | Verdict |
|---|---|---|
| Reliability — sitting soak (`quality.md`) | 15–40 min continuous sitting, driven through the shipped screens | **pass** — 15:22, no crash, no forced exit; quit-and-reopen inside the sitting |
| `F-move-advice.R2` / `R9` — Advice Off renders no marks | `advice_off` copy, a move played, `GS.adviceBestMove` / `GS.adviceEval` read | **pass** — see [notes.md](notes.md#advice-off) |
| `F-move-advice.R2` / `R9` — offline and On, no backend | build offline, Advice On, two moves played | **pass** — no evaluation, no marks, no S3 error |
| Reopen inside the sitting | relaunch, compare stored document | **pass** — mode pick; stored value identical (`last_mode` `puzzle`, `player_elo` `1000.0`) |

**Story rows**: `F-move-advice.R2`, `F-move-advice.R9` — `pass` each.
**Protocol verdict**: not applicable — this is a quality-row and ADR-row observation, not a
playtest protocol. No `TEL.*` row is claimed: the release build emits no telemetry by
specification, so `TEL.1`–`TEL.5` are `none` for this run, not `not-judged`.

## Paths

- [notes.md](notes.md) — judgement text, method, the `DBG.2` limitation, method limits
- [readings.md](readings.md) — timed values and the read field values
- `logs/sitting.log` — JSONL: sitting start/end, phases, taps, heartbeats, advice reads
- `logs/browser-events.log` — CDP protocol events for the sitting
- `logs/probe_release_state.gd`, `logs/probe-release-state.log` — release-graph probe that reads
  the advice fields `DBG.2` would return (26 checks, 0 failures)
- `screenshots/sitting-*` — 57 images; the judged states are
  `sitting-02-advice-off-setup`, `sitting-06-g4-after` (Advice Off, after a move),
  `sitting-08-game-over`, `sitting-10-puzzle-open`, `sitting-reopen-20-reopen-mode-pick`,
  `sitting-reopen-33-offline-after-wait` (offline and On, after a move),
  `sitting-reopen-36-result-after-resign`, `sitting-reopen-39-final-mode-pick`
- Drivers: `sitting.mjs`, `ui.mjs`, `drive.mjs`, `pnglib.mjs`

## Defects

None. Both legs and the soak passed, so no `type:defect` is filed against a
[`quality-regression-owners.md`](../../../../specs/definition/quality-regression-owners.md) owner.

Rows this run does **not** judge, left to their owners: `SND.L1`–`L2` ambient bed (#567, absent
from the build's second bed at the time of the sitting), Load time, Performance, and every other
`quality.md` row.
