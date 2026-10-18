# Technical Traceability

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../.agents/specs/rules/technical/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play; on-device moves | vision; definition; ADR-0001 | [`layers.md`](layers.md); [`CTR-local-move`](contracts/local-move.md); [`SEQ-apply-local-move`](sequences/apply-local-move.md) |
| Optional Stockfish Advice stream | F-move-advice; ADR-0002 | [`CMP-advice-client`](components/advice-client.md); [`CTR-advice-stream`](contracts/advice-stream.md); [`SEQ-advice-stream`](sequences/advice-stream.md) |
| Elo / Last mode / recent solved | fields-persist; ADR-0003 | [`persistence.md`](persistence.md); [`CMP-persist-store`](components/persist-store.md) |
| Dual playtest ENV/DBG/TEL | playtest tools; ADR-0004 | [`verification.md`](verification.md) |
| Asset catalog + manifest | assets access; ADR-0005 | [`asset-access.md`](asset-access.md); [`CMP-asset-resolver`](components/asset-resolver.md) |
| Shared + Puzzle modes | design configuration / loops | Session components; [`SEQ-cold-open`](sequences/cold-open.md) |
| Design `CFG.*` | design configuration | [`configuration.md`](configuration.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Layer decomposition | [`layers.md`](layers.md) | Applies |
| Modular decomposition | [`modules.md`](modules.md) | Applies |
| Components | [`components/`](components/) | Applies — critical-path set |
| Contracts | [`contracts/`](contracts/) | Applies — local-move, advice-stream, persist-document |
| Schemata and lifecycles | [`schemata/`](schemata/) | Applies — play-state, persist-doc |
| Sequences | [`sequences/`](sequences/) | Applies — cold-open, apply-local-move, advice-stream |
| Failure model | [`failures.md`](failures.md) | Applies |
| Concurrency and update loop | [`concurrency.md`](concurrency.md) | Applies |
| Persistence and save mapping | [`persistence.md`](persistence.md) | Applies |
| Config and data-driven tables | [`configuration.md`](configuration.md) | Applies |
| Verification hooks | [`verification.md`](verification.md) | Applies |
| Asset access and loading | [`asset-access.md`](asset-access.md) | Applies — pairs [`specs/assets/access.md`](../assets/access.md); ADR-0005 |
| Diagrams | Mermaid in unit specs | Applies — inline; `diagrams/` unused this pass |
