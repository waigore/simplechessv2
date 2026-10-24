# Design story view: shared-game

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [design story view](index.md); rule: [map index](../../story-protocol.md). Rows whose scenarios prove `L-two-player-game` K and E steps, plus the clock tunables the `CFG` cite covers.

**Element** is the cite token from the judging protocol that covers the row. **Judged by** lists every protocol that covers it.

| Story row | `Spec key` | Element | Judged by |
|-----------|-----------|---------|-----------|
| [`loops/two-player-game.md#PS1`](../../../../design/stories/loops/two-player-game.md#PS1) | `L-two-player-game` | `L-two-player-game` K1,K2,K3,E1,E2,E3,E4; `CFG` (CFG.BLITZ_START) | `shared-game`, `mode-and-config` |
| [`loops/two-player-draw.md#PS1`](../../../../design/stories/loops/two-player-draw.md#PS1) | `L-two-player-game` | `L-two-player-game` K2 | `shared-game` |
| [`loops/two-player-tunables.md#PS1`](../../../../design/stories/loops/two-player-tunables.md#PS1) | `L-two-player-game` | `CFG` (CFG.BLITZ_START) | `mode-and-config` |
