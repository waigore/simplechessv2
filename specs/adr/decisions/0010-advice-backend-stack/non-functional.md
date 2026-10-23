# ADR-0010 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0010](../0010-advice-backend-stack.md).

## Context

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md).

## Decision

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md).

## Reasoning

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md).

## Rejected alternatives

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | The key check does not run in the client loop |
| Load time / latency | Affects | Key check adds no client latency; the 2000 ms advice target is unchanged |
| Reliability | Affects | Missing or wrong key is an advice failure; play continues (`FAIL.T1`) |
| Observability | No effect | Key rejections log on the backend like other `FAIL.T1` causes |
| Save durability | No effect | — |
| Accessibility | No effect | — |
| Localization | No effect | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | GPL approach: [ADR-0012](../0012-advice-backend-gpl-compliance.md) — this stack ships no Stockfish binary, so the conveying operator carries the GPL duty; accepted cost is one extra runtime |
| Maintainability | Python runtime fixed at implementation; [ADR-0002](../0002-stockfish-advice-backend.md) engine isolation unchanged |
| Testability | Contract tests exercise right, wrong, and missing keys against a local server |
| Portability | Endpoint is configuration; any host reachable from the browser works; deploy stays open |
| Security and privacy | Shared secret over TLS at the endpoint; the key is a client configuration value set per deployment, never committed; positions still sent only when Advice On |

## Imposes

N/A — stated in [ADR-0010](../0010-advice-backend-stack.md).

## Validation

| Check | Method | When |
|-------|--------|------|
| Wrong or missing key fails advice; local move unblocked | Automated test | Every build |
| Client opens advice traffic only to the configured endpoint | Review rule / architecture test | Every release |
