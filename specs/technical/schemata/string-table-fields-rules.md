# Schema: String table copy rules

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

The rules [`SCH-string-table`](string-table.md) carries for its copy. The `F1`–`F5` fields are in [`string-table-fields.md`](string-table-fields.md); the `I1`–`I7` invariants and the lifecycle are in [`string-table-invariants.md`](string-table-invariants.md).

## Fields

In [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

| ID | Invariant |
|----|-----------|
| I2 | `zh-Hant` and `ja` have a value for every `en` key of every F2 owner; a key missing in either fails, naming the owner and key (L1) |
| I3 | An owner's key set is exactly the Key column of its Copy table, or of [`exceptions.md`](../../ux/exceptions.md) for `exceptions`, in table order; no extra key, no missing key |
| I5 | A `zh-Hant` or `ja` value is not a verbatim copy of its `en` value, except a row marked same in every locale (`UI-mode-pick.C4` own name; `shared-play` / `puzzle-play` `queen` `rook` `bishop` `knight`, per [Localization copy](../../ux/localization.md) L3); every other F2 row fails when its value equals `en`, naming the owner and key (L1) |

The remaining invariants are in [`string-table-invariants.md`](string-table-invariants.md) §Invariants.

## Lifecycle

In [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

- One owner to many keys: many-to-one. F2 lists the owners whose three locales are complete, in display order; no consumer depends on it.
- Rows are consumed through [`CTR-localization`](../contracts/localization.md).

## Diagram

None — flat key/value map; the rules do not need one.

## Persistence

N/A — copy is compile-time and not saved (I7).

## Sharing across owners

A key's qualified name is its owner plus its key, and the Copy table is the only copy source ([Localization copy](../../ux/localization.md) L1 L2; [`CTR-localization`](../contracts/localization.md) G1). So a bare name may repeat across owners and resolution never crosses owners: `shared-play` `confirm` and `puzzle-play` `confirm` are different keys with their own values. Owners and keys come from the F1 rows; F1 adds no owner list.

## Missing keys

A key missing in a locale reads `en` and logs once per owner and key; play continues ([`configuration.md`](../configuration.md) B4; [`FAIL.T13`](../failures.md)). This schema adds no second outcome.

## Completeness gate

In [`string-table-gate.md`](string-table-gate.md) §Owner-addition rule; the `exceptions` Key column is read as a subset of the shipped keys (§Key-column shapes). It is the only copy-completeness gate, and a playtest protocol observes the same keys as a player (I2).

## Same in every locale

A marked row renders its `en` value in all three locales. The marked set is exactly [Localization copy](../../ux/localization.md) L3's rows, and L3 stays its source of truth. The screens mark those rows as a sentence in their Copy table, so the marker is prose: no Copy-table field, no schema change, and no third exception exists. As a constant the gate holds it per [`string-table-gate.md`](string-table-gate.md) §Marked-set constant rule.
