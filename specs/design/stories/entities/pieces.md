# Stories: Pieces

Authoring rules: [`.agents/specs/rules/design/story.md`](../../../../.agents/specs/rules/design/story.md).

- **Design spec**: [`entities/pieces.md`](../../entities/pieces.md)
- **Spec key**: `E-pieces`
- **Glossary terms**: [Piece](../../glossary.md)

## Coverage

| Element | Summary | Scenarios |
|---------|---------|-----------|
| P1 | Color | PS1.1 |
| P2 | Type | PS1.1 |
| P3 | Origin square | PS1.1 |
| P4 | Has moved | PS1.2 PS1.3 PS1.4 |
| S1 | On board | PS1.1 |
| S2 | Captured | PS1.5 |
| S3 | Promoting | PS1.6 |
| Placement | Orthodox start | PS1.7 |

## PS1: Piece identity and lifecycle

As a casual player, I rely on piece color, type, and state so that moves stay legal.

### PS1.1: On-board properties

- **Proves**: P1, P2, P3, S1

```gherkin
Given Shared game at the orthodox opening
When L-two-player-game.K1 completes
Then White's piece on e2 has Color White And Type Pawn And Origin square e2 And state S1
```

### PS1.2: Has moved false at start

- **Proves**: P4

```gherkin
Given Shared game start
When L-two-player-game.K1 completes
Then White's king on e1 has P4 false
```

### PS1.3: P4 true blocks castling

- **Proves**: P4

```gherkin
Given White king has P4 true And otherwise kingside castling looks clear
When White attempts kingside castling
Then the move is illegal
```

### PS1.4: P4 true blocks two-square pawn step

- **Proves**: P4

```gherkin
Given White pawn on e3 with P4 true And e4 empty
When White attempts e3→e5
Then the move is illegal
```

### PS1.5: Capture → S2

- **Proves**: S2

```gherkin
Given a Black pawn on d5 And a White piece captures on d5
When the capture completes
Then the Black pawn is in S2 And out of play
```

### PS1.6: Promoting state

- **Proves**: S3

```gherkin
Given a White pawn on e7 And e8 empty
When the player moves the pawn e7→e8
Then the pawn is in S3 (promotion required) until replaced by Q, R, B, or N of White And then S1 as that type
```

### PS1.7: Orthodox placement

- **Proves**: Placement

```gherkin
Given the Shared game begins
When L-two-player-game.K1 completes
Then White occupies ranks 1–2 And Black 7–8 And back ranks are R N B Q K B N R And pawns fill the rank in front
```
