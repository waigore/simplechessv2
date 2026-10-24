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

In scope: server separation and runtime, the configured endpoint, and simple API-key auth. Out of scope: host vendor and deploy path ([ADR-0015](0015-advice-backend-operator-deployments.md)), cost envelope, GPL ([ADR-0012](0012-advice-backend-gpl-compliance.md)), and the server.

## Decision

- The advice backend is a **separate Python server** from the Godot frontend; it alone is the UCI peer to Stockfish (ADR-0002 unchanged).
- The frontend opens advice traffic only to its **configured advice API endpoint**.
- Every advice request carries the **configured API key**. A missing or wrong key is an advice failure ([`FAIL.T1`](../../technical/failures.md)) that clears advice without blocking a local move.
- No host vendor or deploy path is chosen; the endpoint is configuration.

## Reasoning

1. A separate server keeps UCI and Stockfish out of the browser (ADR-0002; Instant play).
2. Python minimizes a small optional service's surface and honors deploy-open.
3. A configured endpoint keeps the Pages client usable against any backend base URL.
4. One shared key is the least auth a public Web client can carry; the product has no accounts.

Cost: one extra runtime; a static per-deployment key.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Engine or backend inside the Godot client | Violates ADR-0002 server-only UCI |
| Hard-coded backend URL | Repointing a deploy would change code |
| No authentication | Open compute for anyone who finds the URL |
| Accounts or OAuth | No accounts exist; overkill for optional advice |

## Non-functional requirements

### Quality expectations

Load time / latency and Reliability are Affects; the others are No effect. Detail: [non-functional requirements](0010-advice-backend-stack/non-functional.md).

### Engineering qualities

Shared secret over TLS; endpoint is portable configuration.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`specs/technical/configuration.md`](../../technical/configuration.md) | Advice endpoint and API key are client configuration values consumed by the advice client |
| [`CMP-advice-client`](../../technical/components/advice-client.md) | Sends advice traffic only to the configured endpoint, with the configured key |
| [`CTR-advice-stream`](../../technical/contracts/advice-stream.md) | Requests carry the key; a mismatch is an advice failure that never blocks a local move |

## Validation

| Check | Method | When |
|-------|--------|------|
| Wrong or missing key fails advice; local move unblocked | Automated test | Every build |
| Client opens advice traffic only to the configured endpoint | Review rule / architecture test | Every release |
| No host vendor, deploy path, cost, or GPL text here (0015, 0012) | Spec lint | Before acceptance |
