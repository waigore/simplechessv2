# ADR-0012 non-functional requirements

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Part of [ADR-0012](../0012-advice-backend-gpl-compliance.md).

## Context

N/A — stated in [ADR-0012](../0012-advice-backend-gpl-compliance.md). This file holds the non-functional tables only.

## Purpose

N/A — stated in [ADR-0012](../0012-advice-backend-gpl-compliance.md).

## Decision

N/A — stated in [ADR-0012](../0012-advice-backend-gpl-compliance.md).

## Reasoning

N/A — stated in [ADR-0012](../0012-advice-backend-gpl-compliance.md).

## Rejected alternatives

N/A — stated in [ADR-0012](../0012-advice-backend-gpl-compliance.md).

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | No runtime code changes; Stockfish stays local UCI (ADR-0011) |
| Load time / latency | No effect | The 2000 ms cap and the non-waiting move are unchanged (ADR-0002) |
| Reliability | No effect | A missing Stockfish remains an advice failure (`FAIL.T1`) |
| Observability | No effect | Advice timing and errors stay in ADR-0002 |
| Save durability | No effect | The backend persists nothing |
| Accessibility | No effect | No interface change |
| Localization | No effect | No player-facing copy |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | GPL v3 via ADR-0002; unbundled invocation, license text, attribution, and the operator duty; no fee |
| Maintainability | The exact Stockfish version and source URL sit beside the backend and change in the same review as a version bump |
| Testability | Scripted review of the export and backend tree proves no Stockfish binary is present |
| Portability | Any platform whose operator can install Stockfish runs the backend; the Web client is unaffected |
| Security and privacy | No change to exposure; TLS and no accounts stay in ADR-0002 |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [`CMP-advice-backend`](../../../technical/components/advice-backend.md) | No Stockfish binary ships (R8); it records the license text, credits, exact version, source URL, and the operator's source offer |

## Validation

| Check | Method | When |
|-------|--------|------|
| No Stockfish binary in the export or backend tree | Scripted scan of both trees and their archives, recorded on the release issue | Every release |
| License text, credits, version, and source URL recorded beside the backend | Review against [CMP-advice-backend](../../../technical/components/advice-backend.md) R8 | Every release |
