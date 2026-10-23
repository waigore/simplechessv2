# Schema: String table gate rules

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

The completeness-gate rules of [`SCH-string-table`](string-table.md), split per the rules' §Splitting. Fields are in [`string-table-fields.md`](string-table-fields.md).

## Fields

Moved to [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

The invariants the gate enforces are [`string-table-invariants.md`](string-table-invariants.md) §Invariants. These rules sit under them.

## Lifecycle

Moved to [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

None — rules over the F1–F5 rows.

## Diagram

None — one per-key loop over F2.

## Persistence

N/A — copy is compile-time and not saved (I7).

## Owner-addition rule

`_all_locales_populated` in `game/string_table_test.gd` is the only completeness gate; no second gate and no per-wave fork. The gate's owner list changes only in the change that adds an owner to F2; a change that adds no owner may still change the test body. **In-wave**, outside F2: I1, I3, I4 hold, while I2 and the varying-row part of I5 do not. **Shipped**, inside F2: all three locales are complete. An owner enters F2 only when its `zh-Hant` and `ja` values land. A half-translated owner satisfies neither state, so it fails I2 naming the owner and key.

## Key-column shapes

| Key column shape | Shipped cells | Read as |
|------------------|---------------|---------|
| bare identifier | `EX.loading` `loading` | an `exceptions` key |
| comma-separated bare identifiers | `EX.confirm` `confirm`, `cancel` | each entry is an `exceptions` key |
| `none` | `EX.interrupt` | no key |
| `owner.key` citation | `EX.error` | a citation; no `exceptions` key |
| bare names with a trailing `in <owners>` qualifier | `EX.promote` `choose_promotion` and the four piece names | each bare name is a citation in those owners; no `exceptions` key |

The derived set is `loading`, `confirm`, `cancel`, `unsupported_input`. `_read_exception_keys()` follows the shipped side: every shipped key must be named by the column, while a column entry the shipped table lacks adds no requirement, so the three absent keys stay out of F2.

## Marked-set rule

I5's carve-out is outside the owner-addition rule: in-wave checking never authorises a `zh-Hant` or `ja` value equal to `en`. The marked set is a constant of the nine key/owner pairs — `mode-pick.locale` and `queen`, `rook`, `bishop`, `knight` on `shared-play` and `puzzle-play` — cross-checked against the rows [Localization copy](../../ux/localization.md) L3 names; a disagreement names the pair (L3 means two row groups). `mode-pick.locale` is the own-name carve-out from `LOCALE_OWN_NAME`; `title` and `latest_state` stay outside it. A varying row equal to `en` fails `"%s.%s still English in %s"`; a drifted marked row fails `"%s.%s not en-equal in %s"`.

## Owner input and the all-owner set

F2 is the only owner input; F1 names the owner on each row and contributes no list. F2's order is display order; no consumer depends on it. Membership is a checked claim: `_owner_missing()` fails `"%s.%s missing in %s"` when an F2 owner lacks a key in a shipped locale, so I2 and I5 never pass vacuously. The all-owner set derives from the copy sources the gate reads — Copy tables in [`specs/ux/screens/`](../../ux/screens/) and the Key column of [`exceptions.md`](../../ux/exceptions.md) ([`CTR-localization`](../contracts/localization.md) G1) — cross-checked against F2.
