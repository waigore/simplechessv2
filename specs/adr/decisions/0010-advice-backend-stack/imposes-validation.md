# ADR-0010: Imposes and validation

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0010](../0010-advice-backend-stack.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). The separate server, the configured endpoint, and the key rules are in that ADR's Decision.

## Context

N/A — the forces behind these constraints are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's Imposes and Validation tables only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

N/A — see [`rejected-alternatives.md`](rejected-alternatives.md).

## Non-functional requirements

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`specs/technical/configuration.md`](../../../technical/configuration.md) | Advice endpoint and API key are client configuration values consumed by the advice client |
| [`CMP-advice-client`](../../../technical/components/advice-client.md) | Sends advice traffic only to the configured endpoint, with the configured key |
| [`CMP-advice-backend`](../../../technical/components/advice-backend.md) | Reads its key from its own environment variable; a mismatch is rejected and an unset variable is auth failure, not an open door |
| [`CTR-advice-stream`](../../../technical/contracts/advice-stream.md) | Requests carry the key; a mismatch is an advice failure that never blocks a local move |

## Validation

| Check | Method | When |
|-------|--------|------|
| Wrong or missing key fails advice; local move unblocked | Automated test | Every build |
| Client opens advice traffic only to the configured endpoint | Review rule / architecture test | Every release |
| Backend takes its key from its environment variable; an unset variable rejects every request | Automated test | Every build |
| No host vendor, deploy path, cost, or GPL text; GPL is ADR-0012 | Spec lint | Before acceptance |
