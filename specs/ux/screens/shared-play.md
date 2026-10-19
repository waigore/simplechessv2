# Screen: Shared play

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play one Shared game on the shared board
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Clear board, Accessibility; [two-player-game](../../design/loops/two-player-game.md); [PER.R*](../../view/perception.md)
- **Mockup**: [`../mockups/screens/shared-play.html`](../mockups/screens/shared-play.html)
- **Glossary terms**: [Board coordinates](../glossary.md); [Side to move](../../design/glossary.md), [Advice](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.position` | always |
| R1 | Board coordinates (a–h, 1–8) | always — edges only; follow White-seat flip |
| R1 | `GS.selectedPiece` | piece selected |
| R2 | `GS.whiteClock`, `GS.blackClock` | Clock is Blitz or Rapid |
| R2 | `GS.sideToMove` | always |
| R3 | `GS.adviceBestMove`, `GS.adviceEval` | Advice On and online and values set |
| R2 | Check cue | side to move in check |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Position and coordinates | 8×8; edge letters/numbers; selection and legal marks. `IN.deselect` clears the selection |
| R2 | Status | Turn, clocks, check | Side to move; clocks when timed; check |
| R3 | Advice | Shared Advice chrome | Toggle; best-move marks when On |
| R4 | End | Resign or draw | Resign; Offer draw |

## Controls

C1–C9 are in [`shared-play-controls.md`](shared-play-controls.md). Focus order is that table.

## States

S1–S6 are in [`shared-play-states.md`](shared-play-states.md).

## Copy

| Key | String | Used in |
|-----|--------|---------|
| advice_on | Advice On | C3 |
| advice_off | Advice Off | C3 |
| resign | Resign | C4 |
| resign_confirm | Resign this game? | S2 |
| offer_draw | Offer draw | C5 |
| offer_confirm | Offer a draw? | S2 |
| accept | Accept | C7 |
| decline | Decline | C8 |
| withdraw | Withdraw | C9 |
| draw_offered | Draw offered | S6 |
| confirm | Confirm | S2 |
| cancel | Cancel | S2 |
| advice_error | Advice unavailable. Play continues. | S3 |
| dismiss | Dismiss | S3 |
| to_move | to move | R2 |

## Experience intent

Clear seats and turn. One Advice switch. Promotion and draw stay on the board. Moves never wait on the network. Pieces read by shape; nothing by color alone; 44px-class targets.
