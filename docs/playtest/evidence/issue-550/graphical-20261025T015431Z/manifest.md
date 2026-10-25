# Manifest — #550 wave-2 sweep, graphical run

- **Issue**: #550 (Wave 2 — Adaptive Puzzle stream)
- **Environment**: `graphical` (`ENV.2`)
- **Build / session id**: `26b07af` (`origin/main`, 2026-10-25), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2.stable.official.ed1daf0bf`; `TEL.3` session `sess-1792893281479-94581-playtest-643849`
- **Build source**: the `26b07af` tree run in-process from a detached worktree (`godot --path game`) — the [`procedures.md`](../../../../../specs/playtest/procedures.md) fallback, not a published reading: ADR-0009 publishes the seam-free `Web Release` only, and this sweep needs `DBG.*` / `TEL.*`. Both folders name the same commit.
- **Timing (`SIT.4` runs)**: not a `SIT.4` run — no timing row is judged here; the one `SIT.6` step (`PTU-mode-pick` S6) reads text size, not frame time.
- **Coverage mode**: `full`, intersected with #550's scope: the 7 UX protocols. Design protocols are headless only; the 7 UX protocols run in both environments. No view story is in the set.
- **Story-row source**: [`protocols-design.md`](../../../../../specs/playtest/traceability/story-protocol/protocols-design.md) and [`protocols-ux.md`](../../../../../specs/playtest/traceability/story-protocol/protocols-ux.md) at `26b07af`; no row re-derived from a protocol's `Cites` line. **18 rows**: 18 UX.
- **`PTU-localization` `Cites` line**, verbatim from `specs/playtest/ux/localization.md` at `26b07af`: **Cites**: `UI-mode-pick.US1`, `LOC.US1`.
- **Screenshots**: [`screenshots/`](screenshots/) — 36 images, each named in [`shots.md`](shots.md).
- **Driver**: [`logs/w550_sweep.gd`](logs/w550_sweep.gd) — kept with the run so the readings can be reproduced. It is the #400 sweep driver (`logs/w400_sweep.gd`), with the wave-2 changes [`driver-notes.md`](driver-notes.md) lists.
- **Defects**: none filed — no story row failed. The shipped-path deal is #655 / #892's, not this run's finding.

## Results

**18 rows** — 14 pass, 0 fail, 4 not-judged. **7 protocols** — 4 pass, 0 fail, 3 not-judged. A protocol is `pass` only when every cited story passes, `fail` if any fails, `not-judged` if any is ([`evidence.md`](../../../../../specs/playtest/evidence.md)).

## Protocol verdicts

- **Design** (headless only): not judged in this run — design protocols are headless (`playtest.md` §Levels); the headless folder records their eight verdicts.
- **UX**: 4 pass, 3 not-judged, 0 fail — pass: `PTU-puzzle-session`, `PTU-mode-pick`, `PTU-navigation`, `PTU-controls`. Not-judged: `PTU-puzzle-play`, `PTU-exceptions`, `PTU-localization`.

## Story rows

One file per protocol in the table above, one row per story row the map lists: [`controls`](rows-controls.md), [`exceptions`](rows-exceptions.md), [`localization`](rows-localization.md), [`mode-pick`](rows-mode-pick.md), [`navigation`](rows-navigation.md), [`puzzle-play`](rows-puzzle-play.md), [`puzzle-session`](rows-puzzle-session.md).

## Paths

- [`logs/run.log`](logs/run.log), [`logs/telemetry.ndjson`](logs/telemetry.ndjson), [`logs/results.json`](logs/results.json), [`logs/static.json`](logs/static.json), [`logs/w550_sweep.gd`](logs/w550_sweep.gd)
- Notes: [`notes.md`](notes.md); driver: [`driver-notes.md`](driver-notes.md)
- Protocol verdicts, the `not-judged` rows with their reasons, and row-level `none`: [`protocol-verdicts.md`](protocol-verdicts.md)
- Screenshots: [`screenshots/`](screenshots/) — 36 images, each named in [`shots.md`](shots.md).
