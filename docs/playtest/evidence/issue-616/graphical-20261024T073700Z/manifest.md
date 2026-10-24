# Manifest — issue #616, graphical acceptance run (re-recorded for #742)

Index for this run. What was run and the geometry: [`run.md`](run.md). Checkable claims about the
environment: [`checks.md`](checks.md); about the images: [`images.md`](images.md); build and CI:
[`build-checks.md`](build-checks.md). Protocol rows: [`protocols.md`](protocols.md).
Judgement text: [`notes.md`](notes.md). What #742 got right and what it did not: [`corrections.md`](corrections.md).

The headless half of this acceptance is [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md).
This run supersedes [`../graphical-20261024T110000Z/`](../graphical-20261024T110000Z/manifest.md) as the
folder acceptance cites for the graphical half.

| Field | Value |
|-------|-------|
| Issue | #616 — Chrome panels at a fixed corner offset instead of centered |
| Environment | `ENV.2` graphical — `DisplayServer` = `X11`, `gl_compatibility`, Mesa llvmpipe under `xvfb-run`, Godot `4.7.2.stable.official.ed1daf0bf`. Recorded from the engine in the first log line ([`checks.md`](checks.md) *Environment*) |
| Build / session id | `origin/main` `cbce7cd`, clean worktree, shipped `game/main.tscn`; not a published build. Run id `graphical-20261024T073700Z`; no `TEL.3` id (not a web build) |
| Timing (`SIT.4` runs) | Not a `SIT.4` run. `PTU-shared-play` / `PTU-puzzle-play` are out of scope; the frame-loop reading is a liveness check, not a timing claim |
| Coverage mode | `full`, within the issue's playable scope |
| Protocols in scope | `PTU-mode-pick` (S6 graphical), `PTU-shared-setup`, `PTU-shared-result`, `PTU-exceptions` (S3), plus the `#616` criteria |
| Paths | Screenshots `screenshots/` — 19 PNG files, listed in [`paths.md`](paths.md). Notes [`notes.md`](notes.md). Logs `logs/graphical-drive.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/lint.log`, `logs/format-check.log`, `logs/spec-lint.log` |

## Results

| Protocol / unit | Cited | Outcome |
|-----------------|-------|---------|
| AC1 — six panels centered at 1280×720 | issue AC1 | pass — `centre_dx=0.0` on all six, drawn rect |
| AC2 — vertical tops unchanged | issue AC2 | pass — 80 / 60 / 120 / 200 / 220 / 220 exact at 1280×720 and 1600×900 |
| AC3 — holds at another frame size | issue AC3 | pass — 1600×900 and the `SIT.6` 390×844 frame, `centre_dx=0.0` on all six |
| AC4 — one placement model | issue AC4 | pass — judged on code in [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md); this run shows the drawn result only |
| AC5 — guard runs and fails a fixed x | issue AC5 | pass — `gdscript_tests.py test` → 28/28, exit 0 (`logs/unit-tests.log`) |
| AC6 — `Code lint`, `Unit tests`, `Coverage` green | issue AC6 | pass — 28/28; coverage 86.5% (4652/5375), threshold 80; `gdlint` no problems; `gdformat --check` 62 unchanged |
| AC7 — no spec, layout, content or node-name change | issue AC7 | pass — this run changed no file under `game/`; the judged build's fix PRs are the ones headless AC7 already names |

Protocol verdicts: `PTU-mode-pick` **not-judged** (P3, P4 unrun) · `PTU-shared-setup` **pass** ·
`PTU-shared-result` **pass** · `PTU-exceptions` **not-judged** (S1, S2 unrun). Every row, with its
cited story: [`protocols.md`](protocols.md).

Defects: none filed. Every `#616` criterion passes on this build; the remaining `not-judged` rows are
protocol rows no `#616` deliverable reaches, not failures.
