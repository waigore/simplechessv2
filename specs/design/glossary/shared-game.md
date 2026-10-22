# Glossary — Shared-game terms

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../../.agents/specs/rules/design/glossary.md).

Part of [`glossary.md`](../glossary.md).

| Term | Definition | Detailed in |
|------|------------|-------------|
| Advice | The best move and eval the player can know when On and online | [`features/move-advice.md`](../features/move-advice.md) |
| Blitz | Timed Shared game; each side starts at `CFG.BLITZ_START` | [`configuration.md`](../configuration.md) |
| Bottom player | Game seat at the bottom of the shared device | [`configuration.md`](../configuration.md) |
| Clock | Shared-game timing: Untimed, Blitz, or Rapid | [`configuration.md`](../configuration.md) |
| Clock expiry | A running clock reaches zero (loss or draw per end conditions) | [`end-conditions.md`](../end-conditions.md) |
| Draw | Shared-game ending that is neither win nor loss | [`end-conditions.md`](../end-conditions.md) |
| Increment | Seconds added after each completed move in Blitz or Rapid | [`configuration.md`](../configuration.md) |
| Rapid | Timed Shared game; each side starts at `CFG.RAPID_START` | [`configuration.md`](../configuration.md) |
| Resign | Side to move ends the Shared game and loses | [`end-conditions.md`](../end-conditions.md) |
| Shared game | Two people play orthodox chess on one device in one session | [`loops/two-player-game.md`](../loops/two-player-game.md) |
| Top player | Game seat at the top of the shared device | [`configuration.md`](../configuration.md) |
| Untimed | Shared game with no clocks | [`configuration.md`](../configuration.md) |
| White seat | Which seat plays White and moves first | [`configuration.md`](../configuration.md) |
