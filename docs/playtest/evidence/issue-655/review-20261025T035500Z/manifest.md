# Manifest — #655 verification pass (2026-10-25, parallel id 1)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Act**: independent verification of the merged implementation record
  [`../review-20261025-impl10/`](../review-20261025-impl10/) (merged as `e929ad9`, PR #829). Not an implementation pass: this folder is
  the only change, no `game/`, `specs/`, `asset_catalog/`, or `game_assets/` file moves.
- **Environment**: `ENV.1` headless — Godot `4.7.2.stable.official.ed1daf0bf`, clean detached worktree of `origin/main` **`8af7f8f`**
  ("Settle #506's SIT.5 seam (S12) and #402 edge direction (#832)").
- **Build / session id**: probe `TEL.3` `sess-1792871275363-86362-playtest-440842`; the absence leg's `puzzle.enter` → `puzzle.confirm`
  → `puzzle.leave` events on that session are in [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log).
- **Repeat count**: 1 import, 1 probe (the issue's own driver, unchanged), 1 unit-suite run, 1 published-artefact read, 1 issue-state read.
- **Coverage mode**: not run — `gdtoolkit` is absent in this container, as recorded on every earlier pass. Not claimed.

## Results

| Criterion | Verdict on `8af7f8f` | Evidence |
|---|---|---|
| 1 — the `specs/` sentence with its commit | **pass** — `catalog-service.md` `R9` / `:56` landed **`a94210d`**; `configuration.md` `B5` landed **`a9192a0`** | [`logs/criterion-1-2-grep.log`](logs/criterion-1-2-grep.log) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** — `is_available=false`, `game/session_router.gd:33-34` still `""` | `X655 B5` line; `git grep` in the same log |
| 3 — one named outcome | **fail** — `S1` with nothing dealt and no failed-read record | `X655 ENTERED` line |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** | `GS.playerElo` 1000.00 unchanged, no puzzle id, `last_failure=<status>`, `deal read failed (status)` ×2 |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass — re-measured here** | `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass` |
| 6 — published rows, or **held** | **fail — not held.** #648's halves landed in two commits; #479's is unlanded but criterion 6's held clause needs **both** | [`logs/published-and-owners.log`](logs/published-and-owners.log) |
| 7 — `#550` manifest rows | **holds, unchanged** — the sweep has not re-run since `d9e1fe1` | [`logs/issue-550-manifest.log`](logs/issue-550-manifest.log) |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — PR #829 is 11 files, 0 under `game/`, `specs/`, `asset_catalog/`, `game_assets/` | `git show --stat e929ad9` |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** — no edge added or implied | issue state |

Delegated reviews: `review-code` **not run — correctly out of scope** (PR #829 changes no implementation file); `review-asset`
**not run** (no catalog or asset path changes).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — the probe's `X655` verdict lines (my run)
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — same run's stdout: refusal backtraces and `TEL.1`–`TEL.5`
- [`logs/criterion-1-2-grep.log`](logs/criterion-1-2-grep.log) — build identity, the `specs/` sentences, their commits, the empty `T9`/`T10` assignments
- [`logs/published-and-owners.log`](logs/published-and-owners.log) — published `index.pck` identity, #479's PR state, every owner's status
- [`logs/issue-550-manifest.log`](logs/issue-550-manifest.log) — the sweep manifest's header, `Defects` line and last two commits touching it
- [`logs/import.log`](logs/import.log), [`logs/unit-tests.log`](logs/unit-tests.log) — import exit 0, 32 headless tests
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged driver as run
- [`notes.md`](notes.md) — what this pass settles, and the correction it makes to the implementation record
- Screenshots: **none** — headless-only; the published-build captures live in [`../review-20261025T022500Z/screenshots/`](../review-20261025T022500Z/screenshots/)

## Attribution

Verification runs are attributed per commit, not per time of day. Everything in this folder was run by the verification pass on the
commit named above; the published-artefact identity was read live at `2026-10-25T03:56Z` and is unchanged from
`review-20261025T022500Z`.
