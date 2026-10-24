# Manifest — issue #616, acceptance run (graphical)

What was run and the raw geometry: [`run.md`](run.md). Judgement text: [`notes.md`](notes.md).
The headless half of this acceptance is [`../headless-20261024T011913Z/`](../headless-20261024T011913Z/manifest.md).

| Field | Value |
|-------|-------|
| Issue | #616 — Chrome panels at a fixed corner offset instead of centered |
| Environment | `ENV.2` graphical (`DisplayServer` = `macOS`, Metal, Godot `4.7.2.stable.official.ed1daf0bf`) |
| Build / session id | `origin/main` `4aa6aba` (the branch tip when this run started), detached worktree. Source: the shipped playtest tree `game/main.tscn` run in a rendered session — the published URL does not serve this commit (it is not yet on `main`-published Pages), so this is the local-playtest-build reading, and no release export fallback was used. No `TEL.3` id (not a web build); run id `graphical-20261024T110000Z`. |
| Timing (`SIT.4` runs) | Not a `SIT.4` run. `PTU-shared-play` / `PTU-puzzle-play` are out of scope here ([notes.md](notes.md)); the frame-loop reading in `run.md` is a liveness check, not a timing claim. |
| Coverage mode | `full`, within the issue's playable scope |
| Protocols in scope | `PTU-mode-pick` (S6 graphical), `PTU-shared-setup`, `PTU-shared-result`, `PTU-exceptions` (S3), plus the `#616` criteria |
| Screenshots | `screenshots/` — 19 PNG files listed under [Paths](#paths) |

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
| `PTU-mode-pick` P1 — both entries work | `UI-mode-pick.US1` | pass (graphical) — Shared game and Puzzle stream both entered; screenshots 01, 03, 05 |
| `PTU-mode-pick` P3 — Switch locale | `UI-mode-pick.US1` | not-judged — no step of this run switched locale |
| `PTU-mode-pick` P4 — `EX.loading` window | `UI-mode-pick.S2`, `US1.6` | not-judged — `SIT.4` timing, no `SIT.4` run here |
| `PTU-mode-pick` P5 — legibility at 390×844 | `UIS.T2`, `SIT.6` | pass (graphical) — `body_text_px=21` for an 844 px frame; smallest label renders 21 px; no clipping or panel overflow. See the note on the debug overlay in [notes.md](notes.md) |
| `PTU-mode-pick` verdict | — | **not-judged** — P3 and P4 are out of scope for this run |
| `PTU-shared-setup` P1 — controls and Start/Back match story | `UI-shared-setup.US1` | pass (graphical) — panel centered, 10 controls, 0 outside the frame, smallest label 18 px at 1280×720 |
| `PTU-shared-setup` verdict | — | **pass** |
| `PTU-shared-result` P1 — result actions match story | `UI-shared-result.US1` | pass (graphical) — panel centered, 8 controls, 0 outside the frame |
| `PTU-shared-result` verdict | — | **pass** |
| `PTU-exceptions` S3 — interrupt leave/resign with cancel | `EX.US1` | pass (graphical) — Resign confirm opened centered; Cancel returned to shared play with the session intact |
| `PTU-exceptions` verdict | — | **not-judged** — S1 and S2 are not steps this defect's deliverables touch, and this run did not drive them |
| Screenshot completeness | `evidence.md` | pass — one rendered image per judged state and per frame size |

Defects: none filed. Every `#616` criterion passes on this build; the remaining `not-judged` rows above
are protocol rows no `#616` deliverable reaches, not failures.

## Paths

| Artifact | Path |
|----------|------|
| What was run | `run.md` |
| Notes | `notes.md` |
| Drive script | `drive_graphical.gd` |
| Runner | `run_graphical.sh` |
| Drive log (judged window) | `logs/graphical-drive.log` |
| Superseded first attempt (honest record) | `logs/graphical-drive-first-attempt.log` |
| Unit tests | `logs/unit-tests.log` |
| Coverage | `logs/coverage.log` |
| Lint | `logs/lint.log`, `logs/format-check.log` |
| Screenshots (1280×720) | `screenshots/w1280-01-mode-pick.png`, `-02-shared-setup`, `-03-resign-confirm`, `-04-shared-result`, `-05-stream-confirm`, `-06-save-failure` |
| Screenshots (1600×900) | `screenshots/w1600-01-mode-pick.png` … `-06-save-failure` |
| Screenshots (390×844, `O12`) | `screenshots/phone-01-mode-pick.png` … `-06-save-failure` |
| Rendered loop reading | `screenshots/caps-frame-3239.png` |
