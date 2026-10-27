# ADR-0016: No public client host

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-25
- **Category**: Integration
- **Supersedes**: ADR-0009
- **Informed by**: Cafe calm (vision); No-install Web commute (definition); Load time / latency (quality); uncommitted `build/web/` ([ADR-0007](0007-web-export-output.md)); no public release ([ADR-0015](0015-advice-backend-operator-deployments.md))

## Context

The definition requires a no-install Web commute: a person opens the game in a browser. ADR-0007 writes the export to uncommitted `build/web/` and names no host. The owner decided the project publishes no public release (ADR-0015).

## Purpose

Does the project operate a public client host?

In scope: whether a project URL or project-operated host exists. Out of scope: the advice backend, the catalog route, and how an operator serves their own copy.

## Decision

The project publishes no public client. There is no project URL and no project-operated host. A Web export stays an uncommitted local artifact in `build/web/` (ADR-0007). An operator may serve their own copy; the project does not deploy that copy.

## Reasoning

1. ADR-0015 records that no public release exists. A project client site would be that release.
2. The no-install commute is a local or operator-served browser export (ADR-0007).
3. Cafe calm: no hosted service to run.

Cost: a playtest reads a local export of the commit under test.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| A project-operated static host | The owner closed a public release (ADR-0015) |
| A free project URL for playtests | That URL is a public release |

## Non-functional requirements

### Quality expectations

| Category | Effect | How this decision meets or limits the target |
|----------|--------|----------------------------------------------|
| Performance | No effect | Frame time is unchanged |
| Load time / latency | No effect | The cold-open check stays local; this decision adds no host |
| Reliability | No effect | No new failure path |
| Observability | No effect | Logs stay local |
| Save durability | No effect | Persistence is unchanged |
| Accessibility | No effect | No interface change |
| Localization | No effect | Copy is unchanged |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | No host fee |
| Maintainability | No site to operate |
| Testability | The build under test is a local export |
| Portability | Web export is unchanged (ADR-0007) |
| Security and privacy | No project client origin is exposed |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`specs/playtest/procedures.md`](../../playtest/procedures.md) Prep | The build under test is a local export or an in-process run of the commit, never a project URL |

## Validation

| Check | Method | When |
|-------|--------|------|
| No project client URL and no publish step | Review of workflows and this ADR | Before acceptance |
| Load time still checked on a local cold open | [`quality.md`](../../definition/quality.md) Load time / latency | Every release |
