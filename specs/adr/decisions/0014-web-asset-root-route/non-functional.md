# ADR-0014: Non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0014](../0014-web-asset-root-route.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). The route is in that ADR's Decision.

## Context

N/A — the forces are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's non-functional tables only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

N/A — see [`rejected-alternatives.md`](rejected-alternatives.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Frame budget unchanged; assets load as before |
| Load time / latency | Affects | Boot files resolve from the shipped tree, so the 3 s cold open is reachable instead of stalled (#630) |
| Reliability | Affects | Reopen at mode pick needs a build that leaves `EX.loading` |
| Observability | Affects | The check prints asset-file and audio-copy counts at export, before publishing |
| Save durability | No effect | Persistence is ADR-0003 |
| Accessibility | No effect | Readability checks unchanged |
| Localization | No effect | The same fonts and strings ship, in the same bytes |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | No new tool or fee; each copied file's license travels with it |
| Maintainability | One script owns staging and cleanup; names come from the manifest and the resolver constant |
| Testability | `test_web_export.py` drives the check red and green and the staging/cleanup with a stand-in engine |
| Portability | Web only; other platforms keep the repo-root read (ADR-0005) |
| Security and privacy | Public client bytes; no new data or network exposure |

## Imposes

N/A — see the parent ADR's Imposes.

## Validation

N/A — see the parent ADR's Validation.
