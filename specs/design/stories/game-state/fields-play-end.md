# Stories: Play fields — endings

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play-end.md`](../../game-state/fields-play-end.md)
- **Spec key**: `GS`
- **Glossary terms**: [Shared game](../../glossary.md), [Draw](../../glossary.md), [Side to move](../../glossary.md)

Draw-offer scenarios: [`fields-play-draw.md`](fields-play-draw.md). Other play fields: [`fields-play.md`](fields-play.md).

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.gameEnded | Initial, reset, refuse moves | PS1.1 PS1.2 PS1.3 |
| GS.drawOffer | Initial none on Shared start | PS1.1 |
| GS.repetitionHistory | Start record; game-long; run clear | PS1.1 PS1.4 PS1.5 PS1.6 |
| GS.fiftyMoveCount | Zero; increment; clears; bound | PS1.1 PS1.7 PS1.8 PS1.9 PS1.10 |

## PS1: Ending counters stay honest

As a casual player, I rely on ending fields so that draws and closed games match the rules.

### PS1.1: Shared start initials

- **Proves**: GS.gameEnded, GS.drawOffer, GS.repetitionHistory, GS.fiftyMoveCount

```gherkin
Given no run is open
When an Untimed Shared game starts
Then GS.gameEnded is false And GS.drawOffer is none And GS.repetitionHistory holds the start occurrence And GS.fiftyMoveCount is 0
```

### PS1.2: New run resets gameEnded

- **Proves**: GS.gameEnded

```gherkin
Given a Shared game ended And GS.gameEnded is true
When another Untimed Shared game starts
Then GS.gameEnded is false
```

### PS1.3: Ended game refuses moves

- **Proves**: GS.gameEnded

```gherkin
Given GS.gameEnded is true
When a move is attempted
Then GS.position is unchanged
```

### PS1.4: Capture keeps repetition history

- **Proves**: GS.repetitionHistory

```gherkin
Given an open Shared game And GS.repetitionHistory holds the start occurrence
When White captures on e5
Then GS.repetitionHistory still holds prior occurrences And adds the post-capture occurrence
```

### PS1.5: New run clears repetition history

- **Proves**: GS.repetitionHistory

```gherkin
Given a Shared game ended mid-game And GS.repetitionHistory has more than the start occurrence
When another Untimed Shared game starts
Then GS.repetitionHistory holds only the new start occurrence
```

### PS1.6: History records after a legal move

- **Proves**: GS.repetitionHistory

```gherkin
Given an open Shared game And GS.repetitionHistory holds the start occurrence
When White plays e2→e4
Then GS.repetitionHistory adds the post-move occurrence for that position, side, castling, and en passant
```

### PS1.7: Quiet move increments fifty-move count

- **Proves**: GS.fiftyMoveCount

```gherkin
Given an open Shared game And GS.fiftyMoveCount is 0
When White plays Nb1→Nc3 (no capture, not a pawn)
Then GS.fiftyMoveCount is 1
```

### PS1.8: Capture clears fifty-move count

- **Proves**: GS.fiftyMoveCount

```gherkin
Given an open Shared game And GS.fiftyMoveCount is 12
When White captures on e5
Then GS.fiftyMoveCount is 0
```

### PS1.9: Pawn move clears fifty-move count

- **Proves**: GS.fiftyMoveCount

```gherkin
Given an open Shared game And GS.fiftyMoveCount is 12
When White plays e2→e4
Then GS.fiftyMoveCount is 0
```

### PS1.10: Count stays within 0–100

- **Proves**: GS.fiftyMoveCount

```gherkin
Given an open Shared game And GS.fiftyMoveCount is 99 And the next legal move is not a capture or pawn move
When that move completes And END.D4 applies
Then GS.fiftyMoveCount is 100 And GS.gameEnded is true And the count is never above 100
```
