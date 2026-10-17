# Stories: Game state

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state.md`](../game-state.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move](../glossary.md), [Required sequence](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| GS.selectedPiece | PS1.1 | GS.position | PS1.2 PS1.3 |
| GS.sideToMove | PS1.2 | GS.whiteClock / blackClock | PS1.4 |
| GS.gameEnded | PS1.5 | GS.puzzleId / puzzleElo | PS1.6 |
| GS.requiredSequence / sequenceIndex | PS1.7 | GS.wrongMoveOnPuzzle | PS1.8 |
| GS.online / adviceBestMove / adviceEval | PS1.9 | GS.playerElo / lastMode | PS1.10 |
| GS.recentSolved | PS1.11 | GS.whiteSeat / clock / increment / advice | PS1.12 |
| GS.locale | PS1.13 | V1 | PS1.14 |
| V2 | PS1.4 | V3 | PS1.15 |
| H1 | PS1.16 | H2 | PS1.9 |
| Q1 | PS1.17 | | |

## PS1: Scoped fields

As a casual player, I rely on consistent state so that legality and Elo stay trustworthy.

### PS1.1–PS1.3: Selection and position

- **Proves**: GS.selectedPiece, GS.position, GS.sideToMove

```gherkin
Given Shared K1 done
When play begins Then GS.position is the orthodox opening And GS.sideToMove is White
Given White's e2 pawn When selected Then GS.selectedPiece is that piece; when deselected, none
Given Puzzle Wrong move When reset Then GS.position is the dealt start
```

### PS1.4–PS1.5: Clocks and end

- **Proves**: GS.whiteClock, GS.blackClock, V2, GS.gameEnded

```gherkin
Given timed Shared And GS.sideToMove White And not ended
When observed Then only White's clock runs And both ≥ 0
Given GS.gameEnded true When a Shared move is attempted Then GS.position unchanged
```

### PS1.6–PS1.8: Puzzle fields

- **Proves**: GS.puzzleId, GS.puzzleElo, GS.requiredSequence, GS.sequenceIndex, GS.wrongMoveOnPuzzle

```gherkin
Given deal of puzzle P Elo 1050 Then GS.puzzleId is P And GS.puzzleElo is 1050 (fixed for that puzzle)
Given sequence length 3 When first match played Then GS.sequenceIndex is 1
Given wrongMove false When Wrong move Then wrongMove true until new deal
```

### PS1.9–PS1.13: Advice, persist, config

- **Proves**: GS.online, GS.adviceBestMove, GS.adviceEval, H2, GS.playerElo, GS.lastMode, GS.recentSolved, GS.whiteSeat, GS.clock, GS.increment, GS.advice, GS.locale

```gherkin
Given Shared Advice On online And best move ready Then player can know adviceBestMove and adviceEval; none pairs with none
Given Elo 1100 lastMode Puzzle When reopen Then both remain
Given recentSolved length 20 When W1 appends Then length 20 newest last
Given Shared started with seat/clock/increment locked Then those stay locked And Advice may toggle
Given locale ja Then locale is one of en, zh-Hant, ja
```

### PS1.14–PS1.17: Invariants and knowledge

- **Proves**: V1, V3, H1, Q1

```gherkin
Given sideToMove White When Black changes position Then unchanged
Given Puzzle stream Then adviceBestMove and adviceEval are none
Given open puzzle before reveal Then player can know position and sideToMove And cannot know full Required sequence
Given same Elo/history and multiple candidates When two deals Then chosen puzzle need not match
```
