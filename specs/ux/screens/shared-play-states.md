# Screen: Shared play states

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

Part of [`shared-play.md`](shared-play.md). State rows for `UI-shared-play`.

## Shows

N/A — [`shared-play.md`](shared-play.md).

## Regions

N/A — [`shared-play.md`](shared-play.md).

## Controls

N/A — [`shared-play-controls.md`](shared-play-controls.md).

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | In play | R1–R4 | C1–C5 per availability |
| S2 | `EX.confirm` | C4 or C5 | That question | Confirm runs it (resign → `shared-result`; offer → S6); Cancel → S1 |
| S3 | `EX.error` | Advice fetch failed | Error; board still playable | Dismiss → S1; C1–C5 as S1 |
| S4 | `EX.promote` | Legal pawn place on the last rank | Queen, rook, bishop, knight sprites at that square, that order, upright for the side to move | C6. C3–C5 per availability. `IN.deselect` drops the choice and leaves the pawn selected. That clock keeps running |
| S5 | `EX.rejected` | Refused place | Danger flash on that square ([PER.R8](../../view/perception.md)); selection stays | C1–C5 as S1. No Dismiss |
| S6 | `EX.draw-offer` | Offer confirmed | Draw offered. That clock keeps running | Offering seat: C9. Other seat: C7 and C8. C3 stays |

## Copy

N/A — [`shared-play.md`](shared-play.md).

## Experience intent

N/A — [`shared-play.md`](shared-play.md).
