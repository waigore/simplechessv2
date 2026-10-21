# Technical Traceability

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../.agents/specs/rules/technical/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play; on-device moves | vision; definition; ADR-0001 | [`layers.md`](layers.md); [`CTR-local-move`](contracts/local-move.md); [`SEQ-apply-local-move`](sequences/apply-local-move.md) |
| Layered client architecture | ADR-0006 | [`layers.md`](layers.md); [`modules.md`](modules.md) |
| Optional Stockfish Advice stream | F-move-advice; ADR-0002 | [`CMP-advice-client`](components/advice-client.md); [`CTR-advice-stream`](contracts/advice-stream.md); [`SEQ-advice-stream`](sequences/advice-stream.md) |
| Elo / Last mode / recent solved | fields-persist; ADR-0003 | [`persistence.md`](persistence.md); [`CMP-persist-store`](components/persist-store.md) |
| Dual playtest ENV/DBG/TEL and `SIT.1`–`SIT.3` | playtest tools; ADR-0004 | [`verification.md`](verification.md); [`CMP-playtest-seams`](components/playtest-seams.md); [`CTR-playtest-drive`](contracts/playtest-drive.md); [`SEQ-playtest-headless-smoke`](sequences/playtest-headless-smoke.md) |
| Asset catalog + manifest | assets access; ADR-0005 | [`asset-access.md`](asset-access.md); [`CMP-asset-resolver`](components/asset-resolver.md); [`CTR-asset-resolve`](contracts/asset-resolve.md) |
| Shared + Puzzle modes | design configuration / loops | Session components; [`SEQ-cold-open`](sequences/cold-open.md); [`SEQ-shared-end-new-session`](sequences/shared-end-new-session.md); [`SEQ-puzzle-result-commit`](sequences/puzzle-result-commit.md) |
| Design `CFG.*` | design configuration | [`configuration.md`](configuration.md) |
| Piece rules entity `E-pieces` | design | [`CMP-chess-rules`](components/chess-rules.md); [`CTR-local-move`](contracts/local-move.md) |
| Mode pick flow `FL-mode-pick` | design | [`CMP-session-router`](components/session-router.md); [`SEQ-cold-open`](sequences/cold-open.md) |
| Advice stream DTO | F-move-advice | [`SCH-advice-update`](schemata/advice-update.md); [`CMP-advice-backend`](components/advice-backend.md) |
| Puzzle attempt / Elo commit | puzzle stream; DIF; PRG | [`SCH-puzzle-attempt`](schemata/puzzle-attempt.md); [`SEQ-puzzle-result-commit`](sequences/puzzle-result-commit.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Layer decomposition | [`layers.md`](layers.md) | Applies |
| Modular decomposition | [`modules.md`](modules.md) | Applies |
| Components | [`components/`](components/) | Applies — critical path + advice-backend + playtest-seams |
| Contracts | [`contracts/`](contracts/) | Applies — includes asset-resolve, playtest-drive |
| Schemata and lifecycles | [`schemata/`](schemata/) | Applies — includes advice-update, puzzle-attempt |
| Sequences | [`sequences/`](sequences/) | Applies — includes puzzle-result-commit, shared-end-new-session, playtest-headless-smoke |
| Failure model | [`failures.md`](failures.md) | Applies |
| Concurrency and update loop | [`concurrency.md`](concurrency.md) | Applies |
| Persistence and save mapping | [`persistence.md`](persistence.md) | Applies |
| Config and data-driven tables | [`configuration.md`](configuration.md) | Applies |
| Verification hooks | [`verification.md`](verification.md) | Applies |
| Asset access and loading | [`asset-access.md`](asset-access.md) | Applies — pairs [`specs/assets/access.md`](../assets/access.md); ADR-0005 |
| Diagrams | Mermaid in unit specs | Applies — inline; `diagrams/` unused this pass |
