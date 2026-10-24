# Criteria derivations — #334 acceptance

Build: `origin/main` `d0e827d`, Godot `4.7.2.stable.official.ed1daf0bf`.
Every criterion was re-derived in this run on a clean detached worktree; the
implementation and verification comments were not taken as the verdict. Raw
output is in `logs/`.

## AC1 — key set

Parsed the `## Copy` table's Key column from `specs/ux/screens/puzzle-play.md`:
exactly 21 keys, `cue_failed` included (`logs/copy-table-keys.txt`). Parsed
`_PUZZLE_PLAY` from `game/string_table.gd`: 21 keys in each of `en`, `zh-Hant`,
`ja`. Set difference in both directions is empty. `mode-pick.puzzle` reads
Puzzle stream / 謎題串流 / パズルストリーム.

## AC2 — C4 switch

No per-screen cache is introduced; `CTR-localization` G2 is untouched and this
task adds values only. The rendered reading is #550's `PTU-localization` pass
(see `notes.md`), not re-run here.

## AC3 — varying vs marked rows

The 17 varying keys are not verbatim `en` copies; the four L3 piece rows
(`queen`, `rook`, `bishop`, `knight`) stay `en`-equal by marking. Proven
non-vacuous by mutations 2 and 3 in `logs/negative-cases.txt`.

## AC4 — no cross-owner resolution

`_PUZZLE_PLAY` carries its own rows for all ten shared bare names: `queen`,
`rook`, `bishop`, `knight`, `choose_promotion`, `refused_place`, `confirm`,
`cancel`, `dismiss`, `save_failed`.

## AC5 — non-vacuity, the point of the leaf

Four states reproduced by mutation, each reverted and diffed clean:

| State | Required | Observed |
|---|---|---|
| Unmutated shipped suite | pass | 28 headless tests passed |
| `cue_failed` empty in `zh-Hant` | fail | `puzzle-play.cue_failed missing in zh-Hant` |
| `reveal` in `ja` set to `Reveal` | fail | `puzzle-play.reveal still English in ja` |
| `knight` in `ja` set to `Knight` (marked row) | pass | 28 headless tests passed |

PR #584's only changed file is `game/string_table_test.gd`; no `specs/` text was
edited by this task, matching "no schema text is edited here".

## AC6 — `mode-pick` additions-only

`EVERY_LOCALE_ROWS` on `main` has `mode-pick: ["locale"]`, and `shared-play` and
`puzzle-play` with the four piece rows. `mode-pick.locale` remains the own-name
row; no fifth marked row exists.

## AC7 — `GS.locale`

No locale initialization or persistence code is touched by this task.

## AC8 — scope of the playtest half

The body's `## Preconditions` draws the line: the `UI-puzzle-play` per-locale
run, the C4-switch-reads-puzzle-copy check, and the ~40% growth cover over
R2–R3 / S2–S5 "all need that panel. They are **#333's evidence**, not an AC of
this task."

| Evidence on `main` | Covers | Verdict |
|---|---|---|
| `issue-550/headless-20261024T000000Z/` | `PTU-localization` P2 / P5 | pass |
| `issue-550/graphical-20261024T000000Z/` | `PTU-localization` P1 / P2; screenshots `01`–`03` walk `en` → `zh-Hant` → `ja` on mode-pick | **pass** |

## Checks

- `gdscript_tests.py test` — 28 passed.
- `gdlint game` — no problems; `gdformat --check game` — 62 files unchanged.
- `spec_lint.py` — 0 errors, 1 pre-existing warning (`specs/view/glossary.md`
  duplicate `Diagram`), unrelated to this task.
- `gdscript_tests.py coverage` was not re-measured: it refuses when gdtoolkit is
  not importable by the script's interpreter here. CI's `Coverage` ran SUCCESS on
  PR #584's head (`cbff807`), the same tree.
