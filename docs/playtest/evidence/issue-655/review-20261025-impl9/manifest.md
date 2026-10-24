# Manifest — #655 re-run on `ce8a156` (2026-10-25 implement pass, parallel id 1)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Disposition**: none claimed; the proposal in [`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md) stands.
- **Environment**: headless (`ENV.1`) — Godot `4.7.2.stable.official.ed1daf0bf`, clean detached worktree of `origin/main` `ce8a156`.
- **Build / session id**: probe `TEL.3` `sess-1792862240351-24968-playtest-190316`; published artefact in [`logs/build-identity.txt`](logs/build-identity.txt).
- **Repeat count**: 1 probe leg, 1 import, 1 unit-suite run, 1 artefact identity check.
- **Coverage mode**: `critical-only`.

## Results

| Row / protocol | Outcome | Evidence |
|---|---|---|
| Criterion 1 — quote the `specs/` sentence stating the catalog route's release status | **unmet** — the sentence does not exist on `ce8a156` | [`logs/criterion1-grep.log`](logs/criterion1-grep.log); #648 AC2 owns it |
| Criterion 2 — deal path reaches the resolver (no refusal is `B5`'s empty-value guard) | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false` |
| Criterion 3 — one named outcome (`K1` dealt **or** `F-puzzle-catalog.X2` absence) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<>` |
| Criterion 4 — absence recorded as `FAIL.T14` | **holds as an observable** | `last_failure=<status>`, no puzzle id, Elo 1000.00 kept |
| Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` | **pass** | `X655 C5_ACTIVATED`, `X655 CANCEL`, `X655 ROUTER … flow_left=true` |
| Criterion 6 — published rows with build/session id, or **held** under the sequencing note | **held** — condition met and verified | `index.pck` byte-identical to the artefact `review-20261025-impl7` measured; #648 and #479 both unlanded |
| Criterion 7 — `#550` manifest rows | **unchanged** | [`logs/finding-550.md`](logs/finding-550.md): the sweep has not re-run |
| Criterion 8 — no `specs/`/`asset_catalog/`/`game_assets/` change; `game/` only under item 4 | **holds** | this pass adds only this folder |
| Criterion 9 — #332 / #333 / #335 relationship | **holds** | no edge added or implied |
| Unit suite (`gdscript_tests.py test`) | **pass** — 30 headless tests | [`logs/unit-tests.log`](logs/unit-tests.log) |
| Import | **pass** — exit 0 | [`logs/import.log`](logs/import.log) |

Criterion-by-criterion detail, the exact `X655` lines, and the protocol verdicts
(`PTD-puzzle-stream` fail, `PTU-puzzle-play` fail, `PTU-puzzle-session` pass)
are in [`results.md`](results.md).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — the probe's `X655` verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — same run's stdout: refusal backtrace and `TEL.1`–`TEL.5`
- [`logs/criterion1-grep.log`](logs/criterion1-grep.log) — the criterion-1 `git grep` and the `T9`/`T10`/`B5` rows it cites
- [`logs/build-identity.txt`](logs/build-identity.txt) — published `index.pck` identity and its producing CI run
- [`logs/finding-550.md`](logs/finding-550.md) — the sweep manifest row, unchanged
- [`logs/unit-tests.log`](logs/unit-tests.log), [`logs/import.log`](logs/import.log) — build checks
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged driver
- [`notes.md`](notes.md) — what this run settles, what it does not, and the one change since `064f134`
