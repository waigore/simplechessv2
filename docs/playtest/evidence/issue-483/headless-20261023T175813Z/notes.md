# Headless notes — #483

Acceptance playtest for #483 (record the string-table contract and extend the completeness gate the wave-2 copy leaves build on), on the merged deliverable build `c4fcb88` (PR [#631](https://github.com/waigore/simplechessv2/pull/631) head `fa23a7d` + `main` `63f744c`).

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `python3 .github/scripts/gdscript_tests.py test` — **22 headless unit tests passed** (`logs/unit-tests.log`)
- `python3 .github/scripts/gdscript_tests.py coverage` — **85.9% (3868/4504)**, threshold 80 (`logs/coverage.log`)
- `gdformat --check game` 50 files unchanged; `gdlint game` no problems (`logs/gdformat-check.log`, `logs/gdlint.log`)
- `python3 .github/scripts/spec_lint.py` — **0 errors, 1 pre-existing warning** (`specs/view/glossary.md`) (`logs/spec-lint.log`)
- `CHESS_SPECS_ROOT=<repo>/specs godot --headless --path game -s res://string_table_test.gd` — exit 0 (`logs/spec-cross-check.log`)
- `godot --headless --path game` — smoke, exit 0 (`logs/headless-smoke.log`)

## Scope

The deliverable changes the completeness gate and one schema sentence, and adds no player-facing string, so `PTU-localization` (UX) is the in-scope protocol. Judged headless here and graphical in the twin.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| P1 — first `C4` gives `繁體中文`, `zh-Hant` copy, still `mode-pick` | pass | `logs/playtest-headless.log` (`MODE_PICK` reading 2, `JUDGE P1 pass`) |
| P2 — `title`/`shared`/`puzzle` differ per locale | pass | three readings, `JUDGE P2 pass` |
| P4 — `locale` reads the live own name, never `English` | pass | `English` / `繁體中文` / `日本語`, `JUDGE P4 pass` |
| P5 — rendered mode-pick strings are Copy-table values | pass | rendered `title`/`shared`/`quit` equal `StringTable.mode_pick`, no raw key |
| F1 — no `FAIL.T13` miss | pass | 0 `locale.miss` telemetry events |
| S3/P5 — promotion-chooser `queen` row | judged in graphical twin | protocol's Graphical-only step |

## Gate checks (the deliverable)

- **Owner-set cross-check is non-vacuous (AC5).** `logs/gate-negative-cases.log` `neg1`: with the shipped→derived loop removed, the suite fails with `a dropped puzzle-play owner passed the owner-set cross-check` (exit 1). On the clean build the same suite is green (exit 0), and `_owner_set_negative_case()` drops `puzzle-play` on every run.
- **`neg2`**: an extra `ghost-play` Copy table that ships no suite fails the gate (exit 1). This direction is reached through the pre-existing `_spec_owner_keys` path, whose message has a known two-argument-into-one-slot formatting bug (present on `main`, unrelated to this PR); the gate still fails, so the owner-set guard is not the only teeth. Noted as a pre-existing copy nit, no defect filed.
- **`exceptions` subset read unchanged (AC5).** `_read_exception_keys()` still keeps only keys `_EXCEPTIONS` ships (`unsupported_input`); no string added.
- Fix, not re-measure, of the schema: `spec_lint.py` clean and every schema file under `WORD_LIMIT = 500`.

## Build note

The headless probe drives the playtest build with the smoke `PlaytestHarness` node removed (it quits on frame one under `ENV.1`); negative cases ran on scratch copies so the checkout stayed clean. Same approach as #511's evidence. The graphical twin drives the same build with the harness present and captures the screenshots.
