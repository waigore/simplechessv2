# Technical Traceability

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../.agents/specs/rules/technical/traceability.md).

## Alignment

The full Alignment table, with one row per upstream item and its serving technical specs, lives in [`traceability/alignment.md`](traceability/alignment.md). It covers every Accepted ADR that shapes code or data, every design feature, entity, and flow, and every quality category that Applies, including **Localization**. All 27 technical elements (10 components, 6 contracts, 5 schemata, 6 sequences) appear there by ID, with `CTR-presentation` recorded as the single consumer-only contract.

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Layer decomposition | [`layers.md`](layers.md) | Applies |
| Modular decomposition | [`modules.md`](modules.md) | Applies |
| Components | [`components/`](components/) | Applies — critical path + advice-backend + playtest-seams |
| Contracts | [`contracts/`](contracts/) | Applies — includes asset-resolve, playtest-drive |
| Schemata and lifecycles | [`schemata/`](schemata/) | Applies — includes advice-update, puzzle-attempt, puzzle-catalog |
| Sequences | [`sequences/`](sequences/) | Applies — includes puzzle-result-commit, shared-end-new-session, playtest-headless-smoke |
| Failure model | [`failures.md`](failures.md) | Applies |
| Concurrency and update loop | [`concurrency.md`](concurrency.md) | Applies |
| Persistence and save mapping | [`persistence.md`](persistence.md) | Applies |
| Config and data-driven tables | [`configuration.md`](configuration.md) | Applies |
| Localization | [alignment](traceability/alignment.md) Localization row; [`configuration.md`](configuration.md) `S4`, `B4`; string tables keyed by `GS.locale` | Applies — `en`, `zh-Hant`, `ja` |
| Verification hooks | [`verification.md`](verification.md) | Applies |
| Asset access and loading | [`asset-access.md`](asset-access.md) | Applies — pairs [`specs/assets/access.md`](../assets/access.md); ADR-0005 |
| Diagrams | Mermaid in unit specs | Applies — inline; `diagrams/` unused this pass |
