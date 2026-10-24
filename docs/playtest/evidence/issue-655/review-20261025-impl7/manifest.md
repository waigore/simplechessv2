# Manifest — #655 re-run on `064f134` (2026-10-25 implement pass, parallel id 2)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Disposition**: none claimed here; the proposal stands in [`../review-20261025T000000Z/disposition.md`](../review-20261025T000000Z/disposition.md). This folder is a re-measurement of a defect whose two remedies are owned elsewhere, not a new decision.
- **Environment**: headless (`ENV.1`) — Godot `4.7.2.stable.official.ed1daf0bf`, plus the published web build in headless Chrome at 390x844 DPR 2.
- **Build / session id**: probe leg on a clean detached worktree of `origin/main` **`064f134`** ("Record the #655 re-run on 4e50418 (#805)"). Probe `TEL.3` `sess-1792860262737-10221-playtest-186840`. Published artefact identity in [`logs/build-identity.txt`](logs/build-identity.txt) — `index.pck` `last-modified` 2026-10-24 13:00:58 GMT, 9561236 bytes, from CI run 40096272525 on `a5b35ae`.
- **Repeat count**: 1 probe leg (twice, identical `X655` lines), 1 headless smoke, 1 unit-suite run, 1 published-build browser leg.
- **Coverage mode**: `critical-only`.

## Results

| Row / protocol | Outcome | Evidence |
|---|---|---|
| Criterion 1 — quote the `specs/` sentence stating the catalog route's release status | **unmet** — the sentence does not exist | `git grep` on `064f134` → no match; `T9`/`T10` still "Set per deployment". #648 AC2 owns it |
| Criterion 2 — deal path reaches the resolver (no refusal is `B5`'s empty-value guard) | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false` |
| Criterion 3 — one named outcome (`K1` dealt **or** `F-puzzle-catalog.X2` absence) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<>` |
| Criterion 4 — absence recorded as `FAIL.T14` | **holds as an observable** | `last_failure=<status>`, no puzzle id, Elo kept |
| Criterion 5 — `C5` → `EX.confirm` → Cancel on the entered `S1` | **pass** | `X655 C5_ACTIVATED`, `X655 CANCEL`, `X655 ROUTER … flow_left=true` |
| Criterion 6 — published rows with build/session id, or **held** under the sequencing note | **fail, not held** | measured: 5 own-origin requests, zero catalog/advice; `index.pck` unchanged |
| Criterion 7 — `#550` manifest rows | **unchanged** | the sweep has not re-run |
| Criterion 8 — no `specs/`/`asset_catalog/`/`game_assets/` change; `game/` only under item 4 | **holds** | this pass adds only this folder |
| Criterion 9 — #332 / #333 / #335 relationship | **holds** | no edge added or implied |
| Unit suite (`gdscript_tests.py test`) | **pass** — 29 headless tests | see [`results.md`](results.md) |
| Import + headless smoke | **pass** — smoke reaches `mode-pick` | see [`results.md`](results.md) |

Criterion-by-criterion detail, exact `X655` lines, and the protocol verdicts
(`PTD-puzzle-stream` fail, `PTU-puzzle-play` fail, `PTU-puzzle-session` pass)
are in [`results.md`](results.md).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — the probe's `X655` verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — the same run's stdout: refusal backtrace and `TEL.1`–`TEL.5`
- [`logs/build-identity.txt`](logs/build-identity.txt) — published `index.pck` identity and its producing CI run
- [`logs/published-deal-log.txt`](logs/published-deal-log.txt) — network + console of the published cold open
- [`screenshots/`](screenshots/) — published mode-pick and the entered stream at 390x844
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged driver
- [`notes.md`](notes.md) — what this run settles and what it does not
