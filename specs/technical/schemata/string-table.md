# Schema: String table

Authoring rules: [`.agents/specs/rules/technical/schemata.md`](../../../.agents/specs/rules/technical/schemata.md).

- **Kind**: value object — compile-time copy for one copy owner, all shipped locales
- **Owner**: [`CMP-presentation`](../components/presentation.md)
- **Serves**: [quality.md](../../definition/quality.md) Localization; [Localization copy](../../ux/localization.md)
- **Informed by**: [`specs/ux/screens/`](../../ux/screens/) Copy tables; [`configuration.md`](../configuration.md) S4 B4
- **ADRs**: [ADR-0001](../../adr/decisions/0001-godot-engine.md)

Fields: [`string-table-fields.md`](string-table-fields.md). Copy rules — sharing across owners, missing keys, the completeness gate, and rows same in every locale: [`string-table-fields-rules.md`](string-table-fields-rules.md). Invariants and lifecycle: [`string-table-invariants.md`](string-table-invariants.md).

## Fields

Moved to [`string-table-fields.md`](string-table-fields.md) §Fields.

## Invariants

Moved to [`string-table-invariants.md`](string-table-invariants.md) §Invariants.

## Lifecycle

Moved to [`string-table-invariants.md`](string-table-invariants.md) §Lifecycle.

## Relationships

Moved to [`string-table-invariants.md`](string-table-invariants.md) §Relationships.

## Diagram

None — flat key/value map ([`string-table-invariants.md`](string-table-invariants.md) §Diagram).

## Persistence

N/A — copy is compile-time, not saved (I7; [`string-table-invariants.md`](string-table-invariants.md) §Persistence).
