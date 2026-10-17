# Stories: End conditions

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`end-conditions.md`](../end-conditions.md)
- **Spec key**: `END`
- **Glossary terms**: [Shared game](../glossary.md), [Puzzle](../glossary.md), [Wrong move](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| L1 | PS1.1 | L2 | PS1.2 |
| L3 | PS1.3 | D1 | PS1.4 |
| D2 | PS1.5 PS1.6 | D3 | PS1.7 |
| D4 | PS1.8 | D5 | PS1.9 |
| W1 | PS1.10 | L4 | PS1.11 |
| L5 | PS1.12 | P1 | PS1.13 |

## PS1: Reach a result

As a casual player, I finish a game or puzzle so that the outcome matches the rules.

### PS1.1–PS1.3: Shared losses

- **Proves**: L1, L2, L3

```gherkin
Given side to move in check with no legal move When checked after a move Then mover loses And gameEnded true
Given open Shared When side to move resigns Then that side loses And gameEnded true
Given timed And White clock 0 And Black can checkmate When expiry Then White loses And no seconds added
```

### PS1.4–PS1.9: Draws

- **Proves**: D1, D2, D3, D4, D5

```gherkin
Given not in check and no legal move When checked Then draw
Given White offers draw When Black accepts Then draw; when Black declines Then continues same side to move clock running
Given same position/side/rights third time When checked after move Then draw
Given fifty moves each side no capture/pawn move When checked Then draw
Given timed White clock 0 And Black cannot checkmate When expiry Then draw And no seconds added
```

### PS1.10–PS1.13: Puzzle and precedence

- **Proves**: W1, L4, L5, P1

```gherkin
Given wrongMove false And sequence completed When done Then solved And next harder per DIF.Y1
Given wrongMove true And sequence later completed When done Then failed And next easier
Given open puzzle When reveal Then failed And next easier
Given in check with no legal move When checked Then L1 applies And D1 does not
```
