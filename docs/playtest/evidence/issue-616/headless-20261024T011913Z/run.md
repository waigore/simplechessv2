# Run — issue #616, acceptance run (headless)

Index: [`manifest.md`](manifest.md) · Notes: [`notes.md`](notes.md)

## What was run

`probe_616_acceptance.gd` instantiates `res://main.tscn`, drops the `PlaytestHarness`, and drives the six panels open **through `SessionRouter` controls** (C1, C2, C5, C4, cancel, confirm, and one failed puzzle commit with `force_write_failure`) at 1280×720, 1600×900 and 390×844. It records `get_global_rect()` of each panel and of its parent, and counts the panel's descendant controls whose drawn rect leaves the frame.

`mutant_616.gd` reinstates the filed defect on one screen panel (`ModePick`, parent `ScreenHost`) and one dialog (`ResignConfirm`, parent `SharedPlayPanel`) to confirm AC4 is a real constraint, not an artefact of the probe.

## Geometry

| Frame | `ModePick` | `SharedSetup` | `SharedResult` | `ResignConfirm` | `StreamConfirm` | `SaveFailure` |
|---|---|---|---|---|---|---|
| 1280×720 | x 480, top 80 | x 480, top 60 | x 480, top 120 | x 500, top 200 | x 500, top 220 | x 500, top 220 |
| 1600×900 | x 640, top 80 | x 640, top 60 | x 640, top 120 | x 650, top 200 | x 660, top 220 | x 660, top 220 |
| 390×844 | x 35, top 80 | x 35, top 60 | x 35, top 120 | x 52.5, top 200 | x 55, top 220 | x 55, top 220 |

`centre_dx` is 0.0 and the top deltas 0.0 for every row, so AC1–AC3 hold. At 390×844 the shipped copy leaves every panel inside the 390 px frame (`ModePick` 35–355) and no descendant control of any judged panel draws outside the frame (checked on all three frames).

Mutant: `MEASURE ModePick rect=[P: (40.0, 80.0)] dx=440.0`, `MEASURE ResignConfirm rect=[P: (40.0, 200.0)] dx=460.0`. Re-imposing the old pattern still produces the filed symptom, so the shipped placement (not the probe) is what makes AC1–AC3 hold.

## Guard and lint

Guard (AC5): with `place_centered` short-circuited to `PRESET_TOP_LEFT` + `position = (40, top)` for `ModePick`, the suite fails on `ModePick drawn centre x off by 440.0 px at (1280.0, 720.0)` and the file was restored (`git status --porcelain` empty afterwards).

`Code lint` was not run by this session: `gdformat`/`gdlint` are not installed on this machine and the install was outside the run's scope. AC7 was judged from the merged PR file lists (code files only, no `specs/` file, no layout, content or node-name change); CI lint status on the merged PRs was not re-read here.
