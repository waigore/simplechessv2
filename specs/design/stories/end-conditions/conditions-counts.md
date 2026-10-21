# Stories: Draw-count thresholds

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions/conditions.md`](../../end-conditions/conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Shared game](../../glossary.md), [Draw](../../glossary.md)

Split from [`conditions.md`](conditions.md) by logical unit; that file proves the other Shared-game conditions.

## Coverage

| Element | Scenarios |
|---------|-----------|
| D3 | PS1.1 PS1.2 PS1.3 |
| D4 | PS1.4 PS1.5 PS1.6 |

## PS1: Reach a count draw

As a casual player, I finish a Shared game so that repetition and fifty-move draws match the counts.

### PS1.1: Second repetition continues

- **Proves**: D3

```gherkin
Given same position, side, rights a second time
When checked after a move
Then play continues
```

### PS1.2: Third repetition draws

- **Proves**: D3

```gherkin
Given same position, side, rights a third time
When checked after a move
Then draw And GS.gameEnded true
```

### PS1.3: Fourth repetition stays drawn

- **Proves**: D3

```gherkin
Given same position, side, rights a fourth time And the D3 draw already applied at the third
When checked after a move
Then draw And GS.gameEnded true
```

### PS1.4: Forty-nine moves continue

- **Proves**: D4

```gherkin
Given forty-nine moves each, no capture or pawn move
When checked after a move
Then play continues
```

### PS1.5: Fifty moves draw

- **Proves**: D4

```gherkin
Given fifty moves each, no capture or pawn move
When checked after a move
Then draw And GS.gameEnded true
```

### PS1.6: Fifty-one moves stays drawn

- **Proves**: D4

```gherkin
Given fifty-one moves each, no capture or pawn move And the D4 draw already applied at fifty
When checked after a move
Then draw And GS.gameEnded true
```
