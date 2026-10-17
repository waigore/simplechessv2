# Configuration

Authoring rules: [`.agents/specs/rules/design/configuration.md`](../../.agents/specs/rules/design/configuration.md).

## Modes

| Mode | Description | Differs from standard rules by | Flow |
|------|-------------|--------------------------------|------|
| Shared game | Two people play on one device | Baseline. Optional clocks and advice | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Puzzle stream | Solo continuous puzzles | No clocks. No advice. Next puzzle follows [Player Elo](glossary.md) | TBD — which flow or loop owns the puzzle stream? |

## Game options

Seats on the shared device are the **Top player** and the **Bottom player**.

| Option | Choices | Default | Effect on rules | Chosen by / when | Locked when |
|--------|---------|---------|-----------------|------------------|-------------|
| White seat | Top player, Bottom player | TBD — which seat is White by default? | That seat plays White and moves first | Players; before Shared game starts | Shared game starts |
| Clock | Untimed, Blitz, Rapid | Untimed | Untimed: no clocks. Blitz: each side starts at `CFG.BLITZ_START`. Rapid: each side starts at `CFG.RAPID_START`. Timed: only the side to move runs a clock | Players; before Shared game starts | Shared game starts |
| Increment | 3 s, 5 s | 3 s | After each completed move, that side's clock gains the chosen seconds, not if the clock has already reached zero | Players; before Shared game starts, when Clock is Blitz or Rapid | Shared game starts |
| Advice | On, Off | On | When On and online, a player may ask for move suggestions. When Off, none. Shared game only | TBD — before Shared game only, or any time during it? | TBD — follows the Advice chosen-by question |

## Designer tunables

| Parameter | Owner spec | Default | Range | Unit | Effect |
|-----------|------------|---------|-------|------|--------|
| `CFG.BLITZ_START` | [`loops/two-player-game.md`](loops/two-player-game.md) | 60 | 60 | seconds | Starting clock for each side in Blitz |
| `CFG.RAPID_START` | [`loops/two-player-game.md`](loops/two-player-game.md) | 600 | 600 | seconds | Starting clock for each side in Rapid |
| `CFG.ELO_K` | [`difficulty.md`](difficulty.md) | 20 | 20 | — | Classic Elo K-factor for [Player Elo](glossary.md) updates |
| `CFG.ELO_MATCH_RANGE` | [`difficulty.md`](difficulty.md) | 100 | 100 | Elo | ± band when dealing the next puzzle by [Player Elo](glossary.md) |
| `CFG.ELO_START` | [`difficulty.md`](difficulty.md) | 1000 | 1000 | Elo | First-time [Player Elo](glossary.md) |

## Dependencies and restrictions

- **K1**: Increment is available only when Clock is Blitz or Rapid.
- **K2**: White seat, Clock, and Increment apply only in Shared game.
- **K3**: Advice applies only in Shared game, not Puzzle stream.
