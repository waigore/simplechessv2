# Architecture Traceability

Authoring rules: [`.agents/specs/rules/adr/traceability.md`](../../.agents/specs/rules/adr/traceability.md).

## Alignment

| Upstream item | Source | Decisions |
|---------------|--------|-----------|
| Instant play | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0006](decisions/0006-layered-client-architecture.md), [ADR-0011](decisions/0011-local-stockfish-invocation.md) |
| Clear board / Cafe calm | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Engine Godot; Web / touch | definition | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0007](decisions/0007-web-export-output.md), [ADR-0009](decisions/0009-github-pages-client-host.md) |
| Local move never waits on network; async time-capped Stockfish | definition | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0010](decisions/0010-advice-backend-stack.md), [ADR-0011](decisions/0011-local-stockfish-invocation.md) |
| No-install Web commute | definition | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0007](decisions/0007-web-export-output.md), [ADR-0009](decisions/0009-github-pages-client-host.md) |
| Shared game; Puzzle stream | definition | [ADR-0001](decisions/0001-godot-engine.md) |
| Performance | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0008](decisions/0008-puzzle-catalog-storage.md) |
| Load time / latency | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0008](decisions/0008-puzzle-catalog-storage.md), [ADR-0009](decisions/0009-github-pages-client-host.md), [ADR-0010](decisions/0010-advice-backend-stack.md), [ADR-0011](decisions/0011-local-stockfish-invocation.md) |
| Reliability | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md), [ADR-0010](decisions/0010-advice-backend-stack.md) |
| Observability | quality | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Save durability | quality | [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Accessibility | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| Localization | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| F-move-advice; CFG.ADVICE_TIME_MS | design | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0010](decisions/0010-advice-backend-stack.md) |
| Loops; game-state; end conditions | design | [ADR-0006](decisions/0006-layered-client-architecture.md) |
| PRG.P1 P2 M1; GS persist fields | design | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Puzzle catalog; DIF.Y1; GS.recentSolved | design | [ADR-0008](decisions/0008-puzzle-catalog-storage.md) |
| 2D Web board view | view | [ADR-0001](decisions/0001-godot-engine.md) |
| Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*` | playtest | [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Asset catalog / asset roots; Recraft-only visual; ElevenLabs SFX/music (TL.2, TL.3) | assets | [ADR-0005](decisions/0005-asset-catalog-roots.md) |
| Godot project root `game/` | assets | [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Load time; Localization fonts | quality | [ADR-0005](decisions/0005-asset-catalog-roots.md) |

## Imposed constraints

| ADR | Constrained spec or element | Status |
|-----|-----------------------------|--------|
| ADR-0005 | `specs/assets/assets.md` Catalog roots | Cited |
| ADR-0005 | `specs/assets/access.md` | Cited |
| ADR-0005 | `specs/technical/asset-access.md` | Cited |
| ADR-0005 | `specs/assets/tools.md` | Cited |
| ADR-0008 | [F-puzzle-catalog](../design/features/puzzle-catalog.md) | Cited |
| ADR-0008 | [SCH-puzzle-catalog](../technical/schemata/puzzle-catalog.md) | Cited |
| ADR-0010 | [`specs/technical/configuration.md`](../technical/configuration.md) | Cited |
| ADR-0010 | [`CMP-advice-client`](../technical/components/advice-client.md) | Cited |
| ADR-0010 | [`CTR-advice-stream`](../technical/contracts/advice-stream.md) | Cited |
| ADR-0011 | [CMP-advice-backend](../technical/components/advice-backend.md) | Cited |
| ADR-0011 | [modules.md](../technical/modules.md) M2, B2 | Cited |
| ADR-0011 | [SEQ-advice-stream](../technical/sequences/advice-stream.md) S3 | Cited |
