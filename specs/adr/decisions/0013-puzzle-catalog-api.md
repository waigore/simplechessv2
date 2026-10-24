# ADR-0013: Puzzle catalog API on the advice server

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-23
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Cafe calm (vision); Puzzle stream (definition); Performance, Reliability (quality); [DIF.Y1](../../design/difficulty.md); [F-puzzle-catalog](../../design/features/puzzle-catalog.md) I1 X2; [ADR-0008](0008-puzzle-catalog-storage.md), [ADR-0010](0010-advice-backend-stack.md)

## Context

[ADR-0008](0008-puzzle-catalog-storage.md) keeps snapshot `2026-10-05` host-side and off the client, readable only through a secured API, and leaves credentials out of scope. [ADR-0009](0009-github-pages-client-host.md) excludes the catalog from Pages. [ADR-0010](0010-advice-backend-stack.md) gives advice a separate Python server with a configured endpoint and shared key. No spec fixes the catalog host, serve path, or key check.

## Purpose

Where is the puzzle catalog served from, and how may the browser read it? In scope: service, route, key, response shape, selection, rapid-fire limit. Out of scope: the snapshot, the Elo formula, session play, a new vendor, its host ([ADR-0015](0015-advice-backend-operator-deployments.md)).

## Decision

- The catalog API is a **second route on the advice Python server** ([ADR-0010](0010-advice-backend-stack.md)): same host, endpoint, **API key**, deploy path, cost. No new vendor.
- The server stores the ADR-0008 snapshot and **selects one puzzle** per request by [DIF.Y1](../../design/difficulty.md): Rating within ±`CFG.ELO_MATCH_RANGE` of the sent Elo, preferring an id outside the sent recent ids, then the `DIF.Y1` relax ladder until one fits.
- A request carries **`GS.playerElo`**, recent solved ids, and the key; success returns **exactly one** `SCH-puzzle-catalog` F1–F13 record.
- **No list, page, or file operation.** The raw export is never a public static file or client bytes. The snapshot is immutable once served; PuzzleIds stay its own.
- A missing or wrong key, a refused rapid-fire request, or any other read failure returns **no record**: nothing is dealt and `GS.playerElo` is unchanged (`F-puzzle-catalog` X2).
- The server refuses more than **30 deal requests per key per minute**; a refusal is that failure. A sitting deals about once a minute, so a copied key cannot walk the snapshot.

## Reasoning

In driver order: cafe calm and Instant play favor one server (endpoint and key already exist); load time and Performance ([ADR-0008](0008-puzzle-catalog-storage.md)) require a host-side snapshot and one record per deal; Reliability requires a failed read to cost only the deal. The host is the operator's ([ADR-0015](0015-advice-backend-operator-deployments.md)).

Cost: each deal waits on the host; a dead server means no deals.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Dedicated catalog service | A second host and deploy for one route |
| Static JSON behind a key | Key ships in the bundle; no server check |
| A filtered slice in the client | Reintroduces a client catalog |
| No rate limit | A copied key could enumerate the snapshot |

## Non-functional requirements

### Quality expectations

Affects: Performance, Load time / latency, and Reliability, per the [split](0013-puzzle-catalog-api/non-functional.md); the rest are No effect.

### Engineering qualities

No new service, host, or fee; one testable route. Detail: split.

## Imposes

N/A — in the [split](0013-puzzle-catalog-api/non-functional.md): one record per deal, host-side selection, and T9–T11 config.

## Validation

N/A — in the [split](0013-puzzle-catalog-api/non-functional.md).
