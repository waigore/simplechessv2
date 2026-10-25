# #400 headless-20261025T230918Z — `mode-and-config` rows

One row per cited story row, with the outcome and its `not-judged` reason.

| `mode-and-config` | `configuration.md#PS1` | pass | PS1.12 Increment blocked when Untimed (clock untimed) / PS1.11 Increment available when timed (clock blitz, disabled false) / PS1.3/1.5 C1 → shared-setup then Start → shared-play, Bottom White, Untimed clocks none (stage shared-play, white white, clock <null>) / PS1.6 Blitz both clocks 60 (59997 / 60000 ms) / PS1.7 Rapid 600 (599997 ms) / PS1.14 increment applied after White's move (64997 ms) / PS1.9 Advice On at start / PS1.10 Advice Off |
| `mode-and-config` | `flows/mode-pick.md#PS1` | pass | FL PS1.1 mode-pick is P1 on cold open |
| `mode-and-config` | `flows/mode-pick-unavailable.md#PS1` | pass | FL PS1.1 no piece move at P1 (loading blocks C1/C2) |
| `mode-and-config` | `loops/two-player-tunables.md#PS1` | pass | CFG.BLITZ_START 60 applied (59997 ms) / CFG.RAPID_START 600 applied (599997 ms) |
| `mode-and-config` | `features/move-advice-tunables.md#PS1` | not-judged | CFG.ADVICE_TIME_MS default is a technical configuration row, not a play observation |
| `mode-and-config` | `difficulty-tunables.md#PS1` | not-judged | DIF tunables are proven by the puzzle-stream rows (PTD-difficulty) |
