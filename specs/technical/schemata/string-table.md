# Schema: String table

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object — compile-time copy for one copy owner, all shipped locales
- **Owner**: [`CMP-presentation`](../components/presentation.md)
- **Serves**: [quality.md](../../definition/quality.md) Localization; [Localization copy](../../ux/localization.md)
- **Informed by**: [`specs/ux/screens/`](../../ux/screens/) Copy tables; [`configuration.md`](../configuration.md) S4 B4
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

## Fields

| ID | Name | Type | Required | Notes |
|----|------|------|----------|-------|
| F1 | owner | copy owner id | yes | A screen such as `puzzle-play`, or `exceptions`, keyed by [`exceptions.md`](../../ux/exceptions.md) |
| F2 | namespaces | ordered owner ids | yes | The complete owner set and the order that forms `CTR-localization` O1 |
| F3 | locale | enum `en` `zh-Hant` `ja` | yes | Shipped locales; `en` is the source |
| F4 | key | snake_case string | yes | Per [Localization copy](../../ux/localization.md) L1 |
| F5 | value | string | yes | The recorded Copy-table string for that key, in that locale; never empty, never the bare key |

## Invariants

| ID | Invariant |
|----|-----------|
| I1 | `en` has a value for every key of every owner; `en` is the source of truth |
| I2 | `zh-Hant` and `ja` have a value for every `en` key; no key is missing in any shipped locale |
| I3 | An owner's key set is exactly the Key column of its Copy table, or of [`exceptions.md`](../../ux/exceptions.md) for `exceptions`, in table order; no extra key, no missing key |
| I4 | No value equals its key (that would render a raw identifier) |
| I5 | A `zh-Hant` or `ja` value is not a verbatim copy of its `en` value, except a row marked same in every locale (`UI-mode-pick.C4` own name; `shared-play` / `puzzle-play` `queen` `rook` `bishop` `knight`, per [Localization copy](../../ux/localization.md) L3) |
| I6 | Each value's glyphs resolve in the shipped font chain ([`AK-fonts.V1`](../../assets/kinds/fonts.md)) for its locale |
| I7 | Copy is not a persist field ([`fields-persist`](../../design/game-state/fields-persist.md)); no string is saved |

## Lifecycle

| ID | Phase | Who acts | What changes |
|----|-------|----------|--------------|
| L1 | Create | Developer, for a new owner | Add F1 with every key and value in all three locales, then F2 gains the owner |
| L2 | Read | [`CMP-presentation`](../components/presentation.md) | Resolve a key for the current locale |
| L3 | Update | Developer, when a Copy table changes | Add, remove, or change the entry in every locale in the same change; key set follows I3 |
| L4 | Destroy | Developer, when a screen is removed | Remove the owner from F1 and F2 together; leave no orphan key |

## Relationships

- One owner to many keys: many-to-one. F2 orders the owners.
- Consumed through [`CTR-localization`](../contracts/localization.md); reads `GS.locale` per [`CMP-session-router`](../components/session-router.md) R5.

## Diagram

None — flat key/value map. A missing key, a value equal to its key, or a verbatim `en` copy fails I2, I4, or I5 ([`FAIL.T13`](../failures.md)).

## Persistence

N/A — copy is compile-time, not saved (I7).
