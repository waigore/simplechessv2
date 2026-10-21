# Stories: Spatial model

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`spatial-model.md`](../spatial-model.md)
- **Spec key**: `SPC`
- **Glossary terms**: [World unit](../glossary.md)

Layers and bounds: [`spatial-model-layers.md`](spatial-model-layers.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| A1 | VS1.1 | A2 | VS1.2 VS1.3 |
| U1 | VS1.4 | U2 | VS1.5 |
| P1 | VS1.6 | P2 | VS1.7 |
| E1 | VS1.8 | E2 | VS1.9 |
| L1 L2 | VS2.1 VS2.2 | L3 | VS2.3 |
| L4 | VS2.4 | B1 | VS2.5 VS2.6 VS2.7 VS2.8 |

## VS1: Board plane layout

As a casual player, I see pieces on a fixed table plane so that positions read at a glance.

### VS1.1: Axes

- **Proves**: A1

```gherkin
Given CAM-board Web 9:16, White seat Bottom, piece on a1 at (0.5, 0.5)
When placed
Then center is 0.5 (±0.01) units +x +y from a1's outer corner, files +x, ranks +y
```

### VS1.2: White-fixed after seat rotation

- **Proves**: A2

```gherkin
Given CAM-board Web 9:16, White seat Top, axes White-fixed, piece on a1 at (0.5, 0.5)
When CAM-board.M2 applies
Then display rotates 180° And a1 center stays (0.5, 0.5) (±0.01) in White-fixed units
```

### VS1.3: White-fixed after puzzle rotation

- **Proves**: A2

```gherkin
Given CAM-board Web 9:16, Puzzle Solving side Black, axes White-fixed, piece on h8 at (7.5, 7.5)
When CAM-board.M2 applies
Then display rotates 180° And h8 center stays (7.5, 7.5) (±0.01) in White-fixed units
```

### VS1.4: World unit

- **Proves**: U1

```gherkin
Given CAM-board Web 9:16, square a1 from (0, 0) to (1, 1)
When measured
Then edge is 1.0 (±0.01) world unit And board spans 8.0 (±0.01)×8.0 (±0.01) units
```

### VS1.5: Time base

- **Proves**: U2

```gherkin
Given CAM-board Web 9:16, PHY.M1 travel
When duration measured
Then time is in seconds (±0)
```

### VS1.6: Snap placement

- **Proves**: P1

```gherkin
Given CAM-board Web 9:16, a piece on e4
When placement applied
Then body center is (4.5, 3.5) (±0.01), travel presentation only
```

### VS1.7: One drawn body per square

- **Proves**: P2

```gherkin
Given CAM-board Web 9:16, e4 occupied at (4.5, 3.5), another piece placed on e4 (E-pieces.I1)
When drawn
Then exactly one body center is at (4.5, 3.5) (±0.01)
```

### VS1.8: Piece extent

- **Proves**: E1

```gherkin
Given CAM-board Web 9:16, a piece on e4 at (4.5, 3.5)
When extent measured
Then body is 0.85 (±0.01)×0.85 (±0.01) units about center, facing None
```

### VS1.9: Square extent

- **Proves**: E2

```gherkin
Given CAM-board Web 9:16, square e4 center (4.5, 3.5)
When extent measured
Then square is 1.0 (±0.01)×1.0 (±0.01) units about its center, facing None
```
