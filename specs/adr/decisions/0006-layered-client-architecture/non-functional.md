# ADR-0006 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0006](../0006-layered-client-architecture.md).

## Context

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).

## Decision

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).

## Reasoning

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).

## Rejected alternatives

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How met or limited |
|----------|--------|--------------------|
| Performance | No effect | In-process (ADR-0001) |
| Load time / latency | No effect | ADR-0001, ADR-0005 |
| Reliability | Affects | Single-owner state; quality.md soak |
| Observability | Affects | Errors, timing, and outcomes via L4 `TEL.*` so playtest logs correlate to story IDs (quality.md playtest-log) |
| Save durability | Affects | Committed `GS.playerElo`/`GS.lastMode` via L4 persist; quit/reload and failed-write keep prior (quality.md) |
| Accessibility | No effect | ADR-0001 |
| Localization | No effect | `GS.locale` is design state |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Not relevant — no third-party code |
| Maintainability | Engine upgrades touch L1/L4; rules stay in L3 |
| Testability | L3 pure and headless-testable (ADR-0004) |
| Portability | Web (ADR-0001); platform code in L4 only |
| Security and privacy | Only advice leaves device (ADR-0002) |

## Imposes

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).

## Validation

N/A — stated in [ADR-0006](../0006-layered-client-architecture.md).
