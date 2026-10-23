# ADR-0005: Non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0005](../0005-asset-catalog-roots.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). Roots, formats, and the manifest are in that ADR's Decision.

## Context

N/A — the forces behind quality expectations and engineering qualities are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's non-functional requirements only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

N/A — see the parent ADR's Rejected alternatives.

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | Load path technical |
| Load time / latency | Affects | Boot/play groups fit 3 s open |
| Reliability | Affects | Approved-only manifest; an unresolved ID keeps the sitting playable (A3) |
| Observability | No effect | — |
| Save durability | No effect | — |
| Accessibility | Affects | Pieces/fonts meet shape/text |
| Localization | Affects | Fonts for `en`/`zh-Hant`/`ja` |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Tool quotas outside repo; fonts licensed |
| Maintainability | Flat roots; `asset_catalog.py` |
| Testability | Catalog CI |
| Portability | Web primary |
| Security and privacy | No credentials in repo |

## Imposes

N/A — no quality target is imposed by the split; the parent ADR's Imposes are in [`imposes-validation.md`](imposes-validation.md).

## Validation

N/A — see the parent ADR's Validation; every Affects row here names its quality.md how-checked there.
