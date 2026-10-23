# ADR-0013 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0013](../0013-puzzle-catalog-api.md).

## Context

N/A — stated in [ADR-0013](../0013-puzzle-catalog-api.md). This file holds the non-functional, Imposes, and Validation tables only.

## Purpose

N/A — stated in [ADR-0013](../0013-puzzle-catalog-api.md).

## Decision

N/A — stated in [ADR-0013](../0013-puzzle-catalog-api.md).

## Reasoning

N/A — stated in [ADR-0013](../0013-puzzle-catalog-api.md).

## Rejected alternatives

N/A — stated in [ADR-0013](../0013-puzzle-catalog-api.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | One small record per deal, off the move path (ADR-0008 row) |
| Load time / latency | Affects | Cold open never waits on the catalog; a slow route is a failed read |
| Reliability | Affects | Any read failure deals nothing, keeps Elo, never hangs (`F-puzzle-catalog` X2) |
| Observability | No effect | Key and rate refusals count server-side; client logs stay on seams |
| Save durability | No effect | Client commits stay [ADR-0003](../0003-localstorage-persistence.md) |
| Accessibility | No effect | Data route only |
| Localization | No effect | No player-facing copy on the server |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | No new service, host, or fee; snapshot stays CC0 ([ADR-0008](../0008-puzzle-catalog-storage.md)) |
| Maintainability | One Python route; a new snapshot is a new ADR-0008 decision, not a route change |
| Testability | Contract tests: key cases, the refusal, a one-record body, and a failure |
| Portability | Endpoint is configuration; the Web client reaches any reachable deployment (definition's only platform is Web) |
| Security and privacy | Key over TLS; no anonymous export; one-record responses and a rate limit stop bulk reads |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`F-puzzle-catalog`](../../../design/features/puzzle-catalog.md) | I1 selection runs host-side, so the client gets one record, never a candidate set; X2 covers key, rate, and read failures |
| [`SCH-puzzle-catalog`](../../../technical/schemata/puzzle-catalog.md) | One F1–F13 record per deal, never a list, page, or file; L2–L3 hold on the route |
| [`CMP-puzzle-session`](../../../technical/components/puzzle-session.md) | C5 reads through [`CTR-puzzle-catalog-read`](../../../technical/contracts/puzzle-catalog-read.md) |
| [`configuration.md`](../../../technical/configuration.md) | Endpoint and key are T9 and T10; the rate limit is T11 |
| [`CTR-puzzle-catalog-read`](../../../technical/contracts/puzzle-catalog-read.md) | One-record deal, key check, 30-per-minute refusal, no bulk read |

## Validation

| Check | Method | When |
|-------|--------|------|
| One record per deal; no bulk body | Automated test | Every build |
| Missing or wrong key and the 30-per-minute refusal return no record | Automated test | Every build |
| A failed read deals nothing and keeps `GS.playerElo` | Automated test | Every build |
| Bundle omits the export; move frames ignore catalog IO | Web-build review; frame-time capture | Every release |
