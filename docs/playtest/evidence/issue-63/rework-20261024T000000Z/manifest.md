# Evidence manifest — #63 rework (`PER.R7` coordinates)

| Field | Value |
|-------|-------|
| Issue | #63 (task, parent epic #34) |
| Phase | Implementation rework (verify Fail on `PER.R7`) |
| Environment | headless, Godot `4.7.2.stable.official.ed1daf0bf`, macOS arm64 |
| Base | `origin/main` `16e197b` |
| Folder | `docs/playtest/evidence/issue-63/rework-20261024T000000Z/` |

## Files

| Path | What it is |
|------|------------|
| `notes.md` | What failed and the three root causes |
| `rework.md` | What changed, measured result, guard self-tests |
| `findings.md` | Pipeline findings |
| `check_coord_probe.py` | PER.R7 checker for the headless drawing dump |
| `logs/import.log` | `--import --quit` on the reworked demo |
| `logs/autodrive.log` | `DEMO_AUTODRIVE=1` headless run (`[demo] PASS`) |
| `logs/autodrive-probe.log` | Same with `DEMO_COORD_PROBE=1` |
| `logs/coord-probe.txt` | Drawing dump: 16 label ink boxes + both bands, frame px |
| `logs/coord-probe-check.log` | Checker output — `PASS` |
| `logs/autodrive-probe-before.log` | Same run with the old left-band geometry — exit 1 |
| `logs/coord-probe-before.txt`, `logs/coord-probe-check-before.log` | Dump and checker for the old geometry — 8 rank failures |

No screenshots: this host cannot open a Godot window (see F1 in `notes.md`).
