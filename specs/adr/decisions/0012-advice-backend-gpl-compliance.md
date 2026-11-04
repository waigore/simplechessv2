# ADR-0012: Advice backend GPL compliance via operator-conveyed Stockfish

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-23
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; definition async time-capped Stockfish; [ADR-0002](0002-stockfish-advice-backend.md); [ADR-0010](0010-advice-backend-stack.md); [ADR-0011](0011-local-stockfish-invocation.md)

## Context

ADR-0002 records "Stockfish GPL; comply when shipping binary" and leaves the host open; [ADR-0015](0015-advice-backend-operator-deployments.md) later makes every backend operator-run. ADR-0010 and ADR-0011 fix one Python server that invokes Stockfish over local UCI, and put GPL compliance out of scope: ADR-0010's licensing row says "out of scope", ADR-0011's says it sets "no GPL procedure", and their Purpose and validation rows carry the same exclusion. No spec states whether a Stockfish binary is ever conveyed.

## Purpose

How does the project meet the GPL that Stockfish carries?

In scope: who conveys Stockfish, the source offer, license texts, attribution, and the checks that keep it true. Out of scope: host vendor and deploy path ([ADR-0015](0015-advice-backend-operator-deployments.md)), cost, and the engine choice (ADR-0002, ADR-0010).

## Decision

**The project conveys no Stockfish binary. The backend operator installs Stockfish and runs it; that operator carries the GPL duty for what it conveys and serves.**

- Nothing shipped — backend, deployment, or client build — carries a Stockfish binary, project source, or combined work. Stockfish stays a separate operator-installed program over local UCI (ADR-0011): unbundled invocation.
- The repository carries Stockfish's license text, credits, exact version, and source URL beside the backend; the project's own license and source ship through the repository.
- An operator that serves a deployed backend to players, or distributes it with Stockfish, offers the source for the exact binary it conveys and keeps the notices intact (`CMP-advice-backend`).
- ADR-0002 stands unchanged; this ADR only ends ADR-0010's and ADR-0011's exclusion.

## Reasoning

1. A separate program satisfies the GPL's aggregate rule for the Python server (ADR-0002, ADR-0011) with no combined-work analysis.
2. No bundled binary means no distributable artifact at build time (Instant play).
3. The duty lands on the party that conveys; ADR-0015 makes that party the operator too.

Costs: the operator follows the licensing constraint; the project keeps the version and source-URL record current.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Bundle Stockfish in the backend image or export | Creates a distribution duty in the project's build (Instant play) |
| Treat Stockfish as permissively licensed and skip compliance | Contradicts ADR-0002 |
| Write per-operator legal procedures here | Duplicates operator duty; ADRs are not step-by-step setup |

## Non-functional requirements

Split: [non-functional requirements](0012-advice-backend-gpl-compliance/non-functional.md) holds every table below.

### Quality expectations

No quality category is affected: no runtime code, cap, failure path, or copy changes.

### Engineering qualities

Licensing is affected: GPL v3 via ADR-0002, discharged by unbundled invocation, license text, attribution, and the operator duty.

## Imposes

See the split: one row on [`CMP-advice-backend`](../../technical/components/advice-backend.md).

## Validation

See the split: a scripted scan proves no Stockfish binary ships, and a review checks the recorded license, version, and source URL; each runs every release.
