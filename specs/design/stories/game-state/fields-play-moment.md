# Stories: Play fields — moment

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`game-state/fields-play.md`](../../game-state/fields-play.md)
- **Spec key**: `GS`
- **Glossary terms**: [Side to move)](../../glossary.md), [Advice)](../../glossary.md)

Split from [`fields-play.md`](fields-play.md) by scope; that file proves the session and run fields.

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| GS.selectedPiece | Piece under select | PS1.1 PS1.2 PS1.5 |
| GS.online | Connection observed | PS1.3 |
| GS.adviceBestMove | Advice best move | PS1.4 |
| GS.adviceEval | Advice eval | PS1.4 |

## PS1: Moment fields

As a casual player, I rely on transient state so that selection and advice stay consistent.

### PS1.1: Select sets

- **Proves**: GS.selectedPiece

```gherkin
Given White to move
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
