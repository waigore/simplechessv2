# Manifest — issue #616, independent acceptance re-run

Unattended `issue-workflow-accept-agent` run (parallel id **1**, `Assigned issue: none`). This folder
records checks produced **in this run**, on a clean worktree, so the acceptance does not rest on the
implementor's numbers. It does not replace the deliverable folders; it verifies them.

Graphical half accepted: [`../graphical-20261024T073700Z/`](../graphical-20261024T073700Z/manifest.md).
Headless half: [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md).

| Field | Value |
|-------|-------|
| Issue | #616 — Chrome panels at a fixed corner offset instead of centered |
| Environment | `ENV.2` graphical — `DisplayServer` = `X11`, `gl_compatibility`, Mesa llvmpipe under `xvfb-run`, Godot `4.7.2.stable.official.ed1daf0bf`; the drive's own `STEP env` line is the source |
| Build / session id | `origin/main` `4e4b724`, detached worktree `/tmp/opencode/accept616-a1`, shipped `game/main.tscn`; no `TEL.3` id (not a web build) |
| Timing (`SIT.4` runs) | Not a `SIT.4` run; the `fps` / `draw_calls` rows are liveness checks, not timing claims |
| Coverage mode | `full`, within the issue's playable scope |
| Protocols in scope | `PTU-mode-pick` (S6 graphical), `PTU-shared-setup`, `PTU-shared-result`, `PTU-exceptions` (S3), plus the `#616` acceptance criteria |
| Paths | Logs in [`logs/`](logs/): `chrome-placement-guard.log`, `unit-tests.log`, `coverage.log`, `graphical-drive-rerun.log`. Screenshots are the committed ones under [`../graphical-20261024T073700Z/screenshots/`](../graphical-20261024T073700Z/screenshots/), reproduced byte-for-byte by this run ([`reproduction.md`](reproduction.md)) |

## Results

| Check | Cited | Outcome |
|-------|-------|---------|
| AC1 — six panels centered at 1280×720 | issue AC1 | pass — `centre_dx=0.0` on all six, drawn rect |
| AC2 — vertical tops unchanged | issue AC2 | pass — 80 / 60 / 120 / 200 / 220 / 220 |
| AC3 — holds at another frame size | issue AC3 | pass — 1600×900 and 390×844, `centre_dx=0.0` on all six |
| AC4 — one placement model | issue AC4 | pass — no `PRESET_CENTER*` in the three files; five call sites, one static rule |
| AC5 — guard runs and fails a fixed x | issue AC5 | pass — 28/28 in the suite; mutant `ModePick … off by 440.0 px`, exit 1 |
| AC6 — lint / tests / coverage green | issue AC6 | pass — `gdlint` clean, `gdformat --check` 62 unchanged, 28/28, coverage 86.5% ≥ 80 |
| AC7 — no spec / layout / content / node-name change | issue AC7 | pass — no `specs/` diff since `eb72873`; `#700` touches tests only |
| Graphical evidence is a rendered session (the #742 question) | `specs/playtest/playtest.md:36` | pass — 19/19 committed PNGs reproduce byte-for-byte; mode-pick content starts at x = 480 / 640 / 35 |

Protocol verdicts inherited from the graphical half and not re-judged here: `PTU-mode-pick`
**not-judged** (P3, P4 unrun), `PTU-shared-setup` **pass**, `PTU-shared-result` **pass**,
`PTU-exceptions` **not-judged** (S1, S2 unrun). None of those rows belongs to a `#616` criterion.

Defects: none filed.
