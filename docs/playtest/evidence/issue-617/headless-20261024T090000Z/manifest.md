# Manifest — issue #617, acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #617 — Shared-play piece sprites upside down (world Y-flip; demo upright) |
| Environment | `ENV.1` headless (`godot --headless`, no display) |
| Build / session id | `origin/main` `3f81b59`, Godot `4.7.2.stable.official.ed1daf0bf`; probe session `probe-617-1792798784` |
| Coverage mode | `full`, intersected with the issue's playable scope |
| Protocol in scope | `PTU-shared-play` (UX) — story perception only |
| Screenshots | waiting on the graphical run of this same build (`../graphical-<run-id>/screenshots/`) |

## Results

| Protocol / unit | Cited spec elements | Outcome |
|-----------------|---------------------|---------|
| Out-of-scope probe: seat-space sprite basis (global determinant, `rot` 0/PI per seat) | `CAM-board.M2` | pass |
| Out-of-scope probe: piece art reads upright on screen, both seats | `SPC.E1`, `SPC.A1` | **fail** — the acceptance subject of #617 |
| Out-of-scope probe: catalogued art itself is stored upright | `SPC.E1` | **fail** — knights only |
| `PTU-shared-play` S1/S2 — seat operation on its turn | `ACT-bottom-player.US1`, `ACT-top-player.US1` | not-judged (no driven session in this run) |
| `PTU-shared-play` S3/S4 — advice toggle, resign confirm, coordinates | `UI-shared-play.US1` | not-judged |
| `PTU-shared-play` P1 (both seats operate on their turn) | `UI-shared-play.US1`, `ACT-bottom-player.US1`, `ACT-top-player.US1` | not-judged (needs a driven session; this run only reached the presentation) |
| `PTU-shared-play` P2 (headless **and** graphical) | `UI-shared-play.US2` | not-judged (no graphical run yet) |
| `PTU-shared-play` P3 (60 fps, no hitch) | `SIT.4` | not-judged (headless cannot time frames; needs the graphical run) |
| `PTU-shared-play` P4 (`TEL.1`–`TEL.5` correlate) | `SIT.5` | **pass** — seam emitted and read back all five fields for both judged stories |
| Protocol verdict `PTU-shared-play` | — | **not-judged** in this environment |

Defects: none filed from this run. The defect this run measures is #617 itself; the acceptance
outcome waits on the graphical run (see `notes.md`).

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Limits and non-blocking marks | `limits-and-marks.md` |
| Probe script | `probe_art_orientation.gd` |
| Probe log (judged window) | `logs/art-orientation.log` |
| Probe stdout (engine noise, warnings) | `logs/probe-stdout.log` |
