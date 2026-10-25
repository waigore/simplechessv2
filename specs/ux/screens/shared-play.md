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
| R1 | Last-move cue on from and to squares, [PAL.K9](../../aesthetics/palette/rules.md) form ([PER.R9](../../view/perception.md)) | after the first move, until the next |
| R1 | Board coordinates (a–h, 1–8) | always — edges only; White-seat flip |
| R1 | `GS.selectedPiece` | piece selected |
| R2 | `GS.whiteClock`, `GS.blackClock` | Clock is Blitz or Rapid |
| R2 | `GS.sideToMove` | always |
| R3 | `GS.adviceBestMove`, `GS.adviceEval` | Advice On and online and values set |
| R2 | Check cue: the word Check and C8 | side to move in check |

## Regions

| ID | Region | Purpose | Contents |
|----|--------|---------|----------|
| R1 | Board | Position, coordinates, and the last move | 8×8; edge letters/numbers; selection, legal, and last-move marks. `IN.deselect` clears selection |
| R2 | Status | Turn, clocks, check | Side to move; clocks; Check and C8 |
| R3 | Advice | Advice chrome | Toggle; best-move marks |
| R4 | End | Resign or draw | Resign, Offer draw |

## Controls

C1–C10 are in [`shared-play-controls.md`](shared-play-controls.md), whose order is the focus order.

## States

S1–S6 are in [`shared-play-states.md`](shared-play-states.md).

## Copy

Keys and strings are in [`shared-play-copy.md`](shared-play-copy.md).

## Experience intent

Clear seats and turn. One Advice switch. Promotion and draw stay on the board. Moves never wait on the network. Pieces read by shape; nothing by color alone; the last move stays visible; 44px-class targets.
