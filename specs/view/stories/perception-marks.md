# Stories: Perception — marks and coordinates

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`perception.md`](../perception.md)
- **Spec key**: `PER`
- **Glossary terms**: [Board camera](../glossary.md), [Frame](../glossary.md)

Split from [`perception.md`](perception.md) by logical unit; that file proves identity, squares, depth, and comfort.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R3 | VS2.1 | R4 | VS2.2 |
| R5 | VS2.3 | R6 | VS2.4 |
| R7 | VS2.5 VS2.6 | R8 | VS2.7 |

## VS2: Read the marks

As a casual player, I see selection, legal moves, Advice, turn, and coordinates clearly so that I can act without guessing.

### VS2.1: Selection

- **Proves**: R3

```gherkin
Given CAM-board Web 9:16, a selected piece
When shown
Then its square and piece show PAL.C6 at ≥ 2:1 on both square colors (PAL.K5) And ≥ 90% of the body stays visible
```

### VS2.2: Legal destinations

- **Proves**: R4

```gherkin
Given CAM-board Web 9:16, a selection with legal destinations
When shown
Then each target shows PAL.C11 at ≥ 2:1 on both square colors (PAL.K6) And each mark covers ≥ 1/4 square
```

### VS2.3: Advice

- **Proves**: R5

```gherkin
Given CAM-board Web 9:16, Shared Advice On and a best move (F-move-advice)
When advice marks show
Then from/to and arrow show PAL.C7 at ≥ 2:1 on both squares (PAL.K5) And eval text is ≥ UIS.T2 And the marks cover ≤ 10% of any body
```

### VS2.4: Turn and check

- **Proves**: R6

```gherkin
Given CAM-board Web 9:16, side to move White in check, sound off
When viewed
Then the side-to-move and check indicator is ≥ 1/12 frame height, in-frame, at ≥ 4.5:1 (PAL.K4) And check uses PAL.C8
```

### VS2.5: Coordinates, Bottom seat

- **Proves**: R7

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When coordinates show
Then files a–h and ranks 1–8 sit on the outer 1-unit margin only, at ≥ UIS.T2 and ≥ 4.5:1 against the background
```

### VS2.6: Coordinates after flip

- **Proves**: R7

```gherkin
Given CAM-board Web 9:16, White seat Top after CAM-board.M2
When coordinates show
Then file a stays on White's left after the 180° flip And labels stay on the outer margin
```

### VS2.7: Refused place

- **Proves**: R8

```gherkin
Given CAM-board Web 9:16, a selected piece, a refused place
When refusal shows
Then that square flashes PAL.C8 for 0.3 s at ≥ 2:1 (PAL.K5) And selection and legal marks stay
```
