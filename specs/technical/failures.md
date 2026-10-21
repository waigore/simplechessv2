# Failures

Authoring rules: [`.agents/specs/rules/technical/failures.md`](../../.agents/specs/rules/technical/failures.md).

- **Serves**: Reliability; Instant play; Observability; Save durability
- **Informed by**: [F-move-advice](../design/features/move-advice.md); [`AST.R3`](asset-access.md); [`exceptions.md`](../ux/exceptions.md); quality categories
- **ADRs**: [ADR-0002](../adr/decisions/0002-stockfish-advice-backend.md), [ADR-0003](../adr/decisions/0003-localstorage-persistence.md)

## Taxonomy

| ID | Class | When | Visible effect |
|----|-------|------|----------------|
| T1 | Advice unavailable | Offline, backend error, or stream timeout | Clear advice; Shared game continues. `EX.error` is Wave 3 (advice fetch while play continues), not a wave-1 state |
| T2 | Persist write fail | `localStorage` setItem throws or quota | Keep prior document; log; play continues (`EX.save-failure`) |
| T3 | Persist read fail / corrupt | Missing or invalid JSON on open | Defaults: Elo start, Last mode none, empty recent; log |
| T4 | Unresolved asset ID | Manifest miss or load fail | Per [`AST.R3`](asset-access.md) / [`ACC.A3`](../assets/access.md) |
| T5 | Playtest seam misuse | DBG/TEL/SIT drive called in a release build | No-op or compile-out; never ship the debug UI or story-ID overlay |
| T6 | Load gate | Cold open until the board is playable | `EX.loading`: wait; no mode controls yet |
| T7 | Confirm gate | Destructive or hard-to-undo choice | `EX.confirm`: confirm or cancel |
| T8 | Promotion choice | Legal pawn place on the last rank | `EX.promote`: commit a type or drop the choice |
| T9 | Rejected place | Piece rules refuse the place | `EX.rejected`: danger flash; position unchanged |
| T10 | Draw offer | Side to move confirmed a draw offer | `EX.draw-offer`: accept, decline, withdraw, or move |
| T11 | Sitting interrupt | Close, refresh, or reopen during play | `EX.interrupt`: next open is mode pick; no mid-game resume |
| T12 | Unsupported input | Non-touch primary input on Web | `EX.unsupported-input`: use touch; control unchanged |

## Recovery

| ID | Failure | Strategy | Retry / limit |
|----|---------|----------|---------------|
| R1 | T1 | Stop eval; clear marks; allow later retry when On+online | No automatic busy-loop; next position or toggle may retry |
| R2 | T2 | Leave prior commit intact | No overwrite; operator clears storage |
| R3 | T3 | Seed defaults; continue to mode pick | Single load attempt per cold open |
| R4 | T4 | Skip draw / overlay per AST.R3 / ACC.A3 | Log once per ID |
| R5 | T6–T12 | Player follows the named `EX.*` action | No automatic retry |

## Degraded modes

| ID | Mode | Enter when | Exit when | Behavior |
|----|------|------------|-----------|----------|
| M1 | Advice off-path | T1 or Advice Off | Advice On and online again | No marks; moves unchanged |
| M2 | Persist read-only sitting | T2 after failed write | Successful write or new sitting | In-memory Elo/Last mode may diverge until next success |

## Diagram

None — linear recoveries.
