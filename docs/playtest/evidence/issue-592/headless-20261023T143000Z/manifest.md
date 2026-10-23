# Manifest — defect #592 evidence

- **Issue**: #592 (coordinate labels paint inside the 8×8 and half below 4.5:1)
- **Build**: `main` `abc6469` (before) and this PR's branch (after)
- **Engine**: Godot 4.7.2 stable, headless + `xvfb-run -a` graphical at 720×1280
- **Commands**
  - `godot --headless --path demos/shared-game --import --quit`
  - `DEMO_AUTODRIVE=1 godot --headless --path demos/shared-game` → `logs/autodrive.log`
  - `DEMO_SHOT_DIR=<dir> DEMO_AUTODRIVE=1 xvfb-run -a godot --path demos/shared-game --resolution 720x1280`
  - `python3 measure_labels.py <before.png> <after.png>` → `logs/coord-label-measure.log`
- **Files**
  - `logs/autodrive.log` — headless autodrive, `[demo] PASS`, per-label ink boxes
  - `logs/coord-label-measure.log` — pixel measurement, before vs after
  - `screenshots/before-main-exercise.png` — 0..720 × 840..960 crop of `main`'s exercise frame
  - `screenshots/after-exercise.png` — the same crop after the fix
  - `screenshots/after-mate.png` — the mate frame after the fix (same crop)
  - `measure_labels.py` — the measurement script
  - `notes.md` — findings and the table
