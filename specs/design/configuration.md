# Configuration

Authoring rules: [`.agents/specs/rules/design/configuration.md`](../../.agents/specs/rules/design/configuration.md).

- **Serves**: Timed/untimed play and optional advice (definition scope); Cafe calm via the Untimed default (vision).

## Modes

| Mode | Description | Differs from standard rules by | Flow |
|------|-------------|--------------------------------|------|
| Shared game | Two people play on one device | Baseline. Optional clocks and advice | [`loops/two-player-game.md`](loops/two-player-game.md) |
| Puzzle stream | Solo continuous puzzles | No clocks. No advice. Next puzzle follows [Player Elo](glossary.md) | [`loops/puzzle-stream.md`](loops/puzzle-stream.md) |

## Game options

Seats on the shared device are the **Top player** and the **Bottom player**.

| Option | Choices | Default | Effect on rules | Chosen by / when | Locked when |
|--------|---------|---------|-----------------|------------------|-------------|
| White seat | Top player, Bottom player | Bottom player | That seat plays White and moves first | Players; before Shared game starts | Shared game starts |
| Clock | Untimed, Blitz, Rapid | Untimed | Untimed: no clocks. Blitz: each side starts at `CFG.BLITZ_START`. Rapid: each side starts at `CFG.RAPID_START`. Timed: only the side to move runs a clock | Players; before Shared game starts | Shared game starts |
| Increment | 3 s, 5 s | 3 s | After each completed move, that side's clock gains the chosen seconds, not if the clock has already reached zero | Players; before Shared game starts, when Clock is Blitz or Rapid | Shared game starts |
| Advice | On, Off | On | When On and online, automatic best-move advice for the side to move (highlights, arrow, eval). When Off, none. Shared game only | Players; before Shared game starts and during it | Not locked; may toggle during the Shared game |

## Designer tunables

| Parameter | Owner spec | Default | Range | Unit | Effect |
|-----------|------------|---------|-------|------|--------|
| `CFG.BLITZ_START` | [`loops/two-player-game.md`](loops/two-player-game.md) | 60 | 30–180 | seconds | Starting clock for each side in Blitz |
| `CFG.RAPID_START` | [`loops/two-player-game.md`](loops/two-player-game.md) | 600 | 300–1800 | seconds | Starting clock for each side in Rapid |
| `CFG.ELO_BAND_WIDEN` | [`difficulty.md`](difficulty.md) | 50 | 25–100 | Elo | Step the ±`CFG.ELO_MATCH_RANGE` deal band widens by when no candidate fits ([DIF.Y1](difficulty.md)) |
| `CFG.ELO_K` | [`difficulty.md`](difficulty.md) | 20 | 10–40 | — | Classic Elo K-factor for [Player Elo](glossary.md) updates |
| `CFG.ELO_MATCH_RANGE` | [`difficulty.md`](difficulty.md) | 100 | 50–200 | Elo | ± band when dealing the next puzzle by [Player Elo](glossary.md) |
| `CFG.ELO_RECENT_WINDOW` | [`difficulty.md`](difficulty.md) | 20 | 5–50 | puzzles | Solved ([END.W1](end-conditions/conditions.md)) puzzle memory for deal preference ([DIF.Y1](difficulty.md)); caps `GS.recentSolved` |
| `CFG.ELO_START` | [`difficulty.md`](difficulty.md) | 1000 | 400–2400 | Elo | First-time [Player Elo](glossary.md) |
| `CFG.ADVICE_TIME_MS` | [`features/move-advice.md`](features/move-advice.md) | 2000 | 500–5000 | ms | Max engine think time per position for [Advice](glossary.md) |

## Dependencies and restrictions

- **K1**: Increment is available only when Clock is Blitz or Rapid.
- **K2**: White seat, Clock, and Increment apply only in Shared game.
- **K3**: Advice applies only in Shared game, not Puzzle stream.
