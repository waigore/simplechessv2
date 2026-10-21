# Stories: Shared play regions

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`shared-play.md`](shared-play.md) stories; the coverage table lives there. This file proves region visibility, citing the design for what the player can know ([game-state.md](../../../design/game-state.md) H1–H2, [two-player-game.md](../../../design/loops/two-player-game.md)).

## US2: What the board shows

As Bottom or Top player, I see the shared position and status so that both seats play the same game.

### US2.1: Coordinates on edges

- **Proves**: R1, S1

```gherkin
Given an actor is on shared-play S1
When the screen is shown
Then R1 shows file letters a–h and rank numbers 1–8 only along the outer edges And C1–C5 are available
```

### US2.2: Position shown

- **Proves**: R1

```gherkin
Given GS.position is the orthodox opening (always knowable in play, game-state H1)
When the screen is shown
Then R1 shows that position
```

### US2.3: Selection visible

- **Proves**: R1

```gherkin
Given GS.selectedPiece is the White king on e1
When the screen is shown
Then R1 highlights that piece and square
```

### US2.4: Side to move

- **Proves**: R2

```gherkin
Given GS.sideToMove is White (always knowable, game-state H1)
When the screen is shown
Then R2 shows White to move
```

### US2.5: Clocks when timed

- **Proves**: R2

```gherkin
Given Clock is Blitz and GS.whiteClock and GS.blackClock are 60 (both players know the clock, two-player-game K1)
When the screen is shown
Then R2 shows both clocks
```

### US2.6: No clocks when untimed

- **Proves**: R2

```gherkin
Given Clock is Untimed
When the screen is shown
Then R2 shows no clock
```

### US2.7: Check cue

- **Proves**: R2

```gherkin
Given the side to move is in check (derived from GS.position, game-state)
When the screen is shown
Then R2 shows the word Check and the PAL.C8 mark
```

### US2.8: Advice overlays

- **Proves**: R3

```gherkin
Given GS.advice is On and GS.online is true and GS.adviceBestMove is set
When the screen is shown
Then R3 shows best-move marks and eval without hiding piece silhouettes
```

### US2.9: Advice absent

- **Proves**: R3

```gherkin
Given GS.advice is Off or GS.online is false (not knowable, game-state H2)
When the screen is shown
Then R3 shows no best-move marks and no eval
```

### US2.10: Legal marks visible

- **Proves**: R1

```gherkin
Given GS.selectedPiece is the White king on e1 (legal moves derived from GS.position, game-state)
When the screen is shown
Then R1 marks each legal destination square
```
