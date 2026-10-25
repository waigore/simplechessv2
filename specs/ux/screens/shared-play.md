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
| R1 | Last-move cue, both squares ([PER.R9](../../view/perception.md)) | between moves |
| R1 | Board coordinates (a–h, 1–8) | always — edges only; White-seat flip |
| R1 | `GS.selectedPiece` | selected |
| R2 | `GS.whiteClock`, `GS.blackClock` | Blitz/Rapid |
| R2 | `GS.sideToMove` | always |
| R3 | `GS.adviceBestMove`, `GS.adviceEval` | Advice On, online, set |
| R2 | Check: word Check, C8 | side to move in check |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Position, coordinates, last move | 8×8; edge letters/numbers; selection, legal, last-move marks; `IN.deselect` clears selection |
| R2 | Status | Turn, clocks, check | Side to move; clocks; Check, C8 |
| R3 | Advice | Advice chrome | Toggle; best-move marks |
| R4 | End | Resign or draw | Resign, Offer draw |

## Controls

C1–C10 are in [`shared-play-controls.md`](shared-play-controls.md), in focus order.

## States

S1–S6: [`shared-play-states.md`](shared-play-states.md).

## Copy

Keys vary by locale (`en`, `zh-Hant`, `ja`); `queen`, `rook`, `bishop`, and `knight` stay `en` ([L3](../localization.md)).

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
| white_to_move | White to move | R2 |
| black_to_move | Black to move | R2 |
| check | Check | R2 |
| choose_promotion | Choose promotion | S4 |
| refused_place | Refused place | S5 |
| pawn | Pawn | R1 |
| king | King | R1 |
| queen | Queen | R1, C6 |
| rook | Rook | R1, C6 |
| bishop | Bishop | R1, C6 |
| knight | Knight | R1, C6 |

Copy owner `shared-play`; source per [localization.md](../localization.md) L1; strings resolve via the locale table ([`CTR-localization`](../../technical/contracts/localization.md)) (A1).

## Experience intent

Clear seats and turn. One Advice switch. Promotion and draw stay on the board. Moves never wait on the network. Pieces read by shape; nothing by color alone; the last move stays visible; 44px-class targets.
