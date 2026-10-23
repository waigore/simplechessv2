# Schema: String table gate

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

Gate rules of [`SCH-string-table`](string-table.md).

## Fields

In [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

In [`string-table-invariants.md`](string-table-invariants.md) §Invariants, with the `I2`, `I3`, and `I5` copies in [`string-table-fields-rules.md`](string-table-fields-rules.md) §Invariants.

## Lifecycle

In [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

F2 lists the owners. Consumed through [`CTR-localization`](../contracts/localization.md).

## Diagram

None.

## Persistence

N/A — compile-time, not saved (I7).

## Owner-addition rule

`game/string_table_test.gd` and its owner list belong to `SCH-string-table`; `_all_locales_populated()` is the single completeness mechanism, with no second gate, per-wave fork, or hard-coded owner list. The owner list changes only with an addition to F2; other changes may still edit the test body.

An owner is in one of two states. In-wave — outside F2 — `I1`, `I3`, and `I4` hold, and `I2` and the varying-row part of `I5` do not apply. Shipped — inside F2 — all three locales are complete. An owner enters F2 only in the change that lands its `zh-Hant` and `ja` values. A half-translated owner is neither state and fails `I2`, naming the owner and key.

## Gate-input rule

F2 is the only owner input: one enumerated row — `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, `exceptions`, `puzzle-play` — meaning every owner whose three locales are complete. F1 names the owner per row and contributes no list. `L1` names the one change that may add a member.

F2 membership is a checked claim: `_owner_missing()` fails with `"%s.%s missing in %s"` when an F2 owner lacks a key in any shipped locale, so `I2` cannot pass vacuously. `I5` reports `"%s.%s still English in %s"` for an unmarked row equal to `en` and `"%s.%s not en-equal in %s"` for a drifted marked row; only the missing-value case under `I1`, `I2`, and `I4` says `missing in`.

The all-owner set comes from the Copy tables the gate reads — `specs/ux/screens/*.md`, a screen owning only its own `## Copy` table — plus the `exceptions` Key column of [`exceptions.md`](../../ux/exceptions.md) (`CTR-localization` G1). A bare Key-column identifier (`EX.loading`) is an `exceptions` key, as is each comma-separated entry (`EX.confirm`); `none`, `owner.key` citations, and bare names scoped by a trailing `in shared-play and puzzle-play` qualifier (`EX.promote`) contribute none. The derived set is `loading`, `confirm`, `cancel`, `unsupported_input`.

The gate follows the shipped side (`_read_exception_keys()`): every shipped `exceptions` key must be named by the column, while a column entry the shipped table lacks adds no requirement. The three absent keys are not added to F2 — `I5` rejects `en` copies.

## Marked-set constant rule

`I5`'s same-in-every-locale carve-out sits outside the owner-addition rule; in-wave checking never authorises a `zh-Hant` or `ja` value equal to `en`. The marked set is a constant of nine key/owner pairs (`mode-pick.locale`, `queen`, `rook`, `bishop`, `knight` on `shared-play` and `puzzle-play`) cross-checked against `L3`'s rows, disagreement naming the pair (`_marked_rows_match_l3()`); `L3`'s "two such rows" means two row groups. `mode-pick.locale` is the own-name carve-out from `LOCALE_OWN_NAME` (`_locale_own_names()`), not a stored `I5` row; `title` and `latest_state` stay outside it. A hard-coded marked list is permitted, not a second owner list. The constant and `_no_english_leak_in_puzzle_play`'s fate stay #483's.
