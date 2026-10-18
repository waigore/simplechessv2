# Stories: Two-player game

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/two-player-game.md`](../../loops/two-player-game.md)
- **Spec key**: `L-two-player-game`
- **Glossary terms**: [Shared game](../../glossary.md), [Side to move](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| K1 | Game setup | PS1.1 PS1.2 PS1.3 |
| K2 | Move and clock response | PS1.4 PS1.5 PS1.6 |
| K3 | After a result | PS1.7 PS1.8 |
| E1 | Checkmate exit | PS1.9 |
| E2 | Resign exit | PS1.10 |
| E3 | Draw exit | PS1.11 |
| E4 | Clock expiry exit | PS1.12 PS1.13 |
| CFG.BLITZ_START | Blitz start seconds | PS1.2 |
| CFG.RAPID_START | Rapid start seconds | PS1.3 |

## PS1: Play a Shared game

As a casual player, I play a friend on one device so that a game reaches a clear result.

### PS1.1: Untimed start

- **Proves**: K1

```gherkin
Given White seat Bottom player And Clock Untimed
When K1 completes
Then GS.position is the orthodox opening And GS.sideToMove White And both clocks none
```

### PS1.2: Blitz start

- **Proves**: K1, CFG.BLITZ_START

```gherkin
Given Clock Blitz And Increment 3 s
When K1 completes
Then both clocks are CFG.BLITZ_START (60) And only White's clock runs
```

### PS1.3: Rapid start

- **Proves**: K1, CFG.RAPID_START

```gherkin
Given Clock Rapid
When K1 completes
Then both clocks are CFG.RAPID_START (600) And only White's clock runs
```

### PS1.4: Legal move

- **Proves**: K2

```gherkin
Given Untimed, GS.sideToMove White
When White completes a legal move
Then GS.position is updated And GS.sideToMove is Black
```

### PS1.5: Illegal attempt refused

- **Proves**: K2

```gherkin
Given Blitz, White's clock running
When White attempts an illegal move
Then GS.position unchanged, GS.sideToMove White, White's clock running
```

### PS1.6: Move adds increment

- **Proves**: K2

```gherkin
Given Blitz And Increment 3 s And GS.whiteClock is 50
When White completes a legal move
Then GS.whiteClock stops at 53 And Black's starts
```

### PS1.7: Play another

- **Proves**: K3

```gherkin
Given GS.gameEnded is true
When players begin another
Then K1 runs again
```

### PS1.8: Stop after result

- **Proves**: K3

```gherkin
Given GS.gameEnded is true
When players stop
Then phase is FL-mode-pick.P1
```

### PS1.9: Checkmate exit

- **Proves**: E1

```gherkin
Given the side to move is in check with no legal move
When endings apply
Then both clocks stop And GS.gameEnded true
```

### PS1.10: Resign exit

- **Proves**: E2

```gherkin
Given an open game
When White resigns
Then White loses And GS.gameEnded true
```

### PS1.11: Draw exit

- **Proves**: E3

```gherkin
Given END.D1 holds
When endings apply
Then a draw And GS.gameEnded true
```

### PS1.12: Expiry loses

- **Proves**: E4

```gherkin
Given Blitz, GS.whiteClock 0, Black can checkmate
When White's clock expires
Then White loses, no seconds added, GS.gameEnded true
```

### PS1.13: Expiry draws

- **Proves**: E4

```gherkin
Given Blitz, GS.whiteClock 0, Black cannot checkmate
When White's clock expires
Then a draw And GS.gameEnded true
```
