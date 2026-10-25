# Manifest

- **Issue**: 544 — implement `SIT.4` frame-time / load-time capture (seam `S11`, op `O10`)
- **Environment**: headless (`ENV.1`) — the unit-test binary, `spec_lint`, format/lint, and the headless smoke of `main.tscn`
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf` on `origin/main` `1894f31` (`Record the #546 S6 acceptance run (graphical, fails; files #837) (#838)`), clean detached worktree. `S11` `refused` reports carry no `TEL.3` (the seam emits `TEL.3` only with a start event); the smoke line carries session `sess-1792872913131-99315-playtest-291345` (`logs/headless-smoke.log`).
- **Coverage mode**: partial — `S11` seam scope only. The protocol-level `PTU-*` S1/S4/S5 judgement is `ENV.2` (`tools-situational.md`: "Timing is sampled on Graphical, where a browser renders") and belongs to the #400 sweep; this run establishes the seam, its tests, and its release behaviour.
- **Screenshots**: not applicable here — this environment has no display; the graphical run's folder records what `ENV.2` produced instead.
- **SIT.4 timing record**: device `Mac16,* (Apple M5)`, OS `macOS 27.0.1 arm64`, engine `Godot 4.7.2`, repeat count `3` for the graphical frame-time probe (`graphical-20261024T203114Z`, one run per log).

## Results

| Check | Result |
|-------|--------|
| AC 9 — unit tests cover the close predicates and negatives | pass — `logs/unit-tests.log`: 32 suites, including `playtest_seams_measure_test` (`_check_all` and its eight `_check_*` legs) |
| AC 9 — `gdscript_tests.py test` | pass — 32 headless unit test(s) passed |
| AC 9 — `gdscript_tests.py coverage` | pass — statement-line coverage 86.7% (4799/5533), threshold 80 |
| AC 10 — `spec_lint.py` clean, no `specs/` edit | pass — 0 errors, 1 pre-existing warning (`specs/view/glossary.md` `Diagram`); no `specs/` change in the deliverable |
| Format / lint | pass — `gdformat --check game` 68 files unchanged; `gdlint game` no problems |
| Headless smoke (`ENV.1`) | pass — 4 `TEL.1` events (`jump`, `smoke_inspect`, `pause`, `resume`), no errors |
| `S11` on a live session | **fail** — see `graphical-20261024T203114Z/notes.md`: a `frame_times` window costs its own close report, and the named `disarm_measurement()` deliverable is absent |

## Paths

- `logs/import.log`
- `logs/unit-tests.log`
- `logs/coverage.log`
- `logs/spec-lint.log`
- `logs/gdformat-check.log`, `logs/gdlint.log`
- `logs/headless-smoke.log`

## Defects

None filed from this run. The live `S11` findings are routed on #544 itself (an implementation/API gap and a defect route against #506 named in `D3`), and the shipped-build blocker is the already-accepted #630 whose repair leaf #647 is open — see `graphical-20261024T203114Z/notes.md`.
