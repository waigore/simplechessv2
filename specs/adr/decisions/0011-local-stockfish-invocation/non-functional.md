# ADR-0011 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0011](../0011-local-stockfish-invocation.md).

## Context

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).

## Decision

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).

## Reasoning

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).

## Rejected alternatives

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | The client frame budget is unchanged. Engine work stays off the browser |
| Load time / latency | Affects | Stockfish is local, so advice adds no second network hop. The 2000 ms cap and the rule that a move never waits stay in quality.md and ADR-0002 |
| Reliability | No effect | If Stockfish fails, advice clears and play continues (ADR-0002) |
| Observability | No effect | Advice timing and errors stay in ADR-0002 |
| Save durability | No effect | Advice is not saved |
| Accessibility | No effect | No interface change |
| Localization | No effect | No player-facing copy |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Stockfish stays GPL under ADR-0002. This decision sets no fee and no GPL procedure |
| Maintainability | One Python server owns the engine process. Replacing Stockfish stays inside that server |
| Testability | Tests can run the Python server with local Stockfish. No remote engine is required |
| Portability | Web client unchanged. The server is Python plus a local Stockfish it invokes |
| Security and privacy | Stockfish is not reachable from the network. The client still reaches only the Python server. ADR-0002 still requires TLS and no accounts |

## Imposes

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).

## Validation

N/A — stated in [ADR-0011](../0011-local-stockfish-invocation.md).
