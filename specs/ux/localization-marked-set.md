# Localization Copy: piece names

Authoring rules: [`.agents/specs/rules/ux/ux.md`](../../.agents/specs/rules/ux/ux.md).

- **Serves**: [quality.md](../definition/quality.md) Localization (`en`, `zh-Hant`, `ja`); Accessibility
- **Informed by**: [`localization.md`](localization.md) key and locale rules; screen Copy tables; [`CMP-presentation`](../technical/components/presentation.md) R8

Part of [`localization.md`](localization.md), whose rule table continues there past `L6` and cites the rules below by their `L` number: `L7`–`L10` here are that table's next four rules, and no rule is numbered in both files.

## Rules

| ID | Rule |
|----|------|
| L7 | **The marked set has one source: this rule.** It is the `mode-pick` own name (`UI-mode-pick.C4`) plus `pawn`, `king`, `queen`, `rook`, `bishop`, `knight` on `shared-play` and the same six on `puzzle-play`: three owners, 13 rows. Screen marker prose and the string-table schema cite L7 and restate no row of it. |
| L8 | **A piece's accessible name is its type.** [`CMP-presentation`](../technical/components/presentation.md) R8 exposes it as node metadata, never a drawn label, so a piece takes its name from no colour and no turn-status row. |
| L9 | Each of the six kinds names its one Copy key, the kind's own name, read from `shared-play` or `puzzle-play` per play screen. A kind absent from L7 has no name, and no English name is written in code. |
| L10 | A piece name renders as text by an assistive layer, so its longest per-locale value is measured there at `L4`'s 40% tolerance ([`CTR-localization`](../technical/contracts/localization.md) G5). TBD — which locale is measured first. |
