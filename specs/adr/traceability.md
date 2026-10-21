# Architecture Traceability

Authoring rules: [`.agents/specs/rules/adr/traceability.md`](../../.agents/specs/rules/adr/traceability.md).

## Alignment

| Upstream item | Source | Decisions |
|---------------|--------|-----------|
| Instant play | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Clear board / Cafe calm | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Engine Godot; Web / touch | definition | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Local move never waits on network; async time-capped Stockfish | definition | [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| No-install Web commute | definition | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Shared game; Puzzle stream | definition | [ADR-0001](decisions/0001-godot-engine.md) |
| Performance | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Load time / latency | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| Reliability | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Observability | quality | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Save durability | quality | [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Accessibility | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| Localization | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| F-move-advice; CFG.ADVICE_TIME_MS | design | [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| Loops; game-state; end conditions | design | [ADR-0006](decisions/0006-layered-client-architecture.md) |
| PRG.P1 P2 M1; GS persist fields | design | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| 2D Web board view | view | [ADR-0001](decisions/0001-godot-engine.md) |
| Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*` | playtest | [ADR-0004](decisions/0004-dual-playtest-environments.md), [ADR-0006](decisions/0006-layered-client-architecture.md) |
| Asset catalog / asset roots; Recraft-only visual | assets | [ADR-0005](decisions/0005-asset-catalog-roots.md) |
| Godot project root `game/` | assets | [ADR-0005](decisions/0005-asset-catalog-roots.md), [ADR-0007](decisions/0007-web-export-output.md) |
| Load time; Localization fonts | quality | [ADR-0005](decisions/0005-asset-catalog-roots.md) |

## Imposed constraints

| ADR | Constrained spec or element | Status |
|-----|-----------------------------|--------|
| ADR-0005 | `specs/assets/assets.md` Catalog roots | Cited |
| ADR-0005 | `specs/assets/access.md` | Cited |
| ADR-0005 | `specs/technical/asset-access.md` | Cited |
| ADR-0005 | `specs/assets/tools.md` | Cited |
