# Stories: Controls drag

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`controls.md`](../controls.md)
- **Spec key**: `IN`
- **Glossary terms**: [Binding](../glossary.md)

## Coverage

Part of [`controls.md`](controls.md). The coverage table lives there. This file proves drag bindings B10 and B11.

## US2: Web drag bindings

As an actor on Web, I drag a piece so the matching action fires.

### US2.1: Drag move

- **Proves**: IN.move, B10

```gherkin
Given shared-play S1, own seat to move, piece not selected
When the actor drags that piece onto a legal destination
Then IN.move fires on UI-shared-play.C2 and no other action activates
```

### US2.2: Drag clear

- **Proves**: IN.deselect, B11

```gherkin
Given shared-play S1, own seat to move
When the actor releases a drag of an own piece on an illegal square, empty non-destination, or off the board
Then IN.deselect fires and GS.selectedPiece is none and no place is asked
```
