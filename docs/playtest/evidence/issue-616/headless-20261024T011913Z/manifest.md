# Manifest — issue #616, acceptance run (headless)

What was run and the raw geometry: [`run.md`](run.md). Judgement text: [`notes.md`](notes.md).

| Field | Value |
|-------|-------|
| Issue | #616 — Chrome panels at a fixed corner offset instead of centered |
| Environment | `ENV.1` headless (`godot --headless`) |
| Build / session id | `origin/main` `2ccea5c`, Godot `4.7.2`. No `TEL.3` id (not a web build); run id `headless-20261024T011913Z`. |
| Timing (`SIT.4` runs) | Not a `SIT.4` run — placement only. |
| Coverage mode | `full`, within the issue's playable scope |
| Protocols in scope | `PTU-mode-pick`, `PTU-shared-setup`, `PTU-shared-result`, `PTU-exceptions` (S3), plus the `#616` criteria |
| Screenshots | waiting: `../graphical-<run-id>/screenshots/` |

## Results

| Protocol / unit | Cited | Outcome |
|-----------------|-------|---------|
| AC1 — six panels centered at 1280×720 | issue AC1 | pass — `centre_dx=0.0` |
| AC2 — vertical tops unchanged | issue AC2 | pass — 80 / 60 / 120 / 200 / 220 / 220 |
| AC3 — holds at another frame size | issue AC3 | pass — 1600×900 and 390×844 too, `centre_dx=0.0` |
| AC4 — one placement model | issue AC4 | pass — reinstating the old pattern gives `dx=440.0` / `460.0`; nothing shipped does |
| AC5 — guard fails a fixed x | issue AC5 | pass — suite 26/26; mutant exits 1 |
| AC6 — lint / tests / coverage | issue AC6 | pass — 26 tests; coverage 84.8% ≥ 80; lint in [`notes.md`](notes.md) |
| AC7 — no spec, layout, content or node-name change | issue AC7 | pass — merged PRs touch `game/` only |
| `PTU-mode-pick` P1 — both entries work | `UI-mode-pick.US1` | pass (headless) |
| `PTU-mode-pick` P5 — legibility at 390×844 | `UIS.T2`, `SIT.6` | not-judged — graphical |
| `PTU-mode-pick` P2/P4 — both environments, loading window | `UI-mode-pick.S2`, `US1.6` | not-judged — headless only |
| `PTU-shared-setup` / `PTU-shared-result` — controls inside the frame | `UI-shared-setup`, `UI-shared-result` | pass (headless) — 0 overflow, all frames |
| `PTU-exceptions` S3 — confirm/cancel does not trap | `EX.US1` | pass (headless) |
| Verdict `PTU-mode-pick` | — | **not-judged** — graphical pass needed |
| Verdict `PTU-shared-setup` / `PTU-shared-result` | — | **not-judged** — graphical pending |
| Verdict `PTU-exceptions` | — | **not-judged** — graphical pending |

Defects: none filed. The `#616` criteria pass; only the graphical re-run `PTU-*` requires waits.

## Paths

| Artifact | Path |
|----------|------|
| What was run | `run.md` |
| Notes | `notes.md` |
| Acceptance probe | `probe_616_acceptance.gd` |
| Probe log (judged window) | `logs/probe.log` |
| Mutant (defect reinstated) | `mutant_616.gd`, `logs/mutant.log` |
| Guard red run | `logs/unit-tests-mutant.log` |
| Suite | `logs/unit-tests.log` |
| Coverage | `logs/coverage.log` |
| Screenshots | waiting: `../graphical-<run-id>/screenshots/` |
