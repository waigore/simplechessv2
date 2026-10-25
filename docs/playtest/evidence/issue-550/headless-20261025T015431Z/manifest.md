# Manifest — #550 wave-2 sweep, headless run

- **Issue**: #550 (Wave 2 — Adaptive Puzzle stream)
- **Environment**: `headless` (`ENV.1`)
- **Build / session id**: `26b07af` (`origin/main`, 2026-10-25), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792893272248-94361-playtest-807719`
- **Build source**: the `26b07af` tree run in-process from a detached worktree (`godot --headless --path game`) — the [`procedures.md`](../../../../../specs/playtest/procedures.md) fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release` only, and this sweep needs `DBG.*` / `TEL.*`. Both folders name the same commit.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here; the one `SIT.6` step (`PTU-mode-pick` S6) reads text size, not frame time.
- **Coverage mode**: `full`, intersected with #550's scope: 8 design + 7 UX protocols. Design protocols are headless only; the 7 UX protocols run in both environments. No view story is in the set.
- **Story-row source**: [`protocols-design.md`](../../../../../specs/playtest/traceability/story-protocol/protocols-design.md) and [`protocols-ux.md`](../../../../../specs/playtest/traceability/story-protocol/protocols-ux.md) at `26b07af`; no row re-derived from a protocol's `Cites` line. **44 rows**: 26 design + 18 UX.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md` at `26b07af`: **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: none — headless run; every screenshot path is waiting on [`../graphical-20261025T015431Z/screenshots/`](../graphical-20261025T015431Z/screenshots/), the same build.
- **Driver**: [`logs/w550_sweep.gd`](logs/w550_sweep.gd) — kept with the run so the readings can be reproduced. It is the #400 sweep driver (`logs/w400_sweep.gd`), with the wave-2 changes the [graphical run's `driver-notes.md`](../graphical-20261025T015431Z/driver-notes.md) lists; both folders ship the same driver.
- **Defects**: none filed — no story row failed. The shipped-path deal is #655 / #892's, not this run's finding.

## Results

**44 rows** — 35 pass, 0 fail, 9 not-judged. **15 protocols** — 7 pass, 0 fail, 8 not-judged. A protocol is `pass` only when every cited story passes, `fail` if any fails, `not-judged` if any is ([`evidence.md`](../../../../../specs/playtest/evidence.md)).

## Protocol verdicts

- **Design**: 4 pass, 4 not-judged, 0 fail — pass: `PTD-puzzle-stream`, `PTD-difficulty`, `PTD-progression`, `PTD-game-state`. Not-judged: `PTD-pieces-common`, `PTD-pieces-king`, `PTD-pieces-officers`, `PTD-pieces-pawn`.
- **UX**: 3 pass, 4 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`. Not-judged: `PTU-puzzle-play`, `PTU-controls`, `PTU-exceptions`, `PTU-localization`.

## Story rows

One file per protocol in the table above, one row per story row the map lists: [`controls`](rows-controls.md), [`difficulty`](rows-difficulty.md), [`exceptions`](rows-exceptions.md), [`game-state`](rows-game-state.md), [`localization`](rows-localization.md), [`mode-pick`](rows-mode-pick.md), [`navigation`](rows-navigation.md), [`pieces-common`](rows-pieces-common.md), [`pieces-king`](rows-pieces-king.md), [`pieces-officers`](rows-pieces-officers.md), [`pieces-pawn`](rows-pieces-pawn.md), [`progression`](rows-progression.md), [`puzzle-play`](rows-puzzle-play.md), [`puzzle-session`](rows-puzzle-session.md), [`puzzle-stream`](rows-puzzle-stream.md).

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json), [`logs/w550_sweep.gd`](logs/w550_sweep.gd)
- Notes: [`notes.md`](notes.md); AC readings: [`ac-readings.md`](ac-readings.md)
- Protocol verdicts, the `not-judged` rows with their reasons, and row-level `none`: [`protocol-verdicts.md`](protocol-verdicts.md)
- The [graphical run](../graphical-20261025T015431Z/manifest.md) records the other environment of this sweep.
