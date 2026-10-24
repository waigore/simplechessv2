# Manifest — issue #616, acceptance run (headless)

| Field | Value |
|-------|-------|
| Issue | #616 — Chrome panels sit at a fixed corner offset instead of centered (mode-pick, shared-setup, shared-result, three dialogs) |
| Environment | `ENV.1` headless (`godot --headless`, no display) |
| Build / session id | `origin/main` `2ccea5c`, Godot `4.7.2.stable.official.ed1daf0bf`. Not a web build, so no `TEL.3` session id; run id `headless-20261024T011913Z`. |
| Timing (`SIT.4` runs) | Not a `SIT.4` run — this defect changes panel placement only, and `SIT.4` (loading time) is not in scope. |
| Coverage mode | `full`, intersected with the issue's playable scope |
| Protocols in scope | `PTU-mode-pick` (UX, placement part of S1/S2/S3 and `UI-mode-pick.US1`), `PTU-shared-setup`, `PTU-shared-result` (copy and control placement), `PTU-exceptions` (S3 confirm/cancel), plus the `#616` placement criteria |
| Screenshots | waiting on the graphical run of this same build (`../graphical-<run-id>/screenshots/`) |

## Results

| Protocol / unit | Cited spec elements | Outcome |
|-----------------|---------------------|---------|
| `#616` AC1 — six panels centered at 1280×720 | issue AC1 | pass — `centre_dx=0.0` for all six |
| `#616` AC2 — vertical tops unchanged | issue AC2 | pass — 80 / 60 / 120 / 200 / 220 / 220 |
| `#616` AC3 — holds at another frame size | issue AC3 | pass — also 1600×900 and 390×844, `centre_dx=0.0` at all three |
| `#616` AC4 — one placement model | issue AC4 | pass — re-imposing `PRESET_CENTER` + `position` on a screen panel and a dialog gives `dx=440.0` / `dx=460.0`; no shipped control does it |
| `#616` AC5 — guard runs and fails a fixed x | issue AC5 | pass — suite 26/26; mutant `ERROR: ModePick drawn centre x off by 440.0 px` with exit 1 |
| `#616` AC6 — lint / tests / coverage | issue AC6 | pass — `26 headless unit test(s) passed`; coverage 84.8% (4475/5280) ≥ 80; lint see `notes.md` |
| `#616` AC7 — no spec, layout, content or node-name change | issue AC7 | pass — merged PRs touch only `game/presentation.gd`, `game/shared_play_panel.gd`, `game/puzzle_play_panel.gd`, `game/chrome_placement_test.gd`, `game/presentation_test.gd` |
| `PTU-mode-pick` P1 — both entries work (activated C1 then C2 through the router) | `UI-mode-pick.US1` | pass (headless) |
| `PTU-mode-pick` P5 — labels legible, no clipping at 390×844 | `UIS.T2`, `SIT.6` | not-judged — legibility is a graphical judgement |
| `PTU-mode-pick` P2/P4 — both environments, loading window | `UI-mode-pick.S2`, `US1.6` | not-judged (headless only; `EX.loading` window not timed here) |
| `PTU-shared-setup` / `PTU-shared-result` — controls inside the frame | `UI-shared-setup`, `UI-shared-result` | pass (headless) — 0 overflowing controls at all three frames |
| `PTU-exceptions` S3 — confirm/cancel does not trap | `EX.US1` | pass (headless) — Resign confirm opened and cancelled; Stream confirm opened and cancelled |
| Protocol verdict `PTU-mode-pick` | — | **not-judged** in this environment (P5, P2, P4 need the graphical pass) |
| Protocol verdict `PTU-shared-setup` / `PTU-shared-result` | — | **not-judged** (graphical pass pending) |
| Protocol verdict `PTU-exceptions` | — | **not-judged** (graphical pass pending) |

Defects: none filed. The `#616` criteria pass on this build; what waits is the graphical
re-run that `PTU-*` requires, which is not a defect ([`evidence.md`](../../../../specs/playtest/evidence.md)).

## Paths

| Artifact | Path |
|----------|------|
| Notes | `notes.md` |
| Acceptance probe | `probe_616_acceptance.gd` |
| Probe log (judged window) | `logs/probe.log` |
| Mutant (defect reinstated) | `mutant_616.gd`, `logs/mutant.log` |
| Guard red run | `logs/unit-tests-mutant.log` |
| Suite | `logs/unit-tests.log` |
| Coverage | `logs/coverage.log` |
| Screenshots | waiting: `../graphical-<run-id>/screenshots/` |
