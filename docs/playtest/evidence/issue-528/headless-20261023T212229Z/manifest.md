# Evidence manifest — issue #528 (headless run)

| Field | Value |
|-------|-------|
| Issue | #528 (defect, epic #35 / Wave 2 — Adaptive Puzzle stream) |
| Environment | headless `ENV.1` — Godot `4.7.2.stable.official.ed1daf0bf`, macOS arm64 |
| Build | `origin/main` `614746c` (worktree `1`, branch `main`, no local code changes) |
| Coverage mode | `full`, intersected with this defect's playable deliverables: `PTD-puzzle-stream` (Design, headless). `PTD-difficulty` is `n/a` — `DIF.Y1` runs on the service (#329), and neither the client nor the session selects from a downloaded set. UX protocols `PTU-puzzle-session` / `PTU-puzzle-play` were scheduled because the read sits on the puzzle-play journey and its leave path; their headless half is here and their graphical half is the twin run. |
| Peer | `FakeCatalogTransport` — the ADR-0013 Testability stand-in the seam build installs; no network, no Stockfish, no key on the wire. The shipped seam peer never answers, which is this run's "unresponsive catalog" case. |
| Screenshots | None — Design protocol requires none; the UX halves' screenshots are in `../graphical-20261023T212229Z/screenshots/`. |
| Defects | None — no cited story failed. Two observations recorded for other owners (see `notes.md`). |

## Results

Protocol verdicts and stories: [`results.md`](results.md). Issue acceptance criteria:
[`acceptance.md`](acceptance.md). Checks run: [`checks.md`](checks.md).

| Protocol | Verdict |
|----------|---------|
| `PTD-puzzle-stream` | pass (headless) |
| `PTU-puzzle-session` | headless half pass; graphical half in `../graphical-20261023T212229Z/` |
| `PTU-puzzle-play` | headless half pass; graphical half in `../graphical-20261023T212229Z/` |

## Paths

- [`results.md`](results.md), [`acceptance.md`](acceptance.md), [`checks.md`](checks.md)
- [`notes.md`](notes.md)
- `logs/drive.gd` — the drive (same file as the graphical twin's `logs/drive.gd`)
- `logs/drive-headless.log`
- `logs/real-socket-retire.gd`, `logs/real-socket-retire.log`
- `logs/retire-without-reaper.gd`, `logs/retire-without-reaper.log`
- `logs/baseline-30-frames.gd`, `logs/baseline-30-frames*.log`
- `logs/no-catalog-bytes.log`
- `logs/import.*`, `logs/unit-tests.*`, `logs/coverage.*`, `logs/gdformat.*`, `logs/gdlint.*`, `logs/spec-lint.*`, `logs/headless-smoke.*`