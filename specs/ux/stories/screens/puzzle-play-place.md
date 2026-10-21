# Stories: Puzzle play place

Authoring rules: [`.agents/specs/rules/ux/story.md`](../../../../.agents/specs/rules/ux/story.md).

- **UX spec**: [`screens/puzzle-play.md`](../../screens/puzzle-play.md)
- **Spec key**: `UI-puzzle-play`
- **Glossary terms**: [Board coordinates](../../glossary.md)

## Coverage

Part of [`puzzle-play.md`](puzzle-play.md). The coverage table lives there. This file proves C2 result branches and the S4/S5 enter cases those branches open.

## US3: Place results (continued)

As Bottom player, I place so that each C2 result branch is visible.

### US3.4: Promotion shown

- **Proves**: C2, S4

```gherkin
Given puzzle-play S1 and a legal pawn place is on the last rank
When Bottom activates C2 on that square
Then S4 shows queen, rook, bishop, and knight sprites and C6 is usable
```

### US3.3: Refused place

- **Proves**: C2, S5

```gherkin
Given puzzle-play S1 with a selection and a place the piece rules refuse
When Bottom activates C2 on that square
Then S5 flashes that square, GS.selectedPiece stays set, and C1–C5 are available
```

### US3.16: Pick-and-drag place

- **Proves**: C2

```gherkin
Given puzzle-play S1 and GS.selectedPiece is none
When Bottom activates C2 by pick-and-drag onto a legal square
Then the interface asks the puzzle loop to handle that move
```
