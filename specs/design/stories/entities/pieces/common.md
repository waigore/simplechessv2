# Stories: Piece common rules

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces/common.md`](../../../entities/pieces/common.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../../glossary.md), [Side to move](../../../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| I1 | PS1.1 | I2 | PS1.2 |
| I35 | PS1.3 | I3 | PS1.4 |
| I4 | PS1.5 PS1.6 | I5 | PS1.7 PS1.8 |
| I6 | PS1.9 | I7 | PS1.10 |
| I8 | PS1.11 | I9 | PS1.12 |
| I10 | PS1.13 PS1.14 | I11 | PS1.15 |

## PS1: Board, capture, check, legality

As a casual player, I make only legal moves so that check and capture stay orthodox.

### PS1.1–PS1.3: Board

- **Proves**: I1, I2, I35

```gherkin
Given any mode When board observed Then 8×8 a–h/1–8 And ≤1 piece per square
Given White pawn e2 When forward step Then +rank toward Black
Given board When colors Then a1 dark And orthogonal neighbors differ
```

### PS1.4–PS1.6: Capture

- **Proves**: I3, I4

```gherkin
Given White knight can take Black pawn d5 When capture Then Black pawn removed same move
Given e4 holds White When another White moves onto e4 Then illegal position unchanged
Given a king-capture would be next When legality applied Then end condition first And king never S2
```

### PS1.7–PS1.11: Attack and check

- **Proves**: I5, I6, I7, I8

```gherkin
Given White pawn e4 When attacks listed Then d5 f5 yes e5 no
Given White rook a1 piece a3 empty a2 When attacks Then a2 a3 yes a4 no
Given pinned White rook When attack tested Then still attacks; knights jump; king attacks every adjacent
Given White to move e1 attacked When check Then White in check
Given pinned move would leave king in check When attempted Then illegal
```

### PS1.12–PS1.15: Legality

- **Proves**: I9, I10, I11

```gherkin
Given White to move When move matches piece rules (incl. castle/EP/promo) Then pseudo-legal before self-check filter
Given pseudo-legal after which White king not in check When legality Then legal
Given pseudo-legal after which White king in check When legality Then illegal
Given sideToMove White When Black moves Then position unchanged
```
