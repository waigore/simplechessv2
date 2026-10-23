# Schema: String table fields

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

Fields of [`SCH-string-table`](string-table.md), split per the rules' §Splitting. Invariants, the sharing, missing-key, gate, and same-in-every-locale rules are in [`string-table-fields-rules.md`](string-table-fields-rules.md); the lifecycle, relationships, diagram, and persistence are in [`string-table-invariants.md`](string-table-invariants.md).

## Fields

| ID | Name | Type | Required | Notes |
|----|------|------|----------|-------|
| F1 | owner | copy owner id | yes | A screen such as `puzzle-play`, or `exceptions`, keyed by [`exceptions.md`](../../ux/exceptions.md) |
| F2 | namespaces | ordered owner ids | yes | The owners whose three locales are complete, enumerated: `mode-pick`, `shared-setup`, `shared-play`, `shared-result`, `exceptions`, `puzzle-play`; order is display order and no consumer depends on it ([`string-table-gate.md`](string-table-gate.md) §Gate-input rule) |
| F3 | locale | enum `en` `zh-Hant` `ja` | yes | Shipped locales; `en` is the source |
| F4 | key | snake_case string | yes | Per [Localization copy](../../ux/localization.md) L1 |
| F5 | value | string | yes | The recorded Copy-table string for that key, in that locale; never empty, never the bare key |

## Invariants

Moved to [`string-table-fields-rules.md`](string-table-fields-rules.md) §Invariants.

## Lifecycle

N/A — [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

- One owner to many keys: many-to-one. F2 lists the owners whose three locales are complete, in display order; no consumer depends on it.
- F1–F5 are consumed through [`CTR-localization`](../contracts/localization.md).

## Diagram

None — flat key/value map; the shape does not need one.

## Persistence

N/A — copy is compile-time and not saved (I7).
