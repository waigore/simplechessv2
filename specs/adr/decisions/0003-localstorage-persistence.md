# ADR-0003: localStorage persistence

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: PRG.P1 P2 M1; GS.playerElo lastMode recentSolved; Save durability; Reliability; no-install Web; ADR-0001

## Context

Elo, Last mode, and recent solved IDs must survive sittings until this origin’s storage is cleared. Failed writes must keep the prior commit.

## Purpose

Which browser storage API holds persistent fields for this origin?

In scope: storage product, commit shape, failure semantics. Out of scope: field schema (technical), cloud sync.

## Decision

Persist in origin-scoped **`localStorage`** as one JSON document for this game: at least **Player Elo**, **Last mode**, and **recent solved IDs** (max 20) ([fields-persist](../../design/game-state/fields-persist.md)). A successful write replaces the whole document. A failed write leaves the previous document intact. Clearing this origin’s storage resets per [PRG](../../design/progression.md).

## Reasoning

1. Tiny payload; sync read aids cold open.
2. Matches browser storage and no-install Web.
3. Whole-document replace gives a clear prior-commit durability story.
4. IndexedDB/`user://` add complexity without benefit at this size.

Costs accepted: the synchronous API and the ~5 MB origin quota.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| IndexedDB | Overkill for small JSON |
| Godot `user://` only | Less direct for origin-clear and atomic replace on Web |
| Server-side save | No accounts; out of scope |

## Non-functional requirements

### Quality expectations

| Category | Effect | How |
|----------|--------|-----|
| Performance | No effect | Tiny reads/writes |
| Load time / latency | Affects | Sync read must not dominate cold open |
| Reliability | Affects | After fault, reopen shows last committed Elo and Last mode |
| Observability | Affects | Persist failures visible for playtests/UX |
| Save durability | Affects | Quit/crash/reload keep commit; failed write keeps prior |
| Accessibility | No effect | — |
| Localization | No effect | — |

### Engineering qualities

| Quality | Assessment |
|---------|------------|
| Licensing and cost | Browser API; no fee |
| Maintainability | Simple; quota far above need |
| Testability | Mock `localStorage` in tests |
| Portability | Web primary only |
| Security and privacy | Origin-scoped; no secrets; user can clear |

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| None | — |

## Validation

| Check | Method | When |
|-------|--------|------|
| Reload keeps Elo and Last mode | quality.md quit/reload | Every release |
| Failed write keeps prior | quality.md forced fail | Every release |
| Cold open includes sync read | quality.md timed cold open | Every release |
| Persist failures in logs | quality.md log check | Every release |
