# Manifest

- **Issue**: 334 — Localize the wave-2 puzzle copy in en, zh-Hant, and ja
- **Environment**: headless (`ENV.1`). The graphical requirement is covered by citing the earlier repo folder `../graphical-20261025Tpar1/` (merged via PR #867); this run is not a graphical run.
- **Build / session id**: Godot `4.7.2.stable.official.ed1daf0bf`, clean detached worktree of `origin/main` `ad9c04d` (PR #584 merge commit `a384c4c` and the #868 fix `589ed41` are ancestors). No playtest build was launched; the session-level probe `TEL.3` is **not claimed**.
- **Coverage mode**: `full`, intersected with this leaf's scope: UX `PTU-localization` only (`specs/playtest/ux/localization.md`). `PTU-puzzle-play`, the growth layout, and the C4-on-the-puzzle-screen reading remain #333's evidence per the issue body's `## Preconditions`.
- **Story-row source**: the protocol file's own `Cites` rows (`UI-mode-pick.US1`, `LOC.US1`).
- **Defects**: none opened by this run (see `notes.md` Findings 1–2 — recorded, filed nowhere).
- **Screenshots**: `screenshots/` is carried by the cited graphical folder, not this one.

## Results

| Protocol / row | Result |
|----------------|--------|
| AC1 — every `puzzle-play` Copy-table key + `mode-pick.puzzle` resolves in `en`/`zh-Hant`/`ja`, non-empty, not key-equal | pass — spec parse and shipped table both 23 keys, both set differences empty; 17 varying keys and 6 marked, all non-empty and not key-equal; `mode-pick.puzzle` = `Puzzle stream` / `謎題串流` / `パズルストリーム` |
| AC2 — `UI-mode-pick.C4` switches copy immediately (this leaf's scope: values only) | pass for the copy this leaf owns — owner rows re-read here; the rendered cycle is cited from `../graphical-20261025Tpar1/` `S1` (P1/P2/P3) |
| AC3 — 17 varying keys are not verbatim `en` copies; the six `L7` marked piece rows stay `en`-equal | pass — zero `en` copies over the 17; `pawn king queen rook bishop knight` equal `en` in all three locales |
| AC4 — `puzzle-play` carries its own rows for the shared bare names, no cross-owner resolution | pass — independent rows in `_PUZZLE_PLAY`; reads go through `StringTable.puzzle_play` only |
| AC5 — owner recorded as shipped in the gate | pass — `puzzle-play` in `_all_locales_suites` (six owners); parity gate reads Copy tables through `CHESS_SPECS_ROOT` since #483; `string-table-fields.md` F2 names all six |
| AC5 — gate non-vacuity, unmutated owner | pass — `string_table_test.gd` green (shipped suite passes its own gate, first assertion of `_copy_gate_negative_cases`) |
| AC5 — removing a `zh-Hant` key fails naming `puzzle-play.<key>` | pass — emptied `cue_failed` in `ja` (see `logs/mutation-missing.log`) |
| AC5 — an `en`-copied varying key fails naming `puzzle-play.<key>` | pass — disarmed the I5 varying branch; suite reds `an en-copied varying key passed the gate` (`logs/mutation-i5-disarmed.log`) |
| AC5 — an `en`-copied marked piece row passes | pass — the third assertion inside the shipped `_copy_gate_negative_cases` |
| AC6 — `mode-pick` additions-only; `locale` own name; marked set unchanged | pass — `locale` = `English` / `繁體中文` / `日本語`; `EVERY_LOCALE_ROWS` holds 13 rows = `mode-pick.locale` + 6 `shared-play` + 6 `puzzle-play` (the four-name rows the issue body described predate the six-name `L7`)
| AC7 — `GS.locale` initialization/persistence unchanged by this task | pass — no code in this leaf touches it; PR #584 touches one test file |
| AC8 — `PTU-localization` S2/S3 readings for `puzzle-play` in all three locales | pass for the owner rows — table read above; screen readings cited from the graphical folder |
| **This run's verdict** | **accept** — every AC passes on evidence locatable in this repo |

## Paths

- `notes.md`
- `probe/accept334_probe.gd` — independent reader of the shipped getters (re-run from this copy produces `logs/probe-values.log`)
- `probe/runner.gd` — the wrapper that runs the shipped gate document
- `logs/probe-values.log`, `logs/copy-gate.log`
- `logs/unit-tests.log` — 33 passed
- `logs/mutation-missing.log`, `logs/mutation-i5-disarmed.log` — the two mutation runs
- `../graphical-20261025Tpar1/` — the cited graphical `PTU-localization` run and its screenshots
