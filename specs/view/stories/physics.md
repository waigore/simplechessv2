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

### VS1.1–VS1.5: Motion profiles

- **Proves**: M1, M2, M3, M4, I2, I3

```gherkin
Given Web Shared game And a legal place from e2 to e4 (E-pieces.I10) When the move is played Then the piece travels straight on the board plane origin→destination in ≤ 0.15 s ease-out And the position updates when travel ends with no network wait
Given CAM-board Web, any PRJ.A1 aspect And elapsed 0.15 s after move start When sampled Then the mover is on the destination square center
Given CAM-board Web, any PRJ.A1 aspect And a legal capture When played Then the captured piece breaks apart and clears during the same ≤ 0.15 s M1 travel And is gone when the mover lands (E-pieces.I3) And break fragments fade within M1 (I2)
Given CAM-board Web, any PRJ.A1 aspect And a legal promotion When the pawn arrives Then it morphs into the chosen type within ≤ 0.15 s continuous with no pop-cut (I3) And the new type is visible when the move settles (E-pieces.I33)
Given CAM-board Web, any PRJ.A1 aspect And legal castling When played Then king and rook each use M1 concurrently And both rest on their castling squares together when travel ends (E-pieces.I13)
```

### VS1.6–VS1.7: Collision and contact

- **Proves**: K1, I1

```gherkin
Given CAM-board Web, any PRJ.A1 aspect And two adjacent pieces When neither move is in flight Then K1 holds: no simulated blocking shapes And placement follows SPC.P1
Given CAM-board Web, any PRJ.A1 aspect And M1 lands When settle measured Then settle lasts ≤ 0.03 s And camera shake is none And selection clears to the new occupancy
```
