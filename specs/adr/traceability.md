# Architecture Traceability

Authoring rules: [`.agents/specs/rules/adr/traceability.md`](../../.agents/specs/rules/adr/traceability.md).

## Alignment

| Upstream item | Source | Decisions |
|---------------|--------|-----------|
| Instant play | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| Clear board / Cafe calm | vision | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Engine Godot; Web / touch | definition | [ADR-0001](decisions/0001-godot-engine.md) |
| Local move never waits on network; async time-capped Stockfish | definition | [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| No-install Web commute | definition | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Performance | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Load time / latency | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| Reliability | quality | [ADR-0001](decisions/0001-godot-engine.md), [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Observability | quality | [ADR-0002](decisions/0002-stockfish-advice-backend.md), [ADR-0003](decisions/0003-localstorage-persistence.md), [ADR-0004](decisions/0004-dual-playtest-environments.md) |
| Save durability | quality | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| Accessibility | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| Localization | quality | [ADR-0001](decisions/0001-godot-engine.md) |
| F-move-advice; CFG.ADVICE_TIME_MS | design | [ADR-0002](decisions/0002-stockfish-advice-backend.md) |
| PRG.P1 P2; GS persist fields | design | [ADR-0003](decisions/0003-localstorage-persistence.md) |
| 2D Web board view | view | [ADR-0001](decisions/0001-godot-engine.md) |
| Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*` | playtest | [ADR-0004](decisions/0004-dual-playtest-environments.md) |

## Imposed constraints

| ADR | Constrained spec or element | Citation |
|-----|-----------------------------|----------|
| — | None | — |
