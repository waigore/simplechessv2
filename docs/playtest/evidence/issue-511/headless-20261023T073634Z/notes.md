# Headless notes — #511

Acceptance playtest for #511 (the string-table gate asserts same-in-every-locale rows) on build `e022f83`, which carries the deliverable merge `f44b535` (PR #519) and its prerequisite #483 (`289bce8`, PR #530).

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `python3 .github/scripts/gdscript_tests.py test` — 19 headless unit tests passed (`logs/unit-tests.log`)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`specs/view/glossary.md` `Diagram`) (`logs/spec-lint.log`)
- Coverage not measured locally: `gdtoolkit` 4.5.0 is not importable here; the `Coverage` job was green on PR #519's head and on `main`.
- `godot --headless --path game -s res://accept511_probe.gd` — exit 0, `ISSUE511_PROBE pass` (`logs/playtest-headless.log`)
- `godot --headless --path game` — headless smoke, exit 0 (`logs/headless-smoke.log`)

## Scope

The deliverable changes code and the four marked `shared-play` / `puzzle-play` piece rows (they had drifted to translated values and now render their `en` value), so playtesting applies. Mapping per [`procedures.md`](../../../../../specs/playtest/procedures.md):

- `PTU-localization` (UX, headless **and** graphical) covers the copy the change touches: S1/P1, P2, P4, P5 for the listed strings; S2/P3 is the marked `shared-play` `queen` row and is graphical-only by protocol.
- Design protocols are not in scope: the change alters no game rule, sequence, or score path.
- S3's five-screen, three-locale full listing is judged only for the marked rows and the screens the run reached (`mode-pick`, `shared-setup`, `shared-play`). Everything else in S3 is `not-judged` as outside the change's blast radius: the other rows' values are unchanged by this defect and are covered by the `SCH-string-table` completeness gate (`#483`), which is green.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| `PTU-localization` P1 — after the first `C4` activation the `locale` row reads `繁體中文`, every `mode-pick` string is its `zh-Hant` value, screen stays S1 | pass | `logs/playtest-headless.log` `MODE_PICK reading2`, `COPY mode-pick/reading2` |
| `PTU-localization` P2 — `title`, `shared`, `puzzle` differ in each of the three readings | pass | three `MODE_PICK` readings; `JUDGE P2 pass` |
| `PTU-localization` P4 — the `locale` row reads the live locale's own name, never `English` while `zh-Hant`/`ja` are live | pass | `English` / `繁體中文` / `日本語`; `JUDGE P4 pass` |
| `PTU-localization` P5 — every listed string is a Copy-table row value; no clipped label | pass | `COPY … unmatched=[]` for all three mode-pick readings and both shared-play states; no `CLIPPED` line |
| `PTU-localization` P3 (`shared-play` `queen` and the other three marked rows) | not-judged (headless) | protocol makes this row graphical only; the graphical twin judges it |
| Issue AC1/AC4 — marked rows equal their `en` value | pass | `game/string_table_test.gd` `_all_locales_populated`; the non-judged headless read still shows the rendered promote chooser as `Queen` `Rook` `Bishop` `Knight` |
| Issue AC2 — marked set is a constant, cross-checked against `L3`, failing with the pair named | pass | `logs/spec-cross-check.log` (9 pairs, `L3` + `I5` agree); `neg4` in `logs/gate-negative-cases.log` fails as `marked rows [...] disagree with L3's [...]` naming `shared-play.bishop` |
| Issue AC3 — `mode-pick.locale` is own-name identity, never `en` equality | pass | `logs/marked-rows-values.log` (synthesized `English`/`繁體中文`/`日本語`); `neg3` fails as `mode-pick.locale own name wrong in zh-Hant` |
| Issue AC5 — one negative case proves the assertion bites | pass | `neg1`: `shared-play.rook` → `車` in `zh-Hant` fails `shared-play.rook not en-equal in zh-Hant`, runner exit 1; the unmodified tree passes 19/19 |

## Gate-specific checks

- **Parity direction only** — the diff at `f44b535` adds the marked-row direction inside the existing `_all_locales_populated` loop and leaves the completeness checks alone; the shipped negative cases for `I1`/`I2`/`I4` still pass in `logs/unit-tests.log`.
- **Shipped values** — `logs/marked-rows-values.log` lists all eight piece rows in three locales; none differs from `en`.
- **`specs/` untouched** — `L3` (line 18, "Only two such rows exist") and `I5` are cited, not re-decided; the cross-check log quotes both and matches the constant.
- **Negative-case execution** — each case ran on a scratch copy of the tree (`game/` + `specs/` + `.github/scripts`, assets symlinked) so the checkout and `main` stayed clean; `logs/gate-negative-cases.log` records the mutation and the runner exit per case.

Display server was headless (`ENV.1`). Graphical twin: `../graphical-20261023T073634Z/`.
