# Screen: Shared play

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play one Shared game
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Clear board, Accessibility; [two-player-game](../../design/loops/two-player-game.md); [PER.R*](../../view/perception.md)
- **Mockup**: [`../mockups/screens/shared-play.html`](../mockups/screens/shared-play.html)
- **Glossary terms**: [Board coordinates](../glossary.md); [Side to move](../../design/glossary.md), [Advice](../../design/glossary.md)

## Shows

| Shown in | Design element | Visible when |
|----------|----------------|--------------|
| R1 | `GS.position` | always |
| R1 | Board coordinates (a–h, 1–8) | always — edges only; follow seat flip |
| R1 | `GS.selectedPiece` | piece selected |
| R2 | `GS.whiteClock`, `GS.blackClock` | Clock is Blitz or Rapid |
| R2 | `GS.sideToMove` | always |
| R3 | `GS.adviceBestMove`, `GS.adviceEval` | Advice On, online, values set |
| R2 | Check cue: word Check and [PAL.C8](../../aesthetics/palette.md) | in check |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Position and coordinates | 8×8; edge letters/numbers; selection and legal marks; `IN.deselect` clears selection |
| R2 | Status | Turn, clocks, check | Side to move; clocks when timed; Check word and [PAL.C8](../../aesthetics/palette.md) |
| R3 | Advice | Shared Advice chrome | Toggle; best-move marks |
| R4 | End | Resign or draw | Resign; Offer draw |

## Controls

C1–C10 are in [`shared-play-controls.md`](shared-play-controls.md), the focus order.

## States

S1–S6: [`shared-play-states.md`](shared-play-states.md).

## Copy

All keys vary by locale (`en`, `zh-Hant`, `ja`) except the six piece-type names (L7): they stay `en`, are never drawn, and compose a piece's accessible name ([R7](../../technical/components/presentation.md)).

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

Copy owner `shared-play`; keys and `en` per [localization.md](../localization.md) L1; strings resolve through the locale's string table ([`CTR-localization`](../../technical/contracts/localization.md)) (A1).

## Experience intent

Clear seats, turn, one Advice switch. Promotion and draw stay on the board; moves never wait on the network. Pieces read by shape; nothing by color alone.
