# ADR-0008 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0008](../0008-puzzle-catalog-storage.md).

## Context

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).

## Decision

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).

## Reasoning

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).

## Rejected alternatives

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | The client does not parse the snapshot during a move |
| Load time / latency | Affects | The export stays off the client so cold open can meet 3 seconds |
| Reliability | No effect | A failed read deals nothing and does not crash |
| Observability | No effect | Story-id logs stay on playtest seams |
| Save durability | No effect | Client commits stay [ADR-0003](../0003-localstorage-persistence.md) |
| Accessibility | No effect | Piece readability is unchanged |
| Localization | No effect | Locales are unchanged |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | CC0, no fee, allowed for this browser game; file not in the client |
| Maintainability | Version is the snapshot date, not a client release |
| Testability | Review the Web bundle; frame-time capture covers the move hitch |
| Portability | Web only |
| Security and privacy | The client host does not serve the raw export anonymously; Elo stays in localStorage |

## Imposes

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).

## Validation

N/A — stated in [ADR-0008](../0008-puzzle-catalog-storage.md).
