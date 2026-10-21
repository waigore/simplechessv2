# Stories: Board camera limits

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../../.agents/specs/rules/view/story.md).

- **View spec**: [`cameras/board.md`](../../cameras/board.md)
- **Spec key**: `CAM-board`
- **Glossary terms**: [Board camera](../../glossary.md), [Frame](../../glossary.md)

Split from [`board.md`](board.md); that file proves framing, motion, effects, and control.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| L1 | VS2.1 VS2.2 VS2.3 | L2 | VS2.4 VS2.5 VS2.6 |
| O1 | VS2.7 | T1 | VS2.8 VS2.9 VS2.10 VS2.11 VS2.12 |

## VS2: Fixed bounds and cuts

As a casual player, I keep a fixed framed board so pan and zoom never drift the table.

### VS2.1: Bounds at SPC.B1

- **Proves**: L1

```gherkin
Given CAM-board Web 9:16
When framing checked
Then camera stays on SPC.B1 (x and y in 0–8 inclusive)
```

### VS2.2: Pan past +x

- **Proves**: L1

```gherkin
Given CAM-board Web 9:16, camera on SPC.B1
When pan past +x of SPC.B1 is attempted
Then camera stays on SPC.B1 at the +x limit
```

### VS2.3: Pan past −x

- **Proves**: L1

```gherkin
Given CAM-board Web 9:16, camera on SPC.B1
When pan past −x of SPC.B1 is attempted
Then camera stays on SPC.B1 at the −x limit
```

### VS2.4: Zoom at PRJ.P1

- **Proves**: L2

```gherkin
Given CAM-board Web 9:16
When framing checked
Then short-axis extent is PRJ.P1 (10 units ±0)
```

### VS2.5: Zoom in attempted

- **Proves**: L2

```gherkin
Given CAM-board Web 9:16, short-axis extent PRJ.P1 (10 units)
When zoom toward 9 units is attempted
Then short-axis extent stays 10 units ±0
```

### VS2.6: Zoom out attempted

- **Proves**: L2

```gherkin
Given CAM-board Web 9:16, short-axis extent PRJ.P1 (10 units)
When zoom toward 11 units is attempted
Then short-axis extent stays 10 units ±0
```

### VS2.7: Open table, no blocker

- **Proves**: O1

```gherkin
Given CAM-board Web 9:16, open table (O1 N/A — no scenery blocker)
When board viewed
Then O1 holds: no scenery between camera and board
```

### VS2.8: Enter Shared via T1

- **Proves**: T1

```gherkin
Given mode pick Web 9:16, CAM-board as the target camera
When FL-mode-pick.T1 fires
Then CAM-board is in use within cut 0 s And nothing carries And pose within 0°
```

### VS2.9: Enter Puzzle via T2

- **Proves**: T1

```gherkin
Given mode pick Web 9:16, CAM-board as the target camera
When FL-mode-pick.T2 fires
Then CAM-board is in use within cut 0 s And nothing carries And pose within 0°
```

### VS2.10: Leave Shared via T3

- **Proves**: T1

```gherkin
Given CAM-board Web 9:16, Shared play
When FL-mode-pick.T3 fires
Then CAM-board leaves by cut 0 s And nothing carries
```

### VS2.11: Leave Puzzle via T4

- **Proves**: T1

```gherkin
Given CAM-board Web 9:16, Puzzle play
When FL-mode-pick.T4 fires
Then CAM-board leaves by cut 0 s And nothing carries
```

### VS2.12: Mode-pick transitions do not fire

- **Proves**: T1

```gherkin
Given CAM-board Web 9:16, Shared play, no FL-mode-pick.T1–T4 pending
When 1 s elapses
Then CAM-board stays in use And pose is unchanged within 0°
```
