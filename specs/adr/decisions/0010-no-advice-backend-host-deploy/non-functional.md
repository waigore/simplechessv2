# ADR-0010 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Context

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Decision

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Reasoning

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Rejected alternatives

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | No host is added. Advice hitch rules stay in ADR-0002 |
| Load time / latency | No effect | Advice timing stays in ADR-0002 and quality.md |
| Reliability | No effect | Failure still clears advice; play continues (ADR-0002) |
| Observability | No effect | Advice timing and errors stay in ADR-0002 |
| Save durability | No effect | Advice is not saved |
| Accessibility | No effect | No interface change |
| Localization | No effect | No player-facing copy |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Does not set fees or a GPL procedure. ADR-0002 still notes Stockfish is GPL |
| Maintainability | The server can move without a spec change |
| Testability | Tests set the configured endpoint. No deploy pipeline is in scope |
| Portability | Web client unchanged. No deploy target is required |
| Security and privacy | No host is named. ADR-0002 still requires TLS and no accounts |

## Imposes

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).

## Validation

N/A — stated in [ADR-0010](../0010-no-advice-backend-host-deploy.md).
