# Schema: String table invariants

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

Invariants and lifecycle of [`SCH-string-table`](string-table.md), split per the rules' §Splitting. Fields are in [`string-table-fields.md`](string-table-fields.md); the copy rules are in [`string-table-fields-rules.md`](string-table-fields-rules.md); the gate rules are in [`string-table-gate.md`](string-table-gate.md).

## Fields

Moved to [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | `en` has a value for every key of every owner; `en` is the source of truth |
| I2 | `zh-Hant` and `ja` have a value for every `en` key of every F2 owner; a key missing in either fails, naming the owner and key (L1) |
| I3 | An owner's key set is exactly the Key column of its Copy table, or of [`exceptions.md`](../../ux/exceptions.md) for `exceptions`, in table order; no extra key, no missing key |
| I4 | No value equals its key (that would render a raw identifier) |
| I5 | A `zh-Hant` or `ja` value is not a verbatim copy of its `en` value, except a row marked same in every locale (`UI-mode-pick.C4` own name; `shared-play` / `puzzle-play` `queen` `rook` `bishop` `knight`, per [Localization copy](../../ux/localization.md) L3); every other F2 row fails when its value equals `en`, naming the owner and key (L1) |
| I6 | Each value's glyphs resolve in the shipped font chain ([`AK-fonts.V1`](../../assets/kinds/fonts.md)) for its locale |
| I7 | Copy is not a persist field ([`fields-persist`](../../design/game-state/fields-persist.md)); no string is saved |

## Lifecycle

| ID | Phase | Who acts | What changes |
|----|-------|----------|--------------|
| L1 | Create | Developer, for a new owner | Add F1 with every key and an `en` value (I1, I3, I4); the owner enters F2 in the change that adds its `zh-Hant` and `ja` values (I2, I5). F2 membership asserts all three locales are complete for the owner, and the gate fails, naming the owner and key, when an F2 owner is missing a key |
| L2 | Read | [`CMP-presentation`](../components/presentation.md) | Resolve a key for the current locale |
| L3 | Update | Developer, when a Copy table changes | Add, remove, or change the entry in every locale in the same change; key set follows I3 |
| L4 | Destroy | Developer, when a screen is removed | Remove the owner from F1 and F2 together; leave no orphan key |

## Relationships

- One owner to many keys: many-to-one. F2 lists the owners whose three locales are complete, in display order; no consumer depends on it.
- Consumed through [`CTR-localization`](../contracts/localization.md); reads `GS.locale` per [`CMP-session-router`](../components/session-router.md) R5.

## Diagram

None — flat key/value map. A missing key, a value equal to its key, or a verbatim `en` copy fails I2, I4, or I5 ([`FAIL.T13`](../failures.md)).

## Persistence

N/A — copy is compile-time, not saved (I7).
