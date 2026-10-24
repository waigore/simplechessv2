# ADR-0010: Advice backend: separate Python server, configured endpoint, API key

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-22
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: [ADR-0002](0002-stockfish-advice-backend.md); Instant play; definition async time-capped Stockfish; [F-move-advice](../../design/features/move-advice.md); Reliability; [ADR-0009](0009-github-pages-client-host.md)

## Context

[ADR-0002](0002-stockfish-advice-backend.md) puts Stockfish on a server-side advice backend and leaves the host open. `CTR-advice-stream` and `SCH-advice-update` are authored; nothing records the backend's runtime, how the client locates it, or who may call it. Epic #36 waits on that record.

## Purpose

Which runtime runs the advice backend, and how does the client reach and authenticate to it?

In scope: server separation and runtime, the configured endpoint, and simple API-key auth. Out of scope: host vendor, deploy path and reproducibility, cost envelope, GPL, and the server implementation.

## Decision

- The advice backend is a **separate Python server** from the Godot frontend; it alone is the UCI peer to Stockfish (ADR-0002 unchanged).
- The frontend opens advice traffic only to its **configured advice API endpoint**.
- Every advice request carries the **configured API key**. A missing or wrong key is an advice failure ([`FAIL.T1`](../../technical/failures.md)) that clears advice without blocking a local move.
- No host vendor or deploy path is chosen; the endpoint is configuration.
- **Client-side delivery of the configured endpoint and key is the deploy path**, so it stays out of this decision and out of `specs/`: no delivery mechanism is named there, and none is required. A key that a published bundle makes readable is accepted as an **abuse throttle**, not a secrecy boundary.
- The backend reads its key from its own **environment variable**; a request whose `api_key` does not match is rejected, and an unset variable is treated as auth failure ([`FAIL.T1`](../../technical/failures.md)), never as an open door.

## Reasoning

1. A separate server keeps UCI and Stockfish out of the browser (ADR-0002; Instant play).
2. Python minimizes a small optional service's surface and honors deploy-open.
3. A configured endpoint keeps the Pages client usable against any backend base URL.
4. One shared key is the least auth a public Web client can carry; the product has no accounts.

Cost: one extra runtime; a static per-deployment key.

## Rejected alternatives

Moved to [`rejected-alternatives.md`](0010-advice-backend-stack/rejected-alternatives.md): four options rejected against a driver. Client-side delivery of the values is not among them — it is the deploy path, outside this decision's scope.

## Non-functional requirements

### Quality expectations

Load time / latency and Reliability are Affects; the others are No effect. Detail: [non-functional requirements](0010-advice-backend-stack/non-functional.md).

### Engineering qualities

Shared secret over TLS; endpoint is portable configuration.

## Imposes

Moved to [`imposes-validation.md`](0010-advice-backend-stack/imposes-validation.md): one row per constrained spec element, including the backend's own key source.

## Validation

Moved to [`imposes-validation.md`](0010-advice-backend-stack/imposes-validation.md): each check, its method, and when it runs, including the unset-key rejection.
