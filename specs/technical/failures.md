# Failures

Authoring rules: [`.agents/specs/rules/technical/failures.md`](../../.agents/specs/rules/technical/failures.md).

- **Serves**: Reliability; Instant play; Observability; Save durability
- **Informed by**: [F-move-advice](../design/features/move-advice.md); [`AST.R3`](asset-access.md); [`exceptions.md`](../ux/exceptions.md); quality categories
- **ADRs**: [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md), [ADR-0003](../adr/decisions/0003-localstorage-persistence.md), [ADR-0010](../adr/decisions/0010-advice-backend-stack.md), [ADR-0013](../adr/decisions/0013-puzzle-catalog-api.md)

## Taxonomy

| ID | Class | When | Visible effect |
|----|-------|------|----------------|
| T1 | Advice unavailable | Offline, backend error, stream timeout, or missing / wrong key ([ADR-0010](../adr/decisions/0010-advice-backend-stack.md)) | Clear advice; Shared game continues (`EX.error`) |
| T2 | Persist write fail | `localStorage` setItem throws or quota | Keep prior document; log; play continues (`EX.save-failure`) |
| T3 | Persist read fail / corrupt | Missing or invalid JSON on open | Defaults: Elo start, Last mode none, empty recent; log |
| T4 | Unresolved asset ID | Manifest miss or load fail | [`AST.R3`](asset-access.md) / [`ACC.A3`](../assets/access.md) |
| T5 | Playtest seam misuse | DBG/TEL/SIT driven in a release build | No-op; never shipped |
| T6 | Load gate | Cold open until the board is playable | `EX.loading`: wait |
| T7 | Confirm gate | Destructive or hard-to-undo choice | `EX.confirm` |
| T8 | Promotion choice | Legal pawn place on the last rank | `EX.promote`: commit or drop |
| T9 | Rejected place | Piece rules refuse the place | `EX.rejected`: danger flash; position unchanged |
| T10 | Draw offer | Side to move confirmed a draw offer | `EX.draw-offer` |
| T11 | Sitting interrupt | Close, refresh, or reopen during play | `EX.interrupt`: mode pick next; no resume |
| T12 | Unsupported input | Non-touch primary input on Web | `EX.unsupported-input`: use touch; control unchanged |
| T13 | Missing locale key | A key is absent in a shipped locale | Read `en` per [`CTR-localization`](contracts/localization.md); play continues |
| T14 | Catalog read fail | Missing or wrong key, rate refusal, transport error, timeout, or bad body ([ADR-0013](../adr/decisions/0013-puzzle-catalog-api.md)) | Nothing dealt; `GS.playerElo` kept |

## Recovery

| ID | Failure | Strategy | Retry / limit |
|----|---------|----------|---------------|
| R1 | T1 | Stop eval; clear marks; retry when On+online | No busy-loop |
| R2 | T2 | Leave prior commit; log | No overwrite |
| R3 | T3 | Seed defaults; go to mode pick | Single load attempt |
| R4 | T4 | Skip draw / overlay per AST.R3 | Log once per ID |
| R5 | T6–T12 | Player follows the named `EX.*` action | No automatic retry |
| R6 | T14 | Keep Elo; deal again next turn | No busy-loop retry |

## Degraded modes

| ID | Mode | Enter when | Exit when | Behavior |
|----|------|------------|-----------|----------|
| M1 | Advice off-path | T1 or Advice Off | Advice On and online | No marks; moves unchanged |
| M2 | Persist read-only sitting | T2 after failed write | A later successful write or new sitting | In-memory Elo may diverge meanwhile |

## Diagram

None — linear recoveries.
