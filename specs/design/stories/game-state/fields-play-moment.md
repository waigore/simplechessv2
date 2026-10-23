# Stories: Play fields — moment

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move](../../glossary.md), [Advice](../../glossary.md)

Split from [`fields-play.md`](fields-play.md) by scope; that file proves the run fields.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.selectedPiece | Piece under select | PS1.1 PS1.2 PS1.5 PS1.6 PS1.9 |
| GS.online | Connection observed | PS1.3 PS1.7 |
| GS.adviceBestMove | Advice best move | PS1.4 PS1.8 PS1.10 PS1.11 |
| GS.adviceEval | Advice eval | PS1.4 PS1.8 PS1.10 PS1.11 |

## PS1: Moment fields

As a casual player, I rely on transient state so that selection and advice stay consistent.

### PS1.1: Select sets

- **Proves**: GS.selectedPiece

```gherkin
Given White to move And no piece is selected
When White selects the e2 pawn
Then GS.selectedPiece is that pawn
```

### PS1.2: Deselect clears

- **Proves**: GS.selectedPiece

```gherkin
Given GS.selectedPiece is the e2 pawn
When it is deselected
Then GS.selectedPiece is none
```

### PS1.3: Offline observed

- **Proves**: GS.online

```gherkin
Given GS.online is true
When the browser goes offline
Then GS.online is false
```

### PS1.4: Advice fields pair

- **Proves**: GS.adviceBestMove, GS.adviceEval

```gherkin
Given Advice On And online And a best move is ready
When advice is set
Then GS.adviceBestMove is that move And GS.adviceEval is its eval; with no best move both are none
```

### PS1.5: Only side-to-move piece selects

- **Proves**: GS.selectedPiece

```gherkin
Given GS.sideToMove is White And a Black pawn on d5
When the Black pawn is selected
Then GS.selectedPiece remains none
```

### PS1.6: Move completion clears selection

- **Proves**: GS.selectedPiece

```gherkin
Given GS.selectedPiece is the e2 pawn
When the e2→e4 move completes
Then GS.selectedPiece is none
```

### PS1.7: Offline initial

- **Proves**: GS.online

```gherkin
Given the browser cannot reach the advice service
When the game starts
Then GS.online is false
```

### PS1.8: Advice initial none

- **Proves**: GS.adviceBestMove, GS.adviceEval

```gherkin
Given Advice Off
When a Shared game starts
Then GS.adviceBestMove is none And GS.adviceEval is none
```

### PS1.9: Selection initial none

- **Proves**: GS.selectedPiece

```gherkin
Given a Shared game is about to start
When play starts
Then GS.selectedPiece is none
```

### PS1.10: Move completion clears advice

- **Proves**: GS.adviceBestMove, GS.adviceEval

```gherkin
Given Advice On And online And GS.adviceBestMove and GS.adviceEval are set
When a legal move completes
Then GS.adviceBestMove is none And GS.adviceEval is none
```

### PS1.11: Offline clears advice

- **Proves**: GS.adviceBestMove, GS.adviceEval

```gherkin
Given Advice On And GS.online is true And GS.adviceBestMove and GS.adviceEval are set
When the browser goes offline
Then GS.adviceBestMove is none And GS.adviceEval is none
```
