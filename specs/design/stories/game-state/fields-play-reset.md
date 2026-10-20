# Stories: Play fields — start and reset

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move](../../glossary.md), [Shared game](../../glossary.md)

Split from [`fields-play.md`](fields-play.md) by logical unit; that file proves the other session fields.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.gameEnded | Initial and reset | PS1.1 PS1.2 |
| GS.drawOffer | Initial and end clear | PS1.1 |
| GS.whiteClock, GS.blackClock | Initial and reset | PS1.1 PS1.2 |
| GS.puzzleId, GS.puzzleElo | None outside a puzzle | PS1.1 |
| GS.requiredSequence, GS.sequenceIndex | None/zero outside a puzzle | PS1.1 |
| GS.wrongMoveOnPuzzle | Initial false | PS1.1 |

## PS1: Start each run clean

As a casual player, I get a clean run state so that a previous game cannot leak into the next.

### PS1.1: Shared start clears session state

- **Proves**: GS.gameEnded, GS.drawOffer, GS.whiteClock, GS.blackClock, GS.puzzleId, GS.puzzleElo, GS.requiredSequence, GS.sequenceIndex, GS.wrongMoveOnPuzzle

```gherkin
Given no session is open
When an Untimed Shared game starts
Then GS.gameEnded is false And GS.drawOffer is none And both clocks are none And GS.puzzleId and GS.puzzleElo are none And GS.requiredSequence is none And GS.sequenceIndex is 0 And GS.wrongMoveOnPuzzle is false
```

### PS1.2: New game resets the last run

- **Proves**: GS.gameEnded, GS.whiteClock, GS.blackClock

```gherkin
Given a Blitz Shared game ended And GS.whiteClock is 40 And GS.blackClock is 55
When an Untimed Shared game starts
Then GS.gameEnded is false And GS.whiteClock is none And GS.blackClock is none
```
