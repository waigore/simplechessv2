# Schema: String table gate rules

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

Gate rules of [`SCH-string-table`](string-table.md). Fields: [`string-table-fields.md`](string-table-fields.md). Invariants and lifecycle: [`string-table-invariants.md`](string-table-invariants.md). `I2`/`I5` copies: [`string-table-fields-rules.md`](string-table-fields-rules.md).

## Fields

In [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

In [`string-table-invariants.md`](string-table-invariants.md) §Invariants, with the `I2`/`I5` copies.

## Lifecycle

In [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

F2 lists the owners; consumed through [`CTR-localization`](../contracts/localization.md).

## Diagram

None — one per-key loop over F2.

## Persistence

N/A — compile-time, not saved (I7).

## Owner-addition rule

`game/string_table_test.gd` and its owner list belong to `SCH-string-table`; `_all_locales_populated()` is the single completeness mechanism, with no second gate, per-wave fork, or hard-coded owner list. That list changes only with an F2 addition; other edits may change the test body.

An owner has two states. In-wave — outside F2 — `I1`, `I3`, and `I4` hold; `I2` and the varying-row part of `I5` do not. Shipped — inside F2 — all three locales are complete. An owner enters F2 only when its `zh-Hant` and `ja` values land; a half-translated owner is neither state and fails `I2`, naming the owner and key.

## Gate-input rule

F2 is the only owner input: one enumerated row — `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, `exceptions`, `puzzle-play` — meaning every owner whose three locales are complete. Its order is display order; no consumer depends on it. F1 names the owner per row and contributes no list. `L1` names the change that may add a member.

F2 membership is checked: `_owner_missing()` fails with `"%s.%s missing in %s"` when an F2 owner lacks a key in any shipped locale, so `I2` cannot pass vacuously. `I5` reports `"%s.%s still English in %s"` for an unmarked row equal to `en`, and `"%s.%s not en-equal in %s"` for a drifted marked row; only a missing value (`I1`, `I2`, `I4`) says `missing in`.

The all-owner set is the Copy tables the gate reads — `specs/ux/screens/*.md`, a screen owning only its `## Copy` table — plus the `exceptions` Key column of [`exceptions.md`](../../ux/exceptions.md) (`CTR-localization` G1), cross-checked against F2. Shapes: a bare identifier (`EX.loading` `loading`) or comma-separated entry (`EX.confirm` `confirm`, `cancel`) is an `exceptions` key; `none` (`EX.interrupt`), `owner.key` citations (`EX.error`), and names scoped by a trailing `in shared-play and puzzle-play` qualifier (`EX.promote`) contribute none. The derived set: `loading`, `confirm`, `cancel`, `unsupported_input`.

The gate reads the shipped side (`_read_exception_keys()`): every shipped `exceptions` key must be named by the column, while a column entry the shipped table lacks adds no requirement; the absent keys stay out of F2, since `I5` rejects `en` copies.

## Marked-set constant rule

The `I5` carve-out is outside the owner-addition rule; in-wave checking never authorises an `en`-equal `zh-Hant` or `ja` value. The marked set is a constant of 13 key/owner pairs (`mode-pick.locale`; the six piece keys `L9` maps on `shared-play` and `puzzle-play`) cross-checked against `L7`'s rows; a mismatch names the pair (`_marked_rows_match_l3()`). `mode-pick.locale` is the own-name carve-out from `LOCALE_OWN_NAME` (`_locale_own_names()`), not a stored `I5` row; `title` and `latest_state` stay outside it. A hard-coded marked list is allowed, not a second owner list. The constant and `_no_english_leak_in_puzzle_play`'s fate stay #483's.
