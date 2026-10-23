# ADR-0004 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0004](../0004-dual-playtest-environments.md).

## Context

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md). This file holds the non-functional tables and Validation only.

## Purpose

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md).

## Decision

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md).

## Reasoning

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md).

## Rejected alternatives

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | Affects | Playtest I/O must not redefine the 60 fps player path (quality.md Performance) |
| Load time / latency | No effect | Playtest builds are not the cold-open bar |
| Reliability | Affects | Sessions complete without engine-forced exit within the sitting soak (quality.md Reliability, 15–40 minutes) |
| Observability | Affects | `TEL.*` and story IDs visible for agent playtests (quality.md Observability) |
| Save durability | No effect | ADR-0003 |
| Accessibility | No effect | — |
| Localization | No effect | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Godot MIT; no extra fee |
| Maintainability | Two profiles; upgrade with Godot line |
| Testability | Native headless + Web graphical; Must tools in both |
| Portability | Web primary; headless for CI hosts |
| Security and privacy | Debug seams not in public release |

## Imposes

N/A — stated in [ADR-0004](../0004-dual-playtest-environments.md).

## Validation

| Check | Method | When |
|-------|--------|------|
| Headless Design protocol | Spike: `--headless` + one Design protocol | Before acceptance |
| Graphical UX screenshots | Spike: Web + one UX protocol evidence | Before acceptance |
| Observability story IDs | quality.md playtest check | Every release |
| 60 fps with playtest I/O | quality.md frame-time capture | Every release |
| Sessions without engine-forced exit | quality.md Reliability sitting soak, in the Headless and Graphical playtest builds | Every release |
