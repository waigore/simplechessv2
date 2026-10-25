# Failures

Authoring rules: [`.agents/specs/rules/technical/failures.md`](../../.agents/specs/rules/technical/failures.md).

- **Serves**: Reliability; Instant play; Observability; Save durability
- **Informed by**: [F-move-advice](../design/features/move-advice.md); [`AST.R3`](asset-access.md); [`exceptions.md`](../ux/exceptions.md)
- **ADRs**: [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md), [ADR-0003](../adr/decisions/0003-localstorage-persistence.md), [ADR-0010](../adr/decisions/0010-advice-backend-stack.md), [ADR-0013](../adr/decisions/0013-puzzle-catalog-api.md)

## Taxonomy

| ID | Class | When | Visible effect |
|----|-------|------|----------------|
| T1 | Advice unavailable | Offline, backend error, timeout, bad key ([ADR-0010](../adr/decisions/0010-advice-backend-stack.md)) | Clear advice; play continues (`EX.error`) |
| T2 | Persist write fail | `localStorage` setItem throws or quota | Prior document kept; log; play continues (`EX.save-failure`) |
| T3 | Persist read fail | Missing or invalid JSON on open | Defaults: Elo start, Last mode none; log |
| T4 | Unresolved asset ID | Manifest miss or load fail | [`AST.R3`](asset-access.md) |
| T5 | Seam misuse | DBG/TEL/SIT driven in release | No-op; never shipped |
| T6 | Load gate | Cold open to a playable board | `EX.loading`: wait; a failed Boot load is T15 |
| T7 | Confirm gate | Destructive choice | `EX.confirm` |
| T8 | Promotion | Pawn place on the last rank | `EX.promote`: commit or drop |
| T9 | Rejected place | Piece rules refuse the place | `EX.rejected`: flash; position unchanged |
| T10 | Draw offer | Side to move offered a draw | `EX.draw-offer` |
| T11 | Interrupt | Close, refresh, or reopen during play | `EX.interrupt`: mode pick next; no resume |
| T12 | Unsupported input | Non-touch input on Web | `EX.unsupported-input`: use touch |
| T13 | Missing locale key | A shipped locale lacks a key | Read `en` per [`CTR-localization`](contracts/localization.md) |
| T14 | Catalog read fail | Bad key, refusal, transport error, timeout, or body ([ADR-0013](../adr/decisions/0013-puzzle-catalog-api.md)) | Nothing dealt; `GS.playerElo` kept |
| T15 | Boot load fail | Boot preload leaves an ID unresolved ([`CTR-asset-resolve`](contracts/asset-resolve.md) E4) | `EX.load-failure`: wait ends; Reload offered |

## Recovery

| ID | Failure | Strategy | Retry / limit |
|----|---------|----------|---------------|
| R1 | T1 | Stop eval; clear marks; retry when On+online | No busy-loop |
| R2 | T2 | Leave prior commit; log | No overwrite |
| R3 | T3 | Defaults; go to mode pick | Single attempt |
| R4 | T4 | Skip draw / overlay per AST.R3 | Log once |
| R5 | T6–T12 | Player follows the named `EX.*` action | No auto retry |
| R6 | T14 | Keep Elo; deal again next turn | No busy-loop |
| R7 | T15 | C5 Reload loads the game again from the start | No auto retry |

## Degraded modes

| ID | Mode | Enter when | Exit when | Behavior |
|----|------|------------|-----------|----------|
| M1 | Advice off-path | T1 or Advice Off | Advice On, online | No marks; moves unchanged |
| M2 | Persist read-only sitting | T2 after failed write | A later write or new sitting | In-memory Elo may diverge |

## Diagram

None — linear recoveries.
