# Screen: Shared play states

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

Part of [`shared-play.md`](shared-play.md). State rows for `UI-shared-play`.

- **Serves**: Instant play, Clear board, Accessibility; [two-player-game](../../design/loops/two-player-game.md); [PER.R*](../../view/perception.md)

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
| S2 | `EX.confirm` | C4 or C5 | That question | Confirm and Cancel. Confirm runs it (resign → `shared-result`; offer → S6); Cancel → S1 |
| S3 | `EX.error` | Advice fetch failed | Error; board still playable | Dismiss → S1; C1–C5 as S1 |
| S4 | `EX.promote` | Legal pawn place on the last rank | Queen, rook, bishop, knight sprites at that square, that order, upright for the side to move | C6. C3–C5 per availability. `IN.deselect` drops the choice and leaves the pawn selected. That clock keeps running |
| S5 | `EX.rejected` | Refused place | Danger flash on that square ([PER.R8](../../view/perception.md)); selection stays | C1–C5 as S1. No Dismiss |
| S6 | `EX.draw-offer` | Offer confirmed | One shared panel: Draw offered; board stays playable. That clock keeps running | C1–C3 per availability; C7–C9. A place by the side to move lapses the offer to S1 |

## Copy

N/A — [`shared-play.md`](shared-play.md).

## Notes

S4 fixes the chooser's placement and order — the four sprites sit at the promotion square, Queen, rook, bishop, knight — so promotion layout needs no separate design decision (assumption A3, PO-confirmed on #767).

## Experience intent

N/A — [`shared-play.md`](shared-play.md).
