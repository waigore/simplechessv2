# ADR-0010: Rejected alternatives

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0010](../0010-advice-backend-stack.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). The choice is in that ADR's Decision.

## Context

N/A — the forces are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's Rejected alternatives only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Engine or backend inside the Godot client | Violates ADR-0002 server-only UCI |
| Hard-coded backend URL | Repointing a deploy would change code |
| No authentication | Open compute for anyone who finds the URL |
| Accounts or OAuth | No accounts exist; overkill for optional advice |

Client-side delivery of the configured endpoint and key is not a rejected alternative: it is the deploy path, which the parent ADR's Decision keeps out of scope without claiming a secrecy boundary for the key.

## Non-functional requirements

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — see the parent ADR's Imposes.

## Validation

N/A — see the parent ADR's Validation.
