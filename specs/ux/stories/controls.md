# Stories: Controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls.md`](../controls.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| IN.confirm | Confirm | US1.1 |
| IN.cancel | Cancel | US1.2 |
| IN.back | Back | US1.3 |
| IN.point | Point | US3.1 US3.2 US3.3 US3.4 US3.5 |
| IN.activate | Activate | US1.4 |
| IN.select | Select | US1.5 |
| IN.move | Move | US1.6 US2.1 |
| IN.deselect | Clear | US1.7 US1.8 US2.2 US2.3 US2.4 |
| B1 | Activate | US1.4 |
| B2 | Select | US1.5 |
| B3 | Move | US1.6 |
| B4 | Confirm | US1.1 |
| B5 | Cancel | US1.2 |
| B6 | Back | US1.3 |
| B7 | Point | US3.1 US3.2 US3.3 US3.4 US3.5 |
| B8 | Clear piece | US1.7 |
| B9 | Clear empty | US1.8 |
| B10 | Drag move | US2.1 |
| B11 | Drag clear | US2.2 US2.3 US2.4 |
| F1 | Focus | US3.1 US3.2 US3.3 US3.4 US3.5 |

US2: [`controls-drag.md`](controls-drag.md). US3: [`controls-point.md`](controls-point.md).

## US1: Web tap bindings

As an actor on Web, I tap so the matching action fires.

### US1.1: Confirm

- **Proves**: IN.confirm, B4

```gherkin
Given EX.confirm is open on Web
When the actor taps Confirm
Then IN.confirm activates and no other action activates
```

### US1.2: Cancel

- **Proves**: IN.cancel, B5

```gherkin
Given EX.confirm is open on Web
When the actor taps Cancel
Then IN.cancel activates and no other action activates
```

### US1.3: Back

- **Proves**: IN.back, B6

```gherkin
Given shared-setup S1 on Web
When the actor taps Back
Then IN.back activates and no other action activates
```

### US1.4: Activate

- **Proves**: IN.activate, B1

```gherkin
Given mode-pick S1 on Web
When the actor taps Shared game
Then IN.activate fires on UI-mode-pick.C1 and no other action activates
```

### US1.5: Select

- **Proves**: IN.select, B2

```gherkin
Given shared-play S1, own seat to move, piece not selected
When the actor taps their piece
Then IN.select fires on UI-shared-play.C1 and no other action activates
```

### US1.6: Tap move

- **Proves**: IN.move, B3

```gherkin
Given shared-play S1 with a selection
When the actor taps a legal destination square
Then IN.move fires on UI-shared-play.C2 and no other action activates
```

### US1.7: Clear on the piece

- **Proves**: IN.deselect, B8

```gherkin
Given shared-play S1 with GS.selectedPiece set
When the actor taps that piece
Then IN.deselect fires and GS.selectedPiece is none and no other action activates
```

### US1.8: Clear on an empty square

- **Proves**: IN.deselect, B9

```gherkin
Given shared-play S1, selection set, empty non-destination
When the actor taps that square
Then IN.deselect fires and GS.selectedPiece is none and no place is asked
```
