# Stories: Board camera

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../../.agents/specs/rules/view/story.md).

- **View spec**: [`cameras/board.md`](../../cameras/board.md)
- **Spec key**: `CAM-board`
- **Glossary terms**: [Board camera](../../glossary.md), [Seat flip](../../glossary.md), [Frame](../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| F1 F2 | VS1.1 | F3 F4 F5 | VS1.2 |
| M1 | VS1.3 | M2 | VS1.4 VS1.5 |
| L1 L2 | VS1.6 | O1 | VS1.7 |
| T1 | VS1.8 VS1.9 | E1 | VS1.10 |
| P1 | VS1.11 | | |

## VS1: Fixed table view

As a casual player, I look straight down at a fixed board so that White’s near edge faces the White seat without panning.

### VS1.1–VS1.3: Framing and follow

- **Proves**: F1, F2, F3, F4, F5, M1

```gherkin
Given Shared game play Web phone-width And White seat Bottom When CAM-board is active Then target is board center (4, 4) And frame center matches And board fills per PRJ.V1
Given CAM-board active When framing checked Then offset is none And dead zone is none And lookahead is none
Given a piece travels under PHY.M1 When travel runs Then camera world position and zoom stay unchanged
```

### VS1.4–VS1.7: Seat flip, limits, occlusion

- **Proves**: M2, L1, L2, O1

```gherkin
Given CAM-board Web, any PRJ.A1 aspect And White seat Bottom When play opens Then framed board rotation about F1 is 0° And White near edge faces Bottom
Given CAM-board Web, any PRJ.A1 aspect And White seat Top When play opens Then framed board rotates 180° about F1 And White near edge faces Top
Given CAM-board Web, any PRJ.A1 aspect When pan or zoom attempted Then camera stays on SPC.B1 And visible height stays PRJ.P1
Given CAM-board Web, any PRJ.A1 aspect And open table When board viewed Then O1 holds: no scenery between camera and board
```

### VS1.8–VS1.11: Transition, effects, control

- **Proves**: T1, E1, P1

```gherkin
Given mode pick Web, any PRJ.A1 aspect And CAM-board as the target camera When Shared or Puzzle play starts (FL-mode-pick) Then CAM-board is in use within 0 s cut And nothing carries over
Given CAM-board Web, any PRJ.A1 aspect And Shared or Puzzle play When returning to mode pick Then CAM-board leaves by 0 s cut
Given CAM-board Web, any PRJ.A1 aspect And any play event When E1 checked Then no shake or zoom punch runs
Given CAM-board Web, any PRJ.A1 aspect When any camera action is attempted Then position angle and zoom are unchanged (CC has no actions)
```
