# Stories: Physics feel

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`physics.md`](../physics.md)
- **Spec key**: `PHY`
- **Glossary terms**: [World unit](../glossary.md)

Drag M5: [`physics-drag.md`](physics-drag.md). Collision and settle: [`physics-contact.md`](physics-contact.md).

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| M1 | VS1.1 VS1.2 VS1.3 | M2 | VS1.4 VS1.5 |
| M3 | VS1.6 VS1.7 | M4 | VS1.8 VS1.9 |
| I2 | VS1.4 | I3 | VS1.6 VS1.7 |

## VS1: Snappy place and capture

As a casual player, I see moves finish quickly on the device so that Instant play stays obvious.

### VS1.1: Legal place starts

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, Shared game, legal place e2→e4 (E-pieces.I10)
When the move is played
Then travel starts at acceptance, straight origin→destination, ease-out And design move completion (L-two-player-game.K2) is not delayed to travel end, with no network wait
```

### VS1.2: Mid travel

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, legal place e2→e4 started, elapsed 0.07 s
When sampled
Then the mover body center is between e2 and e4 centers And not on the e4 center
```

### VS1.3: Travel bound

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, legal place e2→e4 started
When sampled at elapsed 0.15 s
Then the mover is on the e4 square center
And at elapsed 0.16 s the mover remains on the e4 square center
```

### VS1.4: Capture

- **Proves**: M2, I2

```gherkin
Given CAM-board Web 9:16, a legal capture
When played
Then the captured piece breaks apart and clears during the same ≤ 0.15 s travel And is gone when the mover lands (E-pieces.I3) And fragments fade within M1
```

### VS1.5: Capture times

- **Proves**: M2

```gherkin
Given CAM-board Web 9:16, a legal capture started
When sampled at elapsed 0.07 s
Then capture fragments are still visible
And at elapsed 0.15 s the captured piece is gone And at 0.16 s it remains gone
```

### VS1.6: Promotion mid morph

- **Proves**: M3, I3

```gherkin
Given CAM-board Web 9:16, legal promotion to queen, morph started, elapsed 0.07 s
When sampled
Then the body is a partial morph: neither full pawn nor full queen silhouette
```

### VS1.7: Promotion bound

- **Proves**: M3, I3

```gherkin
Given CAM-board Web 9:16, legal promotion to queen, morph started
When sampled at elapsed 0.15 s
Then the queen type is visible (E-pieces.I33) via continuous morph (no pop-cut)
And at elapsed 0.16 s the queen type remains
```

### VS1.8: Castling mid

- **Proves**: M4

```gherkin
Given CAM-board Web 9:16, legal castling started, elapsed 0.07 s
When sampled
Then king and rook body centers are each between their start and castling square centers
```

### VS1.9: Castling bound

- **Proves**: M4

```gherkin
Given CAM-board Web 9:16, legal castling started
When sampled at elapsed 0.15 s
Then king and rook rest on their castling squares together (E-pieces.I13)
And at elapsed 0.16 s both remain there
```
