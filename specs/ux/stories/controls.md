# Stories: Controls

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls.md`](../controls.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| IN.confirm | Confirm binding | US1.1 |
| IN.cancel | Cancel binding | US1.2 |
| IN.back | Back binding | US1.3 |
| IN.point | Focus order | US1.4 |
| IN.activate | Tap activate | US1.5 |
| IN.select | Tap select | US1.6 |
| IN.move | Tap move | US1.7 |
| IN.deselect | Tap clear | US1.8 US1.9 |
| B1 | Tap → activate | US1.5 |
| B2 | Tap → select | US1.6 |
| B3 | Tap → move | US1.7 |
| B4 | Confirm tap | US1.1 |
| B5 | Cancel tap | US1.2 |
| B6 | Back tap | US1.3 |
| B7 | Pointer/focus → point | US1.4 |
| B8 | Tap selected piece → clear | US1.8 |
| B9 | Tap empty non-destination → clear | US1.9 |
| F1 | Focus order | US1.4 |

## US1: Web touch bindings

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

### US1.4: Focus order

- **Proves**: IN.point, B7, F1

```gherkin
Given mode-pick S1
When the actor moves the pointer over, or moves focus to, a control
Then focus order follows C1 then C2 then C3 then C4
```

### US1.5: Activate

- **Proves**: IN.activate, B1

```gherkin
Given mode-pick S1 on Web
When the actor taps Shared game
Then IN.activate fires on UI-mode-pick.C1 and no other action activates
```

### US1.6: Select

- **Proves**: IN.select, B2

```gherkin
Given shared-play S1, own seat to move, piece not selected
When the actor taps their piece
Then IN.select fires on UI-shared-play.C1 and no other action activates
```

### US1.7: Move

- **Proves**: IN.move, B3

```gherkin
Given shared-play S1 with a selection
When the actor taps a legal destination square
Then IN.move fires on UI-shared-play.C2 and no other action activates
```

### US1.8: Clear on the piece

- **Proves**: IN.deselect, B8

```gherkin
Given shared-play S1 with GS.selectedPiece set
When the actor taps that piece
Then IN.deselect fires and GS.selectedPiece is none and no other action activates
```

### US1.9: Clear on an empty square

- **Proves**: IN.deselect, B9

```gherkin
Given shared-play S1, selection set, empty non-destination
When the actor taps that square
Then IN.deselect fires and GS.selectedPiece is none and no place is asked
```

