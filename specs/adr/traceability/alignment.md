# Architecture Traceability: Alignment

Authoring rules: [`.agents/specs/rules/adr/traceability.md`](../../../.agents/specs/rules/adr/traceability.md).

Split from [traceability.md](../traceability.md) per that file's Splitting rule; the Imposed constraints table stays there.

| Upstream item | Source | Decisions |
|---------------|--------|-----------|
| Instant play | vision | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0005](../decisions/0005-asset-catalog-roots.md), [ADR-0006](../decisions/0006-layered-client-architecture.md), [ADR-0011](../decisions/0011-local-stockfish-invocation.md) |
| Clear board | vision | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0004](../decisions/0004-dual-playtest-environments.md) |
| Cafe calm | vision | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0004](../decisions/0004-dual-playtest-environments.md), [ADR-0016](../decisions/0016-no-public-client-host.md) |
| Engine Godot; Web / touch | definition | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0007](../decisions/0007-web-export-output.md), [ADR-0016](../decisions/0016-no-public-client-host.md) |
| Local move never waits on network; async time-capped Stockfish | definition | [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0010](../decisions/0010-advice-backend-stack.md), [ADR-0011](../decisions/0011-local-stockfish-invocation.md) |
| No-install Web commute | definition | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0003](../decisions/0003-localstorage-persistence.md), [ADR-0007](../decisions/0007-web-export-output.md), [ADR-0016](../decisions/0016-no-public-client-host.md) |
| Shared game; Puzzle stream | definition | [ADR-0001](../decisions/0001-godot-engine.md) |
| Performance | quality | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0004](../decisions/0004-dual-playtest-environments.md), [ADR-0008](../decisions/0008-puzzle-catalog-storage.md) |
| Load time / latency | quality | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0008](../decisions/0008-puzzle-catalog-storage.md), [ADR-0010](../decisions/0010-advice-backend-stack.md), [ADR-0011](../decisions/0011-local-stockfish-invocation.md), [ADR-0016](../decisions/0016-no-public-client-host.md) |
| Reliability | quality | [ADR-0001](../decisions/0001-godot-engine.md), [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0003](../decisions/0003-localstorage-persistence.md), [ADR-0004](../decisions/0004-dual-playtest-environments.md), [ADR-0006](../decisions/0006-layered-client-architecture.md), [ADR-0010](../decisions/0010-advice-backend-stack.md), [ADR-0012](../decisions/0012-advice-backend-gpl-compliance.md) |
| Observability | quality | [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0003](../decisions/0003-localstorage-persistence.md), [ADR-0004](../decisions/0004-dual-playtest-environments.md), [ADR-0006](../decisions/0006-layered-client-architecture.md) |
| Save durability | quality | [ADR-0003](../decisions/0003-localstorage-persistence.md), [ADR-0006](../decisions/0006-layered-client-architecture.md) |
| Accessibility | quality | [ADR-0001](../decisions/0001-godot-engine.md) |
| Localization | quality | [ADR-0001](../decisions/0001-godot-engine.md) |
| F-move-advice; CFG.ADVICE_TIME_MS | design | [ADR-0002](../decisions/0002-stockfish-advice-backend.md), [ADR-0010](../decisions/0010-advice-backend-stack.md) |
| Loops; game-state; end conditions | design | [ADR-0006](../decisions/0006-layered-client-architecture.md) |
| PRG.P1 P2 M1; GS persist fields | design | [ADR-0003](../decisions/0003-localstorage-persistence.md) |
| DIF.Y1 Elo and pick policy | design | [ADR-0006](../decisions/0006-layered-client-architecture.md) `L3` |
| Puzzle catalog; DIF.Y1; GS.recentSolved | design | [ADR-0008](../decisions/0008-puzzle-catalog-storage.md), [ADR-0013](../decisions/0013-puzzle-catalog-api.md) |
| 2D Web board view | view | [ADR-0001](../decisions/0001-godot-engine.md) |
| Playtest `ENV.1` `ENV.2` `DBG.*` `TEL.*` | playtest | [ADR-0004](../decisions/0004-dual-playtest-environments.md), [ADR-0006](../decisions/0006-layered-client-architecture.md) |
| Asset catalog / asset roots; Recraft-only visual; ElevenLabs SFX/music (TL.2, TL.3) | assets | [ADR-0005](../decisions/0005-asset-catalog-roots.md) |
| Godot project root `game/` | assets | [ADR-0005](../decisions/0005-asset-catalog-roots.md), [ADR-0007](../decisions/0007-web-export-output.md) |
| Load time; Localization fonts | quality | [ADR-0005](../decisions/0005-asset-catalog-roots.md) |
| Advice deployment posture (owner answer on #505); no public release | issue #505 | [ADR-0015](../decisions/0015-advice-backend-operator-deployments.md), [ADR-0012](../decisions/0012-advice-backend-gpl-compliance.md) |
