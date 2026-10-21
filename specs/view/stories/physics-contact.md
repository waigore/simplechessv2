# Stories: Physics contact

Authoring rules: [`.agents/specs/rules/view/story.md`](../../../.agents/specs/rules/view/story.md).

- **View spec**: [`physics.md`](../physics.md)
- **Spec key**: `PHY`
- **Glossary terms**: [World unit](../glossary.md)

Split from [`physics.md`](physics.md) by logical unit; that file proves place, capture, promotion, and castling.

## Coverage

| Element | Scenarios | Element | Scenarios |
|---------|-----------|---------|-----------|
| K1 | VS3.1 VS3.2 | I1 | VS3.3 VS3.4 |

## VS3: Collision and settle

As a casual player, I see pieces pass without blocking and settle briefly so that Instant play stays obvious.

### VS3.1: No blocking on path contact

- **Proves**: K1

```gherkin
Given CAM-board Web 9:16, piece A on d4, piece B traveling a legal place whose path crosses d4
When B's body center reaches d4 while A is still there
Then no simulated blocking shape stops or redirects B And placement follows SPC.P1
```

### VS3.2: Pass-through at rest

- **Proves**: K1

```gherkin
Given CAM-board Web 9:16, two adjacent pieces, neither move in flight
When sampled
Then K1 holds: no colliders And each body center is on its square center (SPC.P1); shapes that never collide pass through
```

### VS3.3: Settle mid

- **Proves**: I1

```gherkin
Given CAM-board Web 9:16, M1 just landed on e4, elapsed 0.01 s into settle
When sampled
Then the mover body center is on the e4 square center And settle is not yet past 0.03 s
```

### VS3.4: Settle bound

- **Proves**: I1

```gherkin
Given CAM-board Web 9:16, M1 landed on e4
When settle measured at elapsed 0.03 s after land
Then settle is complete (≤ 0.03 s) And camera shake is none And only the landing cue plays And selection clear is the design outcome (not a cue)
And at elapsed 0.04 s settle remains complete And the body center stays on e4
```
