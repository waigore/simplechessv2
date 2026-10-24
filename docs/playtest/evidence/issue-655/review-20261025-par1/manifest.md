# Manifest

- **Issue**: 655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Run**: `review-20261025-par1`, implement dispatch parallel id 1, unattended, 2026-10-25
- **Environment**: headless (`ENV.1`), Godot `4.7.2.stable.official.ed1daf0bf`
- **Build**: `origin/main` **`1cb3a5e`** ("Record the #655 re-run on ddaca90, with the #479 exclusion finding (#808)"), clean detached worktree. Nothing measured in the primary checkout.
- **Session id**: the probe is headless and boots no `PlaytestSeams` session; no `TEL.3` id is claimed for this run. See `notes.md` §Identity.
- **Coverage mode**: not a sweep run — one defect's observable, not a protocol set.
- **Defects**: this issue is the defect.
- **Probe**: `probe/x655_confirm_probe.gd`, carried unchanged from `review-20261025-impl10`.
- **Logs**: `logs/x655-probe.log` (the probe's own log), `logs/x655-probe-stdout.log`, `logs/criterion1-grep.log`, `logs/criterion2-3-grep.log`, `logs/criterion5-c5-gate.log`, `logs/owner-state.log`, `logs/unit-tests.log`, `logs/coverage.log`, `logs/import.log`.

## Results

| Criterion | Result on `1cb3a5e` |
|---|---|
| 1 — quote the `specs/` release-status sentence with its commit | **pass** |
| 2 — no refusal is `B5`'s empty-value guard | **fail** |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** |
| 6 — published rows, or **held** | **fail — not held** |
| 7 — `#550` manifest rows + `Defects` line | **holds, unchanged** |
| 8 — scope: no `specs/`/asset change; `game/` only under item 4 | **holds** |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** |

Unit suite **32/32** headless tests; **coverage 86.7% (4775/5508), threshold 80 — measured for the first time on this issue** (`gdtoolkit==4.5.0` installed into a throwaway venv for this run).
