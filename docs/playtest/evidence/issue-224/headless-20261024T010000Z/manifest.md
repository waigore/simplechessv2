# Manifest

- **Issue**: 224
- **Environment**: headless (`ENV.1`), `display=headless`, `playtest_build=true`
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`; working-tree acceptance branch on `origin/main` `43ea9ec` (the spec change under acceptance is `specs/playtest/`, which the build does not read). Probe `TEL.3` `sess-1792797116424-23630-playtest` (`logs/playtest-headless.log`).
- **Coverage mode**: `full` (critical IDs: none), intersected with #224's scope: design `PTD-progression` only. UX protocols are not in scope — the deliverables are spec text, not interface behavior.
- **Story-row source**: the protocol's own `Cites` row (`PRG` A1, P1, P2, P3, M1, F1, Z1–Z3).
- **Defects**: none filed.
- **Screenshots**: waiting on `../graphical-20261024T010000Z/screenshots/`, a graphical re-run of the same build. `PTD-progression` states no screenshot exemption, so this headless run cannot finish acceptance on its own.

## Results

| Step / cited story | Result |
|--------------------|--------|
| S1 — `PRG.A1`/`PRG.P1` Player Elo persists | **pass** — commit 1032.5, cold reopen 1032.50 |
| S1 — `PRG.P2`/`PRG.M1` Last mode persists | **pass** — commit `puzzle`, reopen `puzzle` |
| S1 — `PRG.P3`/`PRG.M1` recentSolved persists | **pass** — commit `["pz-1"]`, reopen `["pz-1"]` |
| S1 — `PRG.A1` start value | **pass** — cleared store reopens at `CFG.ELO_START` 1000 |
| S2 — `PRG.P3` cap | **pass** — 25 solved IDs held at `CFG.ELO_RECENT_WINDOW` = 20 |
| S2 — `PRG.P3` order | **pass** — newest ID last (`pz-solve-24`) |
| S2 — `PRG.P3` drop | **pass** — oldest ID dropped |
| S1 — live save path (`PRG.A1` save, `PRG.P3` append) | not-judged — no puzzle dealt on this build (`stream_checkpoint dealt=false`) |
| S4 — `PRG.A1`/`PRG.F1` Shared advances no axis | **pass** — Shared entry reaches `shared-setup`, Elo and recentSolved unchanged |
| S4 — `PRG.Z1–Z3` completion rules | **pass** — gain nothing from a Shared game |
| **`PTD-progression` verdict** | **not-judged** — two S1 rows need a dealt puzzle; no cited story failed |

## Paths

- `notes.md` — what was judged, blockers, and the non-blocking marks
- `probe/accept224_probe.gd` — driver and judgements
- `logs/playtest-headless.log` — the run, including each `A224 JUDGE` row and `A224 SUMMARY pass=11 fail=0 not-judged=2`
- `logs/spec-lint.log` — `spec_lint` over the acceptance branch
