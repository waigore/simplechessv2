# AC readings — #334 acceptance, headless

Context and build id: `manifest.md`. Method: `notes.md`.

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
| AC6 — `mode-pick` additions-only; `locale` own name; marked set unchanged | pass — `locale` = `English` / `繁體中文` / `日本語`; `EVERY_LOCALE_ROWS` holds 13 rows = `mode-pick.locale` + 6 `shared-play` + 6 `puzzle-play` (the four-name rows the issue body described predate the six-name `L7`) |
| AC7 — `GS.locale` initialization/persistence unchanged by this task | pass — no code in this leaf touches it; PR #584 touches one test file |
| AC8 — `PTU-localization` S2/S3 readings for `puzzle-play` in all three locales | pass for the owner rows — table read above; screen readings cited from the graphical folder |
| **This run's verdict** | **accept** — every AC passes on evidence locatable in this repo |
