# Technical Traceability: Alignment

Authoring rules: [`.agents/specs/rules/technical/traceability.md`](../../../.agents/specs/rules/technical/traceability.md). Hub: [`traceability.md`](../traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play; on-device moves | vision; definition; ADR-0001 | [`layers.md`](../layers.md); [`CMP-chess-rules`](../components/chess-rules.md); [`CTR-local-move`](../contracts/local-move.md); [`SEQ-apply-local-move`](../sequences/apply-local-move.md) |
| Layered client architecture | ADR-0006 | [`layers.md`](../layers.md); [`modules.md`](../modules.md) `M1`, `M2`, `B1`–`B3`; [`CMP-puzzle-progression`](../components/puzzle-progression.md) (L3 Elo and puzzle pick) |
| Uncommitted Web export `build/web/` | ADR-0007 | [`modules.md`](../modules.md) web-export output note under Modules |
| Shared game loop; clocks; end conditions | design `L-two-player-game`; end-conditions | [`CMP-shared-game-session`](../components/shared-game-session.md); [`CMP-presentation`](../components/presentation.md); [`CTR-local-move`](../contracts/local-move.md); [`SEQ-apply-local-move`](../sequences/apply-local-move.md); [`SEQ-shared-end-new-session`](../sequences/shared-end-new-session.md) |
| Puzzle stream; DIF; PRG | design `L-puzzle-stream`; DIF; PRG | [`CMP-puzzle-session`](../components/puzzle-session.md); [`CMP-puzzle-progression`](../components/puzzle-progression.md); [`CTR-puzzle-progress`](../contracts/puzzle-progress.md); [`CTR-local-move`](../contracts/local-move.md); [`SCH-play-state`](../schemata/play-state.md); [`SCH-puzzle-attempt`](../schemata/puzzle-attempt.md); [`SEQ-puzzle-result-commit`](../sequences/puzzle-result-commit.md) |
| Mode pick; Last mode; cold open to playable board | design `FL-mode-pick`; `GS.lastMode`; quality | [`CMP-session-router`](../components/session-router.md); [`SEQ-cold-open`](../sequences/cold-open.md) |
| Clear board; Cafe calm; touch input; UX screens | vision; definition; view; UX | [`CMP-presentation`](../components/presentation.md); [`CTR-presentation`](../contracts/presentation.md); [`layers.md`](../layers.md) view board camera |
| Save durability; Elo / Last mode / recent solved | quality; fields-persist; ADR-0003 | [`persistence.md`](../persistence.md); [`CMP-persist-store`](../components/persist-store.md); [`CTR-persist-document`](../contracts/persist-document.md); [`SCH-persist-doc`](../schemata/persist-doc.md) |
| Load time; Asset access `ACC` G1–G3 | quality; assets access; ADR-0005 | [`asset-access.md`](../asset-access.md); [`CMP-asset-resolver`](../components/asset-resolver.md); [`CTR-asset-resolve`](../contracts/asset-resolve.md) |
| Observability; playtest tools | quality; playtest tools; ADR-0004 | [`verification.md`](../verification.md); [`CMP-playtest-seams`](../components/playtest-seams.md); [`CTR-playtest-drive`](../contracts/playtest-drive.md); [`SEQ-playtest-headless-smoke`](../sequences/playtest-headless-smoke.md) |
| Optional Stockfish Advice stream | F-move-advice; ADR-0002; ADR-0010; ADR-0011 | [`CMP-advice-client`](../components/advice-client.md); [`CMP-advice-backend`](../components/advice-backend.md); [`modules.md`](../modules.md); [`CTR-advice-stream`](../contracts/advice-stream.md); [`SEQ-advice-stream`](../sequences/advice-stream.md) |
| Localization | quality; ADR-0001 | [`configuration.md`](../configuration.md) `S4`, `B4`; [`CTR-localization`](../contracts/localization.md); [`SCH-string-table`](../schemata/string-table.md); [`CMP-session-router`](../components/session-router.md) `R5`; [`CMP-presentation`](../components/presentation.md) `R6`; [`failures.md`](../failures.md) `T13`; copy tables in [`specs/ux/screens/`](../../ux/screens/); [`specs/ux/localization.md`](../../ux/localization.md); [`mode-pick`](../../ux/screens/mode-pick.md) `C4` Switch locale |
| Design `CFG.*` | design configuration | [`configuration.md`](../configuration.md) |
| Piece rules entity `E-pieces` | design | [`CMP-chess-rules`](../components/chess-rules.md); [`CTR-local-move`](../contracts/local-move.md) |
| Mode pick flow `FL-mode-pick` | design | [`CMP-session-router`](../components/session-router.md); [`SEQ-cold-open`](../sequences/cold-open.md) |
| Shared + Puzzle modes | design configuration / loops | [`CMP-shared-game-session`](../components/shared-game-session.md); [`CMP-puzzle-session`](../components/puzzle-session.md); [`CMP-puzzle-progression`](../components/puzzle-progression.md); [`CMP-session-router`](../components/session-router.md); [`SEQ-cold-open`](../sequences/cold-open.md); [`SEQ-shared-end-new-session`](../sequences/shared-end-new-session.md); [`SEQ-puzzle-result-commit`](../sequences/puzzle-result-commit.md) |
| Advice stream DTO | F-move-advice | [`SCH-advice-update`](../schemata/advice-update.md); [`CMP-advice-backend`](../components/advice-backend.md) |
| Puzzle attempt / Elo commit | puzzle stream; DIF; PRG | [`SCH-puzzle-attempt`](../schemata/puzzle-attempt.md); [`CMP-puzzle-progression`](../components/puzzle-progression.md); [`CTR-puzzle-progress`](../contracts/puzzle-progress.md); [`SEQ-puzzle-result-commit`](../sequences/puzzle-result-commit.md) |
| Puzzle catalog snapshot | [F-puzzle-catalog](../../design/features/puzzle-catalog.md); ADR-0008 | [`SCH-puzzle-catalog`](../schemata/puzzle-catalog.md) |
| Shipped-release publication (Pages URL) | ADR-0009; ADR-0007; definition no-install commute | `.github/workflows/web-release.yml` (CI publish of `build/web/`; out of scope of ADR-0009, which names no workflow file); `Web Release` preset in [`game/export_presets.cfg`](../../../game/export_presets.cfg) (the preset; ADR-0007 decides only the `build/web/` output directory) |
| Puzzle catalog read (host route, key, one record) | [F-puzzle-catalog](../../design/features/puzzle-catalog.md); ADR-0008; ADR-0010; ADR-0013 | [`CMP-catalog-service`](../components/catalog-service.md); [`CTR-puzzle-catalog-read`](../contracts/puzzle-catalog-read.md); [`CMP-puzzle-session`](../components/puzzle-session.md) `R1`, C5; [`concurrency.md`](../concurrency.md) `U4`, `S3`; [`SCH-puzzle-catalog`](../schemata/puzzle-catalog.md); [`configuration.md`](../configuration.md) `B5`, `T9`, `T10`, `T11`; [`failures.md`](../failures.md) `T14` |

## Element accounting

All 34 technical elements appear by ID above, except one consumer-only contract:

| Element | Provider | Consumer | Upstream obligation carried by |
|---------|----------|----------|--------------------------------|
| `CTR-presentation` | Any L2 Session: `CMP-session-router`, `CMP-shared-game-session`, `CMP-puzzle-session` | `CMP-presentation` | The Clear board / Cafe calm / touch input / UX screens row |
