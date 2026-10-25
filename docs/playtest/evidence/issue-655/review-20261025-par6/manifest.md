# Manifest

- **Issue**: 655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Run**: `review-20261025-par6`, implement dispatch parallel id 6, unattended, 2026-10-25
- **Environment**: headless (`ENV.1`), Godot `4.7.2.stable.official.ed1daf0bf`
- **Build**: `origin/main` **`6e9cb7e`** ("Fix the S11 measure seam against the #544 acceptance findings (#869)"), clean detached worktree at `T/opencode/wt655-impl-par6`. Nothing measured in the primary checkout, which carries other agents' in-flight edits (`docs/playtest/evidence/issue-626/`, `wt-accept546/`).
- **Session id**: `TEL.3` `sess-1792883679081-94520-playtest-273473` — the probe's router pass boots a real `PlaytestSeams` session and emits `puzzle.enter` → `puzzle.confirm` → `puzzle.leave` on it (`logs/x655-probe.log`). The first, seam-free `PuzzlePlayFlow` pass is outside that session by construction.
- **Coverage mode**: not a sweep run — one defect's observable, not a protocol set.
- **Defects**: this issue is the defect.
- **Probe**: `probe/x655_confirm_probe.gd`, carried unchanged from `review-20261025T235500Z` (`md5 326b60bad50803a46896151661b815da`), so this is the same instrument on a new commit.
- **Logs**: `logs/x655-probe.log`, `logs/x655-probe-stdout.log`, `logs/surface-drift.log`, `logs/criteria-1-2-3-source.log`, `logs/spec-branch.log`, `logs/c5-gate-source.log`, `logs/release-workflow-check.log`, `logs/owner-state.log`, `logs/published-identity.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/presentation-audio-direct.log`, `logs/spec-lint.log`, `logs/import.log`.
- **Screenshots**: `not applicable — ENV.1 headless; the observable is probe output and log lines, not a frame`.

## Results

| Criterion | Result on `6e9cb7e` |
|---|---|
| 1 — quote the `specs/` release-status sentence with its commit | **pass**, with the #648 posture conflict still open (see notes) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** (eleventh conforming measurement) |
| 6 — published rows, or **held** | **fail — the `held` clause is spent; no owner exists for the delivery step** |
| 7 — `#550` manifest rows + `Defects` line | **holds, unchanged** |
| 8 — scope: no `specs/`/asset change; `game/` only under item 4 | **holds** |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** |

Unit suite **32/32** headless tests; **statement-line coverage 86.9% (4826/5551)**, threshold 80, `gdtoolkit==4.5.0` in a throwaway venv; `spec_lint` 0 errors, 1 pre-existing warning. `presentation_audio_test` failed under the coverage wrapper on the first attempt and passed standalone (`logs/presentation-audio-direct.log`); the second wrapper attempt passed, so the recorded number comes from a clean run.

The probe output is byte-identical to `review-20261025T235500Z` and to `review-20261025T221500Z`. `git diff 161b4a9..6e9cb7e --name-only -- game/session_router.gd game/puzzle_stream.gd game/puzzle_play_flow.gd game/puzzle_session.gd` is **empty**: the deal path and the `C5` gate are unchanged across the commit interval (`logs/surface-drift.log`). The four `game/` files that did move (`board_presentation*.gd`, `playtest_seams*.gd`, `presentation*.gd`) are presentation and measure seams.
