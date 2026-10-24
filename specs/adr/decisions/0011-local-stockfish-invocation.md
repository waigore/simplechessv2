# ADR-0011: Python server invokes Stockfish locally

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-22
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; definition async time-capped Stockfish; Load time / latency; [ADR-0002](0002-stockfish-advice-backend.md); [ADR-0010](0010-advice-backend-stack.md)

## Context

ADR-0002 makes the advice backend the only UCI peer. The client never talks to Stockfish. ADR-0010 makes that backend one Python server. The product owner wants that server to invoke Stockfish itself, as part of the same server, with fewer network connections.

## Purpose

How does the Python advice server reach Stockfish?

In scope: who invokes Stockfish, and whether that link is a network connection. Out of scope: host vendor and deploy path ([ADR-0015](0015-advice-backend-operator-deployments.md)), the advice wire schema, the API key (ADR-0010), and GPL ([ADR-0012](0012-advice-backend-gpl-compliance.md)).

## Decision

**The Python advice server invokes Stockfish locally. They are the same server.**

The Python server starts Stockfish. The UCI link is local, not a network connection. Advice has one network connection: the client to this server. ADR-0002 and ADR-0010 stay as they are.

## Reasoning

1. The product owner asked for one server and fewer network connections. A second hop to a remote Stockfish would add one.
2. Local engine traffic keeps the 2000 ms cap and the non-waiting move (ADR-0002).
3. Local UCI keeps Stockfish off the browser (ADR-0002).

Costs accepted: the Python server and Stockfish live and fail together. This ADR does not say where that server runs; [ADR-0015](0015-advice-backend-operator-deployments.md) does.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Stockfish as its own networked service | Adds a network connection the product owner said to avoid |
| Stockfish inside the browser | Already rejected by ADR-0002 |
| The client speaks UCI | The client must talk only to the Python server |

## Non-functional requirements

Quality and engineering rows: [non-functional requirements](0011-local-stockfish-invocation/non-functional.md).

### Quality expectations

Load time / latency is Affects. The other categories are No effect. Detail is in the split.

### Engineering qualities

One Python server, local UCI, no extra network hop. Detail is in the split.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`CMP-advice-backend`](../../technical/components/advice-backend.md) | Python server invokes Stockfish over local UCI. That link is not a network connection |
| [`modules.md`](../../technical/modules.md) M2, B2 | Stockfish stays inside the same server. B2 is local UCI, not a network boundary |
| [`SEQ-advice-stream`](../../technical/sequences/advice-stream.md) S3 | The search step uses local UCI on that server |

## Validation

| Check | Method | When |
|-------|--------|------|
| Stockfish is local UCI inside the Python server | Review of C2, B2, and S3 | Every release |
| A local move still does not wait on advice | Timed advice readiness while moving without waiting (quality.md) | Every release |
