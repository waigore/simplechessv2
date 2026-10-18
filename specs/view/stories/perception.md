# Stories: Perception

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`perception.md`](../perception.md)
- **Spec key**: `PER`
- **Glossary terms**: [Board camera](../glossary.md), [Frame](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| R1 | VS1.1 | R2 | VS1.2 VS1.3 |
| R3 | VS1.4 | R4 | VS1.5 |
| R5 | VS1.6 | R6 | VS1.7 |
| R7 | VS1.8 VS1.9 | D1 | VS1.10 |
| M1 | VS1.11 | | |

## VS1: Glanceable board

As a casual player, I read piece type, turn, and marks at a glance so that Clear board holds on touch.

### VS1.1–VS1.5: Identity, squares, selection

- **Proves**: R1, R2, R3, R4

```gherkin
Given CAM-board And each piece type on the board When viewed inside PRJ.A2 Then each type is recognizable by shape alone And overlays do not hide silhouette identity
Given CAM-board Web, any PRJ.A1 aspect And White seat Bottom When light and dark squares are compared with hue removed Then alternation stays distinguishable per palette K1: relative luminance difference ≥ 0.25
Given CAM-board Web, any PRJ.A1 aspect And White seat Top after CAM-board.M2 When light and dark squares are compared with hue removed Then alternation stays distinguishable after the flip per palette K1: relative luminance difference ≥ 0.25
Given CAM-board Web, any PRJ.A1 aspect And a selected piece When shown Then its occupied square and piece are both highlighted
Given CAM-board Web, any PRJ.A1 aspect And a selection with legal destinations When shown Then empty and capture targets for that selection are marked on those squares
```

### VS1.6–VS1.11: Advice, turn, coords, N/A

- **Proves**: R5, R6, R7, D1, M1

```gherkin
Given CAM-board Web, any PRJ.A1 aspect And Shared Advice On And best-move set (F-move-advice) When advice marks show Then from/to highlights arrow and eval are visible And R1 silhouettes stay unobscured
Given CAM-board Web, any PRJ.A1 aspect And side to move White in check When the board is viewed with sound off Then a non-audio indicator of side to move and of check is inside the frame And both stay inside the frame while the position is shown
Given CAM-board Web, any PRJ.A1 aspect And White seat Bottom When coordinates shown Then files a–h and ranks 1–8 lie on outer edges only And never inside squares
Given CAM-board Web, any PRJ.A1 aspect And White seat Top after CAM-board.M2 When coordinates shown Then letters and numbers stay correct for the White-fixed board
Given CAM-board Web, any PRJ.A1 aspect And a flat board When depth cues checked Then D1 holds: no depth bands
Given fixed CAM-board Web, any PRJ.A1 aspect When comfort options checked Then M1 is N/A And no shake or bob comfort toggle is required
```
