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

As a casual player, I see pieces on a fixed 8×8 table plane so that positions stay readable at a glance.

### VS1.1–VS1.4: Frame and units

- **Proves**: A1, A2, U1, U2

```gherkin
Given CAM-board Web phone-width And White seat Bottom When a piece occupies a1 Then its center is 0.5 units +x and +y from the a1 outer corner And h-file is +x And rank 8 is +y
Given White seat Top And axes White-fixed When Top is White Then CAM-board.M2 rotates display 180° And A1 axis names stay White-fixed
Given square a1 When measured Then edge length is 1 world unit And the board spans 8×8 units
Given PHY.M1 travel When duration measured Then time is in seconds
```

### VS1.5–VS1.8: Placement and extents

- **Proves**: P1, P2, E1, E2

```gherkin
Given CAM-board Web, any PRJ.A1 aspect And a piece on e4 When placement applied Then the body center is at square-center (4.5, 3.5) And travel to that square is presentation only
Given CAM-board Web, any PRJ.A1 aspect And e4 occupied When another piece is placed on e4 Then at most one body remains (E-pieces.I1)
Given CAM-board Web, any PRJ.A1 aspect And a piece on e4 When extent measured Then body is 0.85×0.85 units about square center And facing is none
Given CAM-board Web, any PRJ.A1 aspect And square e4 When extent measured Then square is 1×1 units about its center
```

### VS1.9–VS1.13: Render layers and bounds

- **Proves**: L1, L2, L3, L4, B1

```gherkin
Given CAM-board Web, any PRJ.A1 aspect And cafe backdrop under the board When both drawn Then render layer L2 draws over render layer L1 And L1 L2 parallax factors are 0 and 1
Given CAM-board Web, any PRJ.A1 aspect And two pieces whose bodies overlap in frame When drawn Then render layer L3 nearer by rank-then-file draws over the farther And parallax is 1
Given CAM-board Web, any PRJ.A1 aspect And selection or Advice overlay on a piece When drawn Then render layer L4 draws over render layer L3 And parallax is 1
Given CAM-board Web, any PRJ.A1 aspect And play board When extent checked Then x and y stay in 0–8 inclusive
Given CAM-board Web, any PRJ.A1 aspect And a move that would leave 0–8 When presentation runs Then no piece center rests outside B1 And E-pieces legality owns the reject
```
