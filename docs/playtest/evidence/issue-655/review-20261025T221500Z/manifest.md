# Manifest

- **Issue**: 655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Run**: `review-20261025T221500Z`, implement dispatch parallel id 1, unattended, 2026-10-25
- **Environment**: headless (`ENV.1`), Godot `4.7.2.stable.official.ed1daf0bf`
- **Build**: `origin/main` **`5d80029`** ("Record the #794 R2 playtest evidence, both environments (#794) (#816)"), clean detached worktree at `T/opencode/impl655-par1-new`. Nothing measured in the primary checkout, which carries other agents' in-flight edits.
- **Session id**: `TEL.3` `sess-1792877959388-40808-playtest-309342` — the probe's router pass boots a real `PlaytestSeams` session and emits `puzzle.enter` → `puzzle.confirm` → `puzzle.leave` on it (`logs/x655-probe-stdout.log`). The first, seam-free `PuzzlePlayFlow` pass is outside that session by construction.
- **Coverage mode**: not a sweep run — one defect's observable, not a protocol set.
- **Defects**: this issue is the defect.
- **Probe**: `probe/x655_confirm_probe.gd`, carried unchanged from `review-20261025-impl10` (`md5 326b60bad50803a46896151661b815da`).
- **Logs**: `logs/x655-probe.log` (the probe's own log), `logs/x655-probe-stdout.log`, `logs/criterion-greps.log`, `logs/c5-gate-source.log` (source + blame for the `C5` gate), `logs/owner-and-published-read.log`, `logs/deploy-owner-search.log`, `logs/release-workflow-check.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/import.log`.
- **Screenshots**: `not applicable — ENV.1 headless; the observable is probe output and log lines, not a frame`.

## Results

| Criterion | Result on `5d80029` |
|---|---|
| 1 — quote the `specs/` release-status sentence with its commit | **pass** |
| 2 — no refusal is `B5`'s empty-value guard | **fail** |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** |
| 6 — published rows, or **held** | **fail — not held; and no owner exists for the step that would move it** |
| 7 — `#550` manifest rows + `Defects` line | **holds, unchanged** |
| 8 — scope: no `specs/`/asset change; `game/` only under item 4 | **holds** |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** |

Unit suite **32/32** headless tests; **coverage 86.7% (4797/5531)**, threshold 80, measured with `gdtoolkit==4.5.0` in a throwaway venv.

The probe output is byte-identical to `review-20261025-impl10/logs/x655-probe.log`, to both verification passes, and to `review-20261025-par1`. Every commit on this surface since `ce8a156` is docs-only or touches a different subsystem, so nothing the defect measures could have moved.
