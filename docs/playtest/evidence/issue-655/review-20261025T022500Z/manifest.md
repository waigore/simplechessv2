# Manifest — #655 independent verification (2026-10-25, parallel id 1)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Disposition claimed**: none. This folder is verification evidence, not an implementation record.
- **Environment**: headless (`ENV.1`) for the probe and the unit suite; **published build** (`https://waigore.github.io/simplechessv2/`) in headless Chrome `156.0.8078.47` with SwiftShader WebGL for the release leg.
- **Build measured**: clean detached worktree of `origin/main` **`4f133e8`** ("Read Web ambient audio as the imported resource (Refs #785) (#799)"), Godot `4.7.2.stable.official.ed1daf0bf`.
- **Published artefact**: `index.pck` `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`, `content-length: 9568028`, `etag: "6adcf171-91ff1c"` — produced by Web release run `40118381611` from `c5b8189`. This is **not** the 13:00:58Z / `"6adcac0a-91e494"` artefact every implement pass measured.
- **Deliverable verified**: PR [#814](https://github.com/waigore/simplechessv2/pull/814) (merged `2e34ee7`) — folder `review-20261025-impl9/`, present on `main`.
- **Session id**: probe `TEL.3` `sess-1792865820671-46772-playtest-207114` (first run; re-run on `4f133e8` byte-identical).
- **Coverage mode**: `critical-only`.
- **Repeat count**: 2 probe runs (two different `main` commits, identical output), 2 imports, 2 unit-suite runs, 2 published cold opens.

## Results

| Criterion | Verdict on `4f133e8` / published build | Evidence |
|---|---|---|
| 1 — a `specs/` sentence states the catalog route's release status, with its commit | **pass** | `CMP-catalog-service` `R9` (`:23`) and `:56`; landed `a94210d` (PR #815) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<>` |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** | Elo 1000.00 before/after, no pid, `last_failure=<status>`, log line |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass (probe); published activation inconclusive** | `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass` |
| 6 — published rows with build/session id, or **held** | **fail — not held.** Measured on the 17:57Z release: zero catalog/advice requests, refusal is client-side | `logs/published-build-requests-verify.json` |
| 7 — `#550` manifest rows | **holds, unchanged** | `issue-550/headless-20261024T000000Z/manifest.md:8` |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** | PR #814: 13 files, 0 under `game/`, `specs/`, `asset_catalog/`, `game_assets/` |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** | no edge added or implied |
| Unit suite | **pass — 31 headless tests** | verifier's own run on `4f133e8` |
| Import | **pass — exit 0** | `logs/import-verify.log` |

## Paths

- [`logs/x655-probe-verify.log`](logs/x655-probe-verify.log) — verifier's own probe verdict lines
- [`logs/x655-probe-stdout-verify.log`](logs/x655-probe-stdout-verify.log) — same run's stdout (`TEL.1`–`TEL.5`, refusal backtrace)
- [`logs/published-build-requests-verify.json`](logs/published-build-requests-verify.json) — every request the published client made, and the deal-failure console lines
- [`logs/import-verify.log`](logs/import-verify.log) — import on `4f133e8`
- [`screenshots/01-mode-pick-published.png`](screenshots/01-mode-pick-published.png) — published mode pick
- [`screenshots/02-puzzle-stream-published.png`](screenshots/02-puzzle-stream-published.png) — published puzzle stream after `C2`: board, `Elo 1000`, no puzzle open
- [`notes.md`](notes.md) — what this pass settles, the one correction to the implement record, and the harness limit
