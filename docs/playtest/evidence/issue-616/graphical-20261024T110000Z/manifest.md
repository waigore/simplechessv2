# Manifest — issue #616, acceptance run (graphical)

Index for this run. What was run and the geometry: [`run.md`](run.md). Rendering reading and checks:
[`readings-and-checks.md`](readings-and-checks.md). Protocol rows: [`protocols.md`](protocols.md).
Judgement text: [`notes.md`](notes.md), with [`scope.md`](scope.md) and [`marks.md`](marks.md).
Artifact paths: [`paths.md`](paths.md). The superseded first drive: [`first-attempt.md`](first-attempt.md).
The headless half of this acceptance is
[`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md).

- **Issue**: #616 — Chrome panels at a fixed corner offset instead of centered
- **Environment**: `ENV.2` graphical (`DisplayServer` = `macOS`, Metal, Godot `4.7.2.stable.official.ed1daf0bf`)
- **Build / session id**: local playtest tree at `origin/main` `4aa6aba`, the shipped `game/main.tscn` in a
  rendered session; not a published build. Source and why: [`run.md`](run.md) *Build under test*. Run id
  `graphical-20261024T110000Z`; no `TEL.3` id (not a web build).
- **Timing (`SIT.4` runs)**: not a `SIT.4` run. `PTU-shared-play` / `PTU-puzzle-play` are out of scope
  ([`scope.md`](scope.md)); the frame-loop reading is a liveness check, not a timing claim.
- **Coverage mode**: `full`, within the issue's playable scope
- **Protocols in scope**: `PTU-mode-pick` (S6 graphical), `PTU-shared-setup`, `PTU-shared-result`,
  `PTU-exceptions` (S3), plus the `#616` criteria
- **Screenshots**: `screenshots/` — 19 PNG files listed in [`paths.md`](paths.md)

## Results

| Protocol / unit | Cited | Outcome |
|-----------------|-------|---------|
| AC1 — six panels centered at 1280×720 | issue AC1 | pass — `centre_dx=0.0` on all six, rendered |
| AC2 — vertical tops unchanged | issue AC2 | pass — 80 / 60 / 120 / 200 / 220 / 220 exact at 1280×720 and 1600×900 |
| AC3 — holds at another frame size | issue AC3 | pass — 1600×900 and the `SIT.6` 390×844 frame, `centre_dx=0.0` on all six |
| AC4 — one placement model | issue AC4 | pass — judged on code in [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md); this run shows the drawn result only |
| AC5 — guard runs and fails a fixed x | issue AC5 | pass — `python3 .github/scripts/gdscript_tests.py test` → 26/26, exit 0 |
| AC6 — `Code lint`, `Unit tests`, `Coverage` green | issue AC6 | pass — `gdlint` no problems, `gdformat --check` 59 unchanged, coverage 86.4% (4500/5211, threshold 80) |
| AC7 — no spec, layout, content or node-name change | issue AC7 | pass — this run changed no file under `game/`; the judged build's fix PRs are the ones headless AC7 already names |

Protocol verdicts: `PTU-mode-pick` **not-judged** (P3, P4 unrun) · `PTU-shared-setup` **pass** ·
`PTU-shared-result` **pass** · `PTU-exceptions` **not-judged** (S1, S2 unrun). Every row, with its cited
story: [`protocols.md`](protocols.md).

Defects: none filed. Every `#616` criterion passes on this build; the remaining `not-judged` rows are
protocol rows no `#616` deliverable reaches, not failures.
