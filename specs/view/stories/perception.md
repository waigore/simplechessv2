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
| R7 | VS1.8 VS1.9 | R8 | VS1.12 |
| D1 | VS1.10 | M1 | VS1.11 |

## VS1: Glanceable board

As a casual player, I read piece type, turn, and marks at a glance so that Clear board holds on touch.

### VS1.1: Identity

- **Proves**: R1

```gherkin
Given CAM-board Web 9:16, a piece of each type
When viewed in PRJ.A2
Then each type reads by shape alone And overlays do not hide silhouettes
```

### VS1.2: Squares, Bottom seat

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When light and dark squares are compared with hue removed
Then alternation stays distinct (K1: luminance Δ ≥ 0.25)
```

### VS1.3: Squares after flip

- **Proves**: R2

```gherkin
Given CAM-board Web 9:16, White seat Top after CAM-board.M2
When light and dark squares are compared with hue removed
Then alternation stays distinct (K1: luminance Δ ≥ 0.25)
```

### VS1.4: Selection

- **Proves**: R3

```gherkin
Given CAM-board Web 9:16, a selected piece
When shown
Then its square and piece are highlighted
```

### VS1.5: Legal destinations

- **Proves**: R4

```gherkin
Given CAM-board Web 9:16, a selection with legal destinations
When shown
Then those squares mark empty and capture targets
```

### VS1.6: Advice

- **Proves**: R5

```gherkin
Given CAM-board Web 9:16, Shared Advice On and a best move (F-move-advice)
When advice marks show
Then highlights, arrow, and eval show And R1 silhouettes stay unobscured
```

### VS1.7: Turn and check

- **Proves**: R6

```gherkin
Given CAM-board Web 9:16, side to move White in check, sound off
When viewed
Then a non-audio side-to-move and check indicator is in-frame And stays there
```

### VS1.8: Coordinates, Bottom seat

- **Proves**: R7

```gherkin
Given CAM-board Web 9:16, White seat Bottom
When coordinates show
Then files a–h and ranks 1–8 lie on outer edges only, never inside squares
```

### VS1.9: Coordinates after flip

- **Proves**: R7

```gherkin
Given CAM-board Web 9:16, White seat Top after CAM-board.M2
When coordinates show
Then letters and numbers stay correct after the flip
```

### VS1.10: Depth

- **Proves**: D1

```gherkin
Given CAM-board Web 9:16, a flat board
When depth cues checked
Then D1 holds: no depth bands
```

### VS1.11: Comfort

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, no camera motion over time
When comfort options are checked
Then M1 is N/A And no shake or bob toggle is needed
```

### VS1.12: Refused place

- **Proves**: R8

```gherkin
Given CAM-board Web, PRJ.A1, a selected piece, a refused place
When refusal shows
Then that square flashes PAL.C8 And selection and legal marks stay
```
