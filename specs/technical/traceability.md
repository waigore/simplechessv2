# Technical Traceability

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../.agents/specs/rules/technical/traceability.md).

## Alignment

The full Alignment table, with one row per upstream item and its serving technical specs, lives in [`traceability/alignment.md`](traceability/alignment.md). It covers all 14 Accepted ADRs (ADR-0001 through ADR-0014), every design feature, entity, and flow, and every quality category that Applies, including **Localization**. All 34 technical elements (12 components, 9 contracts, 6 schemata, 6 sequences) appear there by ID, with `CTR-presentation` recorded as the single consumer-only contract. The table also carries the shipped-release publication ([ADR-0009](../adr/decisions/0009-github-pages-client-host.md)), reached only through the Topic coverage row below because a workflow and an export preset carry no element ID.

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Layer decomposition | [`layers.md`](layers.md) | Applies |
| Modular decomposition | [`modules.md`](modules.md) | Applies — includes the uncommitted Web export `build/web/` ([ADR-0007](../adr/decisions/0007-web-export-output.md)) |
| Components | [`components/`](components/) | Applies — critical path + advice-backend + catalog-service + playtest-seams |
| Contracts | [`contracts/`](contracts/) | Applies — includes asset-resolve, playtest-drive, puzzle-catalog-read |
| Schemata and lifecycles | [`schemata/`](schemata/) | Applies — includes advice-update, puzzle-attempt, puzzle-catalog |
| Sequences | [`sequences/`](sequences/) | Applies — includes puzzle-result-commit, shared-end-new-run, playtest-headless-smoke |
| Failure model | [`failures.md`](failures.md) | Applies |
| Concurrency and update loop | [`concurrency.md`](concurrency.md) | Applies |
| Persistence and save mapping | [`persistence.md`](persistence.md) | Applies |
| Config and data-driven tables | [`configuration.md`](configuration.md) | Applies |
| Localization | [alignment](traceability/alignment.md) Localization row; [`configuration.md`](configuration.md) `S4`, `B4`; [`CTR-localization`](contracts/localization.md); [`SCH-string-table`](schemata/string-table.md); [`FAIL.T13`](failures.md) | Applies — `en`, `zh-Hant`, `ja` |
| Verification hooks | [`verification.md`](verification.md) | Applies |
| Asset access and loading | [`asset-access.md`](asset-access.md) | Applies — pairs [`specs/assets/access.md`](../assets/access.md); ADR-0005 |
| Shipped-release publication | [`traceability/alignment.md`](traceability/alignment.md) — Shipped-release publication row; [ADR-0009](../adr/decisions/0009-github-pages-client-host.md) Decision; `.github/workflows/web-release.yml` | Applies — CI publish under ADR-0009 serves the quality Load time / latency check on the public URL and epic #37's `Every release` validation rows (ADR-0001, ADR-0003, ADR-0004); no element ID, since a workflow and an export preset are outside the 32-element set |
| Diagrams | Mermaid in unit specs | Applies — inline; `diagrams/` unused this pass |
