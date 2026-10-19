# Stories: Physics feel

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`physics.md`](../physics.md)
- **Spec key**: `PHY`
- **Glossary terms**: [World unit](../glossary.md)

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| M1 | VS1.1 VS1.2 | M2 | VS1.3 |
| M3 | VS1.4 | M4 | VS1.5 |
| K1 | VS1.6 | I1 | VS1.7 |
| I2 | VS1.3 | I3 | VS1.4 |

## VS1: Snappy place and capture

As a casual player, I see moves finish quickly on the device so that Instant play stays obvious.

### VS1.1: Legal place

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, Shared game, a legal place e2→e4 (E-pieces.I10)
When the move is played
Then the piece travels straight origin→destination in ≤ 0.15 s ease-out And the position updates at travel end with no network wait
```

### VS1.2: Travel ends

- **Proves**: M1

```gherkin
Given CAM-board Web 9:16, elapsed 0.15 s after move start
When sampled
Then the mover is on the destination square center
```

### VS1.3: Capture

- **Proves**: M2, I2

```gherkin
Given CAM-board Web 9:16, a legal capture
When played
Then the captured piece breaks apart and clears during the same ≤ 0.15 s travel And is gone when the mover lands (E-pieces.I3) And fragments fade within M1
```

### VS1.4: Promotion

- **Proves**: M3, I3

```gherkin
Given CAM-board Web 9:16, a legal promotion
When the pawn arrives
Then it morphs into the chosen type within ≤ 0.15 s with no pop-cut And the new type is visible when the move settles (E-pieces.I33)
```

### VS1.5: Castling

- **Proves**: M4

```gherkin
Given CAM-board Web 9:16, legal castling
When played
Then king and rook each use M1 concurrently And both rest on their castling squares together when travel ends (E-pieces.I13)
```

### VS1.6: No blocking shapes

- **Proves**: K1

```gherkin
Given CAM-board Web 9:16, two adjacent pieces
When neither move is in flight
Then K1 holds: no simulated blocking shapes And placement follows SPC.P1
```

### VS1.7: Settle

- **Proves**: I1

```gherkin
Given CAM-board Web 9:16, M1 lands
When settle measured
Then settle lasts ≤ 0.03 s And camera shake is none And selection clears to the new occupancy
```
