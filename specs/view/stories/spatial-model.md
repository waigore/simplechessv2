# Stories: Spatial model

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`spatial-model.md`](../spatial-model.md)
- **Spec key**: `SPC`
- **Glossary terms**: [World unit](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| A1 | VS1.1 | A2 | VS1.2 |
| U1 | VS1.3 | U2 | VS1.4 |
| P1 | VS1.5 | P2 | VS1.6 |
| E1 | VS1.7 | E2 | VS1.8 |
| L1 L2 | VS1.9 | L3 | VS1.10 |
| L4 | VS1.11 | B1 | VS1.12 VS1.13 |

## VS1: Board plane layout

As a casual player, I see pieces on a fixed table plane so that positions read at a glance.

### VS1.1: Axes

- **Proves**: A1

```gherkin
Given CAM-board Web 9:16, White seat Bottom, a piece on a1
When placed
Then center is 0.5 units +x +y from a1's corner, files +x, ranks +y
```

### VS1.2: White-fixed axes

- **Proves**: A2

```gherkin
Given CAM-board Web 9:16, White seat Top or Puzzle Solving side Black, axes White-fixed
When M2 applies
Then the display rotates 180° for either case, names stay White-fixed
```

### VS1.3: World unit

- **Proves**: U1

```gherkin
Given square a1
When measured
Then edge is 1 world unit, board spans 8×8 units
```

### VS1.4: Time base

- **Proves**: U2

```gherkin
Given CAM-board Web 9:16, PHY.M1 travel
When duration measured
Then time is in seconds
```

### VS1.5: Snap placement

- **Proves**: P1

```gherkin
Given CAM-board Web 9:16, a piece on e4
When placement applied
Then body center is (4.5, 3.5), travel presentation only
```

### VS1.6: One piece per square

- **Proves**: P2

```gherkin
Given CAM-board Web 9:16, e4 occupied
When another piece is placed on e4
Then at most one body remains (E-pieces.I1)
```

### VS1.7: Piece extent

- **Proves**: E1

```gherkin
Given CAM-board Web 9:16, a piece on e4
When extent measured
Then body is 0.85×0.85 units about center, facing none
```

### VS1.8: Square extent

- **Proves**: E2

```gherkin
Given CAM-board Web 9:16, square e4
When extent measured
Then square is 1×1 units about its center
```

### VS1.9: Backdrop under board

- **Proves**: L1, L2

```gherkin
Given CAM-board Web 9:16, cafe backdrop under the board
When both drawn
Then L2 draws over L1, parallax 0 and 1
```

### VS1.10: Pieces by depth

- **Proves**: L3

```gherkin
Given CAM-board Web 9:16, two pieces overlapping in frame
When drawn
Then L3 by rank-then-file draws over the farther, parallax 1
```

### VS1.11: Overlays above pieces

- **Proves**: L4

```gherkin
Given CAM-board Web 9:16, selection or Advice overlay on a piece
When drawn
Then L4 draws over L3, parallax 1
```

### VS1.12: Board bounds

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, play board
When extent checked
Then x and y stay in 0–8 inclusive
```

### VS1.13: No off-board rest

- **Proves**: B1

```gherkin
Given CAM-board Web 9:16, a move that would leave 0–8
When presentation runs
Then no piece center rests outside B1; E-pieces legality rejects
```
