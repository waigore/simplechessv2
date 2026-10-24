# Criterion verdicts — #655 verification on `906b8b3`

Split out of [`manifest.md`](manifest.md) to stay under the evidence word limit.

| Criterion | Verdict on `906b8b3` | Evidence |
|---|---|---|
| 1 — a `specs/` sentence states the catalog route's release status, with its commit | **pass** — `configuration.md:43` `B5` and `catalog-service.md:56`; `a94210d` and `a9192a0` both ancestors | [`logs/criterion1-grep.log`](logs/criterion1-grep.log) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` still `""`; the only assignments in `game/` are the test seam [`logs/criterion2-5-code.log`](logs/criterion2-5-code.log) |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>` — the body calls this a `fail` verbatim |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** | Elo `1000.00` before and after, no puzzle id, `last_failure=<status>`, `puzzle stream: deal read failed (status)` ×2 in the run stdout |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** | `X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm>`, `X655 CANCEL state=S1`, `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass`; telemetry `puzzle.enter` (`J-puzzle-session.S1`) → `puzzle.confirm` (`leave_confirm`) → `puzzle.leave` (`S2`) |
| 6 — published rows with build / session id, or **held** | **fail — not held.** Both halves landed (#648 `a94210d`/`a9192a0`; #479 `f07eed6`), so the held clause is spent; the published artefact predates them and still refuses client-side | [`logs/published-and-550.log`](logs/published-and-550.log) |
| 7 — `#550` manifest rows + `Defects` line | **holds, unchanged** | sweep has not re-run; `manifest.md` still names #655 |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** | PR #841 is 15 files, **0** under `game/`, `specs/`, `asset_catalog/`, `game_assets/`. Item 4 measures conforming, so no `game/` change is owed |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** | no edge added or implied |
| Unit suite | **pass — 32 headless tests** | [`logs/unit-tests.log`](logs/unit-tests.log) |
| Import | **pass — exit 0** | import ran before the probe on the same tree |
| Coverage | **not measured** — `gdtoolkit==4.5.0` absent in this container; logged, not claimed | [`logs/coverage.log`](logs/coverage.log) |
| Coding review (`review-code`) | **not run — correctly out of scope**: PR #841 contains no file under `game/`, `specs/`, `asset_catalog/`, or `game_assets/` | PR #841 file list |
