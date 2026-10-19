# Screen: Shared play controls

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

Part of [`shared-play.md`](shared-play.md). Control rows for `UI-shared-play`.

## Shows

N/A — [`shared-play.md`](shared-play.md).

## Regions

N/A — [`shared-play.md`](shared-play.md).

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Select piece | `IN.select` | Side to move; not ended; not S2 or S4 | Sets `GS.selectedPiece` |
| C2 | Place move | `IN.move` | Selection set; side to move; not ended; not S2 or S4 | Legal place clears selection and lapses S6. Last-rank pawn → S4. Refused place → S5; selection stays |
| C3 | Advice | `IN.activate` | Not ended; not S2 | Toggles `GS.advice` |
| C4 | Resign | `IN.activate` | Side to move; not ended; not S2 or S6 | → `EX.confirm` resign |
| C5 | Offer draw | `IN.activate` | Side to move; not ended; not S2 or S6 | → `EX.confirm` offer |
| C6 | Promotion piece | `IN.activate` | S4 | Commits tapped Q, R, B, or N ([I33](../../design/entities/pieces/pawn.md)) |
| C7 | Accept draw | `IN.activate` | S6 | Accepts [END.D2](../../design/end-conditions/conditions.md) → `shared-result` |
| C8 | Decline draw | `IN.activate` | S6 | → S1; same side to move; that clock still runs |
| C9 | Withdraw offer | `IN.activate` | S6 | → S1; same side to move; that clock still runs |

`EX.draw-offer` is one shared panel. Accept and Decline are the other seat's social role; Withdraw is the offering seat's. The interface does not identify people.

## States

N/A — [`shared-play.md`](shared-play.md).

## Copy

N/A — [`shared-play.md`](shared-play.md).

## Experience intent

N/A — [`shared-play.md`](shared-play.md).
