# Manifest — #655 implementation re-run #11 (2026-10-25, parallel id 3)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Environment**: `headless` (`ENV.1`) for the probe, the import, and the unit suite. The published leg is a read of the published artefact's identity (see *Published leg*).
- **Build / session id**: clean detached worktree of `origin/main` **`6a969ee`** ("Record the #478 wave-1 playtest sweep on one playtest build (#836)"), Godot `4.7.2.stable.official.ed1daf0bf`; **`TEL.3` `sess-1792873135319-1941-playtest-242597`**.
- **Judged under**: the **catalog enabled in the release** branch — the answer #648 records. The quoted sentence is `specs/technical/configuration.md:43` (`B5`), landed **`a9192a0`** (PR #822); a second home is `specs/technical/components/catalog-service.md:56`, landed **`a94210d`** (PR #815). Both are quoted with their commits in [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log).
- **Published artefact** (read, not driven this pass): `index.pck` `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`, `etag: "6adcf171-91ff1c"`, `content-length: 9568028` — unchanged since `review-20261025T022500Z` drove it ([`logs/published-identity.log`](logs/published-identity.log)).
- **Coverage mode**: `critical-only`.
- **Repeat count**: 1 probe run, 1 import, 1 unit-suite run. The probe verdict lines are **byte-identical** to [`../review-20261025-impl10/logs/x655-probe.log`](../review-20261025-impl10/logs/x655-probe.log) on a different commit.
- **Screenshots**: none — headless-only run. The published-build captures live in [`../review-20261025T022500Z/screenshots/`](../review-20261025T022500Z/screenshots/).

## Results

| Criterion | Verdict on `6a969ee` | Evidence |
|---|---|---|
| 1 — name the #648 answer and quote the `specs/` release-status sentence with its commit | **pass** | `configuration.md:43` `B5` (landed `a9192a0`, PR #822) and `catalog-service.md:56` (landed `a94210d`, PR #815) — [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` still `""`; the only assignments in `game/` are the test seam `game/advice_ui_test.gd:40-41` |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>` — the body calls this a `fail` verbatim |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** | Elo `1000.00` before and after, no puzzle id, `PuzzleStream.last_failure` = `<status>`, and `puzzle stream: deal read failed (status)` twice in the run log ([`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log)) |
| 5 — `C5` → `EX.confirm` (`leave_confirm`) → Cancel on `S1` | **pass** | `X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true`, `X655 CANCEL state=S1`, `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass` ([`logs/x655-probe.log`](logs/x655-probe.log)) |
| 6 — published rows with build / session id, or **held** | **fail — not held.** Both halves of the held condition have landed: #648's sentence (`a9192a0`, `a94210d`) and #479's delivery decision (PR #806, merge `f07eed6`, 2026-10-24T19:59:17Z). The published `index.pck` is unchanged and predates both | [`logs/published-identity.log`](logs/published-identity.log); [`logs/held-condition.log`](logs/held-condition.log); `review-20261025T022500Z` |
| 7 — `#550` manifest rows + `Defects` line | **holds, unchanged** — sweep has not re-run; `Defects` line still names #655 | [`logs/published-and-550.log`](logs/published-and-550.log) |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — this folder adds only evidence; item 4 measures conforming, so the repair clause does not fire | diff scope |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** — no edge added or implied | — |
| Unit suite | **pass — 32 headless tests** | [`logs/unit-tests.log`](logs/unit-tests.log) |
| Import | **pass — exit 0** | [`logs/import.log`](logs/import.log) |
| Coverage | **not measured** — `gdtoolkit==4.5.0` absent in this container | [`logs/coverage.log`](logs/coverage.log) |

Protocols on this build: `PTD-puzzle-stream` **fail** (K1), `PTU-puzzle-play` **fail** (US1), `PTU-puzzle-session` **pass** (S2–S3).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — probe verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — same run's stdout (`TEL.1`–`TEL.5`, refusal backtrace, the `FAIL.T14` log lines)
- [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log) — build identity, both release-status sentences with their commits, the empty `T9`/`T10` assignments, the `C5` gate
- [`logs/held-condition.log`](logs/held-condition.log) — #648 / #479 landing state, `gh pr view 806` state
- [`logs/c5-attribution.log`](logs/c5-attribution.log) — `git blame` placing the `C5` exemption on #694 (`2e389b5`)
- [`logs/published-identity.log`](logs/published-identity.log) — published artefact identity
- [`logs/published-and-550.log`](logs/published-and-550.log) — the `#550` manifest rows and its `Defects` line
- [`logs/unit-tests.log`](logs/unit-tests.log), [`logs/coverage.log`](logs/coverage.log), [`logs/import.log`](logs/import.log)
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged probe carried over from `review-20261025-impl10`
- [`notes.md`](notes.md) — what moved since the verify fail on `8af7f8f`, and why criteria 2, 3 and 6 still cannot move
