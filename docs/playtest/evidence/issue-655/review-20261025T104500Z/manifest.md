# Manifest — #655 implementation re-run #11 (2026-10-25, parallel id 3)

- **Issue**: #655 — Puzzle stream deals nothing on the shipped-path build: `T9`/`T10` are unset (`type:defect`)
- **Environment**: `headless` (`ENV.1`) for the probe, the import, and the unit suite; the published leg is a read of the artefact's identity.
- **Build / session id**: clean detached worktree of `origin/main` **`6a969ee`** ("Record the #478 wave-1 playtest sweep on one playtest build (#836)"), Godot `4.7.2.stable.official.ed1daf0bf`; **`TEL.3` `sess-1792873135319-1941-playtest-242597`**.
- **Judged under**: the catalog enabled in the release branch (the #648 answer). Sentences: `specs/technical/configuration.md:43` (`B5`, landed `a9192a0`, PR #822) and `specs/technical/components/catalog-service.md:56` (landed `a94210d`, PR #815) — see [`verdicts.md`](verdicts.md).
- **Published artefact** (read, not driven): `index.pck` `etag: "6adcf171-91ff1c"`, `last-modified: 2026-10-24 17:57:05 GMT`, `content-length: 9568028` — unchanged since `review-20261025T022500Z` ([`logs/published-identity.log`](logs/published-identity.log)).
- **Coverage mode**: `critical-only`. **Repeat count**: 1 probe, 1 import, 1 unit suite; probe verdict lines byte-identical to [`../review-20261025-impl10/logs/x655-probe.log`](../review-20261025-impl10/logs/x655-probe.log).
- **Screenshots**: none — headless-only. Published-build captures live in [`../review-20261025T022500Z/screenshots/`](../review-20261025T022500Z/screenshots/).

## Results

| Criterion | Verdict on `6a969ee` | Evidence |
|---|---|---|
| 1 — quote the release-status sentence with its commit | **pass** | [`verdicts.md`](verdicts.md), [`logs/criterion1-2-3-grep.log`](logs/criterion1-2-3-grep.log) |
| 2 — no refusal is `B5`'s empty-value guard | **fail** | `is_available=false`, `endpoint=<>`, `key_set=false` |
| 3 — one named outcome (`K1` **or** `F-puzzle-catalog.X2`) | **fail** | `state=S1`, no pid, never leaves `B5` |
| 4 — absence recorded as `FAIL.T14` | **holds** | Elo `1000.00` unchanged, no pid, `last_failure=<status>` ([`logs/x655-probe-stdout.log`](logs/x655-probe-stdout.log)) |
| 5 — `C5` → `EX.confirm` → Cancel on `S1` | **pass** | `X655_PROBE pass`, `X655 ROUTER_JOURNEY pass` ([`logs/x655-probe.log`](logs/x655-probe.log)) |
| 6 — published rows, or **held** | **fail, not held** | [`held.md`](held.md) |
| 7 — `#550` manifest rows + `Defects` line | **unchanged** | [`logs/published-and-550.log`](logs/published-and-550.log) |
| 8 — no `specs/`/asset change; `game/` only under item 4 | **holds** — evidence only | diff scope |
| 9 — #332 / #333 / #335 relationship | **holds** — no edge | — |
| Unit suite | **pass — 32 tests** | [`logs/unit-tests.log`](logs/unit-tests.log) |
| Import | **pass — exit 0** | [`logs/import.log`](logs/import.log) |
| Coverage | **not measured** — `gdtoolkit==4.5.0` absent | [`logs/coverage.log`](logs/coverage.log) |

Protocols on this build: `PTD-puzzle-stream` **fail** (`K1`), `PTU-puzzle-play` **fail** (`US1`), `PTU-puzzle-session` **pass** (`S2`–`S3`).

## Paths

- [`verdicts.md`](verdicts.md) — criterion 1 quotation, the `C5` attribution, and the #550 / edge notes
- [`held.md`](held.md) — the criterion-6 held clause: why it is spent, and where the fix belongs
- [`notes.md`](notes.md) — what moved since the verify fail on `8af7f8f`
- [`logs/`](logs/) — probe lines and stdout, greps, identity, unit/coverage/import
- [`probe/x655_confirm_probe.gd`](probe/x655_confirm_probe.gd) — the probe, unchanged from `review-20261025-impl10`
