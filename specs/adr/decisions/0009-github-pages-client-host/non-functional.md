# ADR-0009 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0009](../0009-github-pages-client-host.md).

## Context

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).

## Decision

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).

## Reasoning

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).

## Rejected alternatives

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | Frame budget stays on-device |
| Load time / latency | Affects | Cold open on the public URL still meets board playable within 3 seconds |
| Reliability | No effect | Sitting soak is client behavior |
| Observability | No effect | Playtest logs stay ADR-0004 |
| Save durability | No effect | Saves stay origin localStorage (ADR-0003) |
| Accessibility | No effect | Readability checks unchanged |
| Localization | No effect | Locale set unchanged |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | GitHub Pages free tier on the public repo; $0; no revenue share |
| Maintainability | GitHub-native Pages; a different host is a new ADR |
| Testability | Review this path now; the live URL is checked when CI publishes. Playtest builds are not this site |
| Portability | Web only, matching the supported platform |
| Security and privacy | Public release bytes only. No playtest seams. Catalog access stays ADR-0008; advice stays ADR-0002 |

## Imposes

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).

## Validation

N/A — stated in [ADR-0009](../0009-github-pages-client-host.md).
