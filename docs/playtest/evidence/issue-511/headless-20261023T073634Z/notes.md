# Headless notes — #511

Acceptance playtest for #511 (the string-table gate asserts same-in-every-locale rows) on build `e022f83`, which carries the deliverable merge `f44b535` (PR #519) and its prerequisite #483 (`289bce8`, PR #530).

## Prep

- `godot --headless --path game --import --quit` — exit 0 (`logs/import.log`)
- `python3 .github/scripts/gdscript_tests.py test` — 19 headless unit tests passed (`logs/unit-tests.log`)
- `python3 .github/scripts/spec_lint.py` — 0 errors, 1 pre-existing warning (`logs/spec-lint.log`)
- Coverage not measured locally (`gdtoolkit` absent here); the `Coverage` job was green on PR #519 and `main`.
- `godot --headless --path game -s res://accept511_probe.gd` — exit 0, `ISSUE511_PROBE pass` (`logs/playtest-headless.log`)
- `godot --headless --path game` — smoke, exit 0 (`logs/headless-smoke.log`)

## Scope

The deliverable changes code and the four marked `shared-play` / `puzzle-play` piece rows, so playtesting applies: `PTU-localization` (UX, headless **and** graphical), S1/S2 and P1–P5. Design protocols are not in scope — no rule, sequence, or score path changed. S3's five-screen full listing is judged for the marked rows and the screens reached; the rest is unchanged by this defect and covered by #483's green completeness gate.

## Judgement (headless)

| ID | Outcome | Evidence |
|----|---------|----------|
| P1 — first `C4` gives `繁體中文`, `zh-Hant` copy, still S1 | pass | `MODE_PICK reading2`, `COPY mode-pick/reading2` |
| P2 — `title`/`shared`/`puzzle` differ per locale | pass | three readings, `JUDGE P2 pass` |
| P4 — `locale` reads the live own name | pass | `English` / `繁體中文` / `日本語`, `JUDGE P4 pass` |
| P5 — listed strings are Copy-table values, none clipped | pass | `COPY … unmatched=[]` on all five dumps, no `CLIPPED` line |
| P3 — marked piece rows | not-judged headless | protocol makes it graphical only; graphical twin judges it |
| AC1/AC4 — marked rows equal `en` | pass | `game/string_table_test.gd` `_all_locales_populated`; rendered chooser reads `Queen`/`Rook`/`Bishop`/`Knight` |
| AC2 — marked set is a constant cross-checked against `L3` | pass | `logs/spec-cross-check.log` (9 pairs, `L3` + `I5` agree); `neg4` names `shared-play.bishop` |
| AC3 — `locale` is own-name identity, never `en` | pass | `logs/marked-rows-values.log`; `neg3` fails `mode-pick.locale own name wrong in zh-Hant` |
| AC5 — a negative case proves the assertion bites | pass | `neg1`: `shared-play.rook` → `車` fails `not en-equal in zh-Hant`, exit 1; clean tree passes 19/19 |

## Gate-specific checks

- **Parity direction only** — the added branch sits inside the existing `_all_locales_populated` loop; completeness cases still pass (unit-test log).
- **Shipped values** — `logs/marked-rows-values.log` lists all eight piece rows in three locales; none differs from `en`.
- **`specs/` untouched** — `L3` (line 18) and `I5` are cited, not re-decided; the cross-check quotes both.
- **Negative cases** ran on scratch copies (`game/` + `specs/` + `.github/scripts`, assets symlinked), so the checkout stayed clean; `logs/gate-negative-cases.log` records each mutation and runner exit.

Display server was headless (`ENV.1`). Graphical twin: `../graphical-20261023T073634Z/`.
