# Stories: Shared play place

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/shared-play.md`](../../screens/shared-play.md)
- **Spec key**: `UI-shared-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`shared-play.md`](shared-play.md). The coverage table lives there. This file proves C2 result branches and the S4/S5 enter cases those branches open.

## US3: Place results (continued)

As the side-to-move actor, I place so that each C2 result branch is visible.

### US3.13: Promotion shown

- **Proves**: C2, S4

```gherkin
Given shared-play S1 and a legal pawn place is on the last rank
When the side to move activates C2 on that square
Then S4 shows queen, rook, bishop, and knight sprites and C6 is usable And C3–C5 are available
```

### US3.11: Refused place

- **Proves**: C2, S5

```gherkin
Given shared-play S1 with a selection and a place the piece rules refuse
When the side to move activates C2 on that square
Then S5 flashes that square and GS.selectedPiece stays set and C1–C5 are available
```

### US3.14: Move lapses the offer

- **Proves**: C2, S6

```gherkin
Given shared-play S6 and a piece is selected
When the side to move activates C2 on a legal destination
Then the screen is shared-play S1 and no draw offer panel is shown and GS.selectedPiece is cleared
```

### US3.16: Pick-and-drag place

- **Proves**: C2

```gherkin
Given Bottom seat is side to move and GS.selectedPiece is none
When Bottom activates C2 by pick-and-drag onto a legal square
Then the interface asks for that place
```
