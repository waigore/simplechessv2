# Design story view: game-state

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [design story view](index.md); rule: [map index](../../story-protocol.md). Every row whose `Spec key` is `GS`; the protocol cites the key, which covers all nine.

**Element** is the cite token from the judging protocol that covers the row. **Judged by** lists every protocol that covers it.

| Story row | `Spec key` | Element | Judged by |
|-----------|-----------|---------|-----------|
| [`game-state.md#PS1`](../../../../design/stories/game-state.md#PS1) | `GS` | `GS` invariants | `game-state` |
| [`game-state/fields-play.md#PS1`](../../../../design/stories/game-state/fields-play.md#PS1) | `GS` | `GS` GS.position, GS.sideToMove… | `game-state` |
| [`game-state/fields-play-moment.md#PS1`](../../../../design/stories/game-state/fields-play-moment.md#PS1) | `GS` | `GS` GS.selectedPiece, GS.online… | `game-state` |
| [`game-state/fields-play-puzzle.md#PS1`](../../../../design/stories/game-state/fields-play-puzzle.md#PS1) | `GS` | `GS` GS.solvingSide, GS.sideToMove… | `game-state` |
| [`game-state/fields-play-reset.md#PS1`](../../../../design/stories/game-state/fields-play-reset.md#PS1) | `GS` | `GS` GS.whiteClock, GS.blackClock… | `game-state` |
| [`game-state/fields-play-end.md#PS1`](../../../../design/stories/game-state/fields-play-end.md#PS1) | `GS` | `GS` GS.gameEnded, GS.drawOffer… | `game-state` |
| [`game-state/fields-play-draw.md#PS1`](../../../../design/stories/game-state/fields-play-draw.md#PS1) | `GS` | `GS` GS.drawOffer | `game-state` |
| [`game-state/fields-persist.md#PS1`](../../../../design/stories/game-state/fields-persist.md#PS1) | `GS` | `GS` GS.playerElo, GS.lastMode… | `game-state` |
| [`game-state/fields-persist-config.md#PS1`](../../../../design/stories/game-state/fields-persist-config.md#PS1) | `GS` | `GS` GS.whiteSeat, GS.clock… | `game-state` |
