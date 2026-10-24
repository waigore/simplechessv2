# String-table gate: negative cases and live-body checks

Evidence for #495 (implement pass). Companion to the implementing comment.

## Test run

- `GODOT_BIN=/opt/homebrew/bin/godot CHESS_SPECS_ROOT="$PWD/specs" python3 .github/scripts/gdscript_tests.py test` on `main` `5864e45` plus this branch: **25 headless unit test(s) passed**.
- `python3 .github/scripts/spec_lint.py`: **0 errors, 1 warning** — the pre-existing `specs/view/glossary.md:14` diagram glossary warning.

## Negative cases the shipped test exercises (`_copy_gate_negative_cases()`)

| Mutation | Expected message | Result |
|----------|------------------|--------|
| drop `puzzle-play.cue_failed` in `zh-Hant` | `puzzle-play.cue_failed missing in zh-Hant` | fails, names `owner.key` |
| copy a varying `puzzle-play` key from `en` | `puzzle-play.<key> still English in <locale>` | fails |
| copy a marked piece row (`queen`…) from `en` | none | passes |

## In-wave orientation — not demonstrable in code yet

The rule's in-wave state (an `en`-only owner outside F2 is checked by `I1`/`I3`/`I4` only) cannot run as code while the gate reads the shipped suites as it does: `_all_locales_suites()` and `_all_locales_populated()` already loop every shipped owner through `_owner_missing()`, so every shipped owner is checked as shipped. Per the issue's acceptance criteria, no scratch harness is invented and no AC requires an F2-scoped read; the in-wave state becomes executable in the change that makes the gate read F2 (#483's delivered mechanism, extended by whoever adds the owner).

## Relationships lines (deviation note)

The schema changelog in #495 names two `Relationships` lines — `string-table-invariants.md` ("F2 orders the owners." → landed) and a note in `string-table-fields.md` ("F2 enumerates the owners."). On `main` `5864e45` a third occurrence exists: `string-table-fields-rules.md` line 27, "F2 enumerates the owners." It is the same claim, so it was updated in the same change rather than left contradicting F2's new note. `string-table-fields.md`'s own `Relationships` line was updated as named; its intro line was also updated to point at the new gate file, because the §Completeness-gate text moved out of `string-table-fields-rules.md`.

## Word counts as landed (`len(text.split())`)

| File | Before | After |
|------|--------|-------|
| `specs/technical/schemata/string-table.md` | 111 | 122 |
| `specs/technical/schemata/string-table-fields.md` | 210 | 240 |
| `specs/technical/schemata/string-table-fields-rules.md` | 414 | 425 |
| `specs/technical/schemata/string-table-invariants.md` | 373 | 456 |
| `specs/technical/schemata/string-table-gate.md` | — | 500 |
| `specs/ux/exceptions.md` | 495 | 495 (unchanged) |
