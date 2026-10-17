# Screen: Shared play

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../.agents/specs/rules/ux/screens.md).

- **Job**: Play one Shared game on the shared board
- **Actors**: [`bottom-player.md`](../actors/bottom-player.md), [`top-player.md`](../actors/top-player.md)
- **Serves**: Instant play, Clear board; [two-player-game](../../design/loops/two-player-game.md); [PER.R*](../../view/perception.md)
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
| R1 | Board | Position and coordinates | 8×8; edge letters/numbers only; selection and legal marks |
| R2 | Status | Turn, clocks, check | Side to move; clocks when timed; check |
| R3 | Advice | Shared Advice chrome | Toggle; best-move marks when On |
| R4 | Resign | End as loss | Resign control |

## Controls

| ID | Control | UI action | Available when | Result |
|----|---------|-----------|----------------|--------|
| C1 | Select piece | `IN.select` | Actor’s seat is side to move; not ended | Sets selection ([GS.selectedPiece](../../design/game-state/fields-play.md)) |
| C2 | Place move | `IN.move` | Selection set; actor’s seat is side to move | Asks legal place; clears selection |
| C3 | Advice | `IN.activate` | always (one shared control) | Toggles `GS.advice`; when On, advice is for side to move |
| C4 | Resign | `IN.activate` | Actor’s seat is side to move; not ended | → `EX.confirm` resign |

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default | In play | R1–R4 | C1–C4 per availability |
| S2 | `EX.confirm` | C4 | Resign confirm | Confirm → end → `shared-result`; Cancel → S1 |
| S3 | `EX.error` | Advice fetch failed | Error; board still playable | Dismiss → S1; C1–C4 still as S1 |

## Copy

| Key | String | Used in |
|-----|--------|---------|
| advice_on | Advice On | C3 |
| advice_off | Advice Off | C3 |
| resign | Resign | C4 |
| resign_confirm | Resign this game? | S2 |
| to_move | to move | R2 |

## Experience intent

Clear seats and turn; one Advice switch; moves never wait on the network.
