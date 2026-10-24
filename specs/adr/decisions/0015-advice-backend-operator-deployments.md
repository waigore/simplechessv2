# ADR-0015: Advice backend deployments are operator/player-run only

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Proposed
- **Date**: 2026-10-25
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Instant play; Cafe calm (vision); [F-move-advice](../../design/features/move-advice.md); [ADR-0009](0009-github-pages-client-host.md), [ADR-0010](0010-advice-backend-stack.md), [ADR-0011](0011-local-stockfish-invocation.md), [ADR-0012](0012-advice-backend-gpl-compliance.md), [ADR-0013](0013-puzzle-catalog-api.md)

## Context

ADR-0010 chooses no host vendor or deploy path. ADR-0013 and `CMP-catalog-service` R8 nonetheless presuppose **a** backend host and deploy path, and `configuration.md` T9/T10 say "set per deployment". Nothing records whether that host is ever the project's. The product owner answered on #505: the game is experimental with no public release; the Advice control stays and works only against an operator/player-run backend configured through T9/T10.

**Open question:** does the owner approve that ADR-0013's host and deploy path is the operator's, narrowing what that Accepted ADR implies? Until then this record is Proposed.

## Purpose

Whose host and deploy path do the advice server and its catalog route run on?

In scope: the deployment posture. Out of scope: vendor, URL, cost, TLS host, deploy plan, T9/T10 delivery (#479), the GPL procedure (#459), and advice timing.

## Decision

- **The project deploys no backend.** Every backend is an operator's or player's own: they install the Python server and Stockfish, configuring T9/T10. No public release exists; the playtest and local builds are the builds that exist.
- **ADR-0013's host and deploy path is the operator's.** The catalog route runs beside advice there; the project supplies no second host.
- **Unconfigured stays a failure.** A client without T9/T10 fails advice as `FAIL.T1`; the control stays visible (`UI-shared-setup.C4`) and play continues.

## Reasoning

1. Cafe calm and Instant play: no hosted service to run or pay for.
2. ADR-0012 already puts Stockfish and its GPL duty on the operator; the host follows the same party.
3. The client is configuration-driven (ADR-0010), so where it points never changes code.

Costs: advice and puzzle deals exist only where someone runs a backend.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| A project-hosted backend | Reopens the host the owner closed (#112, #505) |
| Declare a reference deployment | Chooses a vendor and URL no decision supports |

## Non-functional requirements

### Quality expectations

No quality category is affected. Detail: [non-functional requirements](0015-advice-backend-operator-deployments/non-functional.md).

### Engineering qualities

Licensing and cost, maintainability, and security are affected; all rows are in the split.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`CMP-catalog-service`](../../technical/components/catalog-service.md) R8 | The host and deploy path are the operator's |
| [`specs/adr/decisions/0013-puzzle-catalog-api.md`](0013-puzzle-catalog-api.md) Purpose | Names this ADR as owner of that host |
| [`specs/definition/quality.md`](../../definition/quality.md) Load time / latency | Untouched; its method stays with the row's owners |

## Validation

| Check | Method | When |
|-------|--------|------|
| No project backend host, URL, or deploy plan in specs | Spec lint plus review | Before acceptance |
| The docs cite this posture as Proposed until approved | Review rule | Every release |
