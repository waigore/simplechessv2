# Manifest — #655 implementation re-run #10 (2026-10-25, parallel id 1)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Environment**: `headless` (`ENV.1`) for the probe, the import, and the unit suite; the published leg is a read of the published artefact's identity only (see *Published leg*).
- **Build / session id**: clean detached worktree of `origin/main` **`5c15e80`** ("Record the #753 acceptance run (headless + graphical) (#825)"), Godot `4.7.2.stable.official.ed1daf0bf`; **`TEL.3` `sess-1792868748148-67330-playtest-215430`**.
- **Published artefact** (read, not driven this pass): `index.pck` `last-modified: Sat, 24 Oct 2026 17:57:05 GMT`, `content-length: 9568028`, `etag: "6adcf171-91ff1c"` — the same artefact `review-20261025T022500Z` drove.
- **Coverage mode**: `critical-only`.
- **Repeat count**: 1 probe run, 1 import, 1 unit-suite run. The probe output is **byte-identical** to [`../review-20261025-impl9/logs/x655-probe.log`](../review-20261025-impl9/logs/x655-probe.log) on a different commit (`ce8a156` → `5c15e80`).

## Results

| Criterion | Verdict on `5c15e80` | Evidence |
|---|---|---|
| 1 — a `specs/` sentence states the catalog route's release status, with its commit | **pass** — landed `a94210d` (PR #815) | [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log), [`logs/landed-648.md`](logs/landed-648.md) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** | `X655 B5 endpoint=<> key_set=false is_available=false`; `game/session_router.gd:33-34` |
| 3 — one named outcome (`K1` dealt **or** committed `F-puzzle-catalog.X2`) | **fail** | `X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>` |
| 4 — absence recorded as `FAIL.T14` | **holds as an observable** | Elo 1000.00 before/after, no pid, `last_failure=<status>`, `deal read failed (status)` ×2 in the run log |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** | `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass` |
| 6 — published rows with build / session id, or **held** | **fail — not held.** #648's sentence has landed, so the held clause is spent; measured refusal is client-side, inside `B5` | [`logs/published-and-550.log`](logs/published-and-550.log); `review-20261025T022500Z` |
| 7 — `#550` manifest rows | **holds, unchanged** — sweep has not re-run; `Defects` line still names #655 | [`logs/published-and-550.log`](logs/published-and-550.log) |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — this folder adds only evidence | diff scope |
| 9 — #332 / #333 / #335 relationship, no native edge | **holds** — no edge added or implied | — |
| Unit suite | **pass — 31 headless tests** | [`logs/unit-tests.log`](logs/unit-tests.log) |
| Import | **pass — exit 0** | [`logs/import.log`](logs/import.log) |
| Coverage | **not measured** — `gdtoolkit==4.5.0` absent in this container | [`logs/coverage.log`](logs/coverage.log) |

Protocols on this build: `PTD-puzzle-stream` **fail** (K1), `PTU-puzzle-play` **fail** (US1), `PTU-puzzle-session` **pass** (S2–S3).

## Paths

- [`logs/x655-probe.log`](logs/x655-probe.log) — probe verdict lines
- [`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log) — same run's stdout (`TEL.1`–`TEL.5`, refusal backtrace)
- [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log) — build identity, criterion-1 sentence and its commit, the empty `T9`/`T10` assignments
- [`logs/published-and-550.log`](logs/published-and-550.log) — published artefact identity, `B5`, the `#550` manifest rows
- [`logs/unit-tests.log`](logs/unit-tests.log), [`logs/coverage.log`](logs/coverage.log), [`logs/import.log`](logs/import.log)
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the unchanged probe from `review-20261025-impl9`
- [`notes.md`](notes.md) — what moved since the verify fail, and what did not
- Screenshots: **none** — headless-only run; the published-build captures live in [`../review-20261025T022500Z/screenshots/`](../review-20261025T022500Z/screenshots/)
