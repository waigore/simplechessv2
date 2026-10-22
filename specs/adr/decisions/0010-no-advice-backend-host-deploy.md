# ADR-0010: No advice-backend host or deploy plan

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-22
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; definition async time-capped Stockfish; [ADR-0002](0002-stockfish-advice-backend.md)

## Context

ADR-0002 keeps Stockfish on a server and leaves the host vendor and the deploy path unspecified. The product owner decided this project will not make that choice.

## Purpose

Does the advice backend need a hosting decision and a deploy plan?

In scope: whether specs name a host or a deploy path. Out of scope: the Stockfish boundary in ADR-0002, the wire schema, a cost envelope, and a GPL procedure.

## Decision

**This project requires no hosting decision and no deploy plan for the advice backend.**

Specs do not choose a host vendor, a production URL, a deploy path, a cost envelope, or a GPL compliance procedure. The advice client opens its stream at an API endpoint given by client configuration. That value is not a production host written into specs. ADR-0002 is unchanged: Stockfish stays off the client, and a local move never waits.

## Reasoning

1. The product owner placed hosting and deploy out of scope. A later host ADR would invent that choice.
2. Instant play still holds because ADR-0002 keeps the move path off the network. Where the server runs does not change that.
3. A configured endpoint lets a build point at a server without a deploy spec.

Costs accepted: this project has no reproducible deploy path for the advice backend. The endpoint is supplied outside the specs.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| A host-vendor and deploy-path plan | The product owner said this project does not require one |
| A production URL fixed in the client | That is a hosting decision |

## Non-functional requirements

Quality and engineering rows: [non-functional requirements](0010-no-advice-backend-host-deploy/non-functional.md).

### Quality expectations

Every category is No effect. Advice targets stay in ADR-0002. Detail is in the split.

### Engineering qualities

No cost envelope, no GPL procedure, no deploy target. Detail is in the split.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`CMP-advice-backend`](../../technical/components/advice-backend.md) | Name no host vendor, production URL, or deploy path |
| [`configuration.md`](../../technical/configuration.md) | The advice API endpoint is client configuration with no production host |
| [`CMP-advice-client`](../../technical/components/advice-client.md) | Open the advice stream only at that configured endpoint |

## Validation

| Check | Method | When |
|-------|--------|------|
| Specs name no advice-backend host vendor, production URL, or deploy path | Review of `specs/adr` and `specs/technical` | Every release |
| The client uses the configured endpoint and does not embed a production host | Review of `CMP-advice-client` and technical configuration | Every release |
