# Acceptance run — issue #63 (headless + graphical)

Environment: **Graphical (native macOS window, Metal) + headless**, Godot
`4.7.2.stable.official.ed1daf0bf`.
Build: `origin/main` at `28c4d9f`; `demos/shared-game/` as shipped by PR #624 (the
`PER.R7` rework), coordinate bands outside the 8x8.
Method: unattended `issue-workflow-accept-agent` run (parallel id 1, `Assigned issue: none`)
running `accept-project-issue` on this issue.

`docs/demos.md` makes playtesting optional for demos, so no playtest protocol is cited (as
in the earlier #63 acceptance runs); the acceptance criteria are the test units. The
graphical run supplies the screenshots.

## What was run

| Step | Command | Log |
|------|---------|-----|
| Import | `godot --headless --path demos/shared-game --import --quit` → exit 0 | [logs/import.log](logs/import.log) |
| Headless autodrive | `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` → `[demo] PASS` | [logs/autodrive.log](logs/autodrive.log) |
| Graphical autodrive | `DEMO_SHOT_DIR=… DEMO_AUTODRIVE=1 godot --path demos/shared-game --resolution 720x1280 --rendering-driver metal` → `[demo] PASS`, screenshots written, rendered-ink check clean | [logs/graphical-autodrive.log](logs/graphical-autodrive.log) |
| Labels-off frame | `PROBE_OUT=… godot --path demos/shared-game --script make_nolabels_probe.gd --resolution 720x1280 --rendering-driver metal` | [make_nolabels_probe.gd](make_nolabels_probe.gd), [logs/nolabels-probe.log](logs/nolabels-probe.log) |
| Coordinate ink from pixels | `python3 measure_independent.py screenshots/demo-shared-game-exercise.png screenshots/nolabels.png` | [logs/independent-measure.log](logs/independent-measure.log) |
| Spec IDs cited by the README | `python3 check_spec_ids.py` | [logs/spec-ids.log](logs/spec-ids.log) |
| Catalog entries and files | all 20 `assets.json` IDs resolved in `asset_catalog/`; every file present under `game_assets/` / `audio_runtime/` | [logs/assets.json](logs/assets.json) |

## Outcome

**Accept.** Every acceptance criterion passes; the per-criterion evidence is in
[criteria.md](criteria.md). No defect filed.

Non-blocking notes:

1. The implementing run's checked-in logs in `rework-20261024T000000Z/` remain stale against
   the shipped build (finding 1 of the earlier verification run); worth regenerating when
   the demo next changes. No effect on the build.
2. `check_coord_probe.py`'s dump boxes reuse `CoordLabels.text_rect`, the same wrapper that
   places the ink, so it is a dump checker, not an independent guard; the graphical
   `coord_ink_problems()` pixel path is the guard. Wording only.

The `PER.R7` pixel measurement is separate: [coordinate-labels.md](coordinate-labels.md).
