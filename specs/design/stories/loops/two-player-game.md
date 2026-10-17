# Stories: Two-player game

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`loops/two-player-game.md`](../../loops/two-player-game.md)
- **Spec key**: `L-two-player-game`
- **Glossary terms**: [Shared game](../../glossary.md), [Side to move](../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| K1 | PS1.1 PS1.2 | K2 | PS1.3 PS1.4 PS1.5 |
| K3 | PS1.6 PS1.7 | E1 | PS1.8 |
| E2 | PS1.9 | E3 | PS1.10 |
| E4 | PS1.11 PS1.12 | | |

## PS1: Play a Shared game

As a casual player, I play a friend on one device so that a game reaches a clear result.

### PS1.1–PS1.2: Start

- **Proves**: K1

```gherkin
Given White seat Bottom Clock Untimed When K1 done Then orthodox opening sideToMove White And both clocks none
Given Clock Blitz Increment 3 s When K1 done Then both clocks CFG.BLITZ_START (60) And only White's runs
```

### PS1.3–PS1.5: Moves

- **Proves**: K2

```gherkin
Given Untimed sideToMove White When White completes legal move Then position updated And sideToMove Black
Given Blitz White clock running When illegal attempt Then position unchanged sideToMove White clock keeps running
Given Blitz Increment 3 s whiteClock 50 When White completes legal move Then White stops at 53 And Black's clock starts
```

### PS1.6–PS1.12: After result and exits

- **Proves**: K3, E1, E2, E3, E4

```gherkin
Given gameEnded true When begin another Then K1 runs; when stop Then FL-mode-pick.P1
Given in check no legal move When endings Then E1 both clocks stopped gameEnded true
Given open game When White resigns Then E2 gameEnded true
Given END.D1 When endings Then E3 gameEnded true
Given Blitz whiteClock 0 Black can mate When expiry Then White loses no seconds added gameEnded true
Given Blitz whiteClock 0 Black cannot mate When expiry Then draw gameEnded true
```
