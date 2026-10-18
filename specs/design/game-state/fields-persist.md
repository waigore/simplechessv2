# Game-state fields — persistent and configuration

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Part of [`fields.md`](fields.md).

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.playerElo` | Persistent | Visible [Player Elo](../glossary.md) | `CFG.ELO_START` | [DIF.Y1](../difficulty.md) | No cap |
| `GS.lastMode` | Persistent | Shared game, Puzzle stream, or none | none | Mode pick T1/T2 | Matches [Last mode](../glossary.md) |
| `GS.recentSolved` | Persistent | Puzzle IDs solved ([END.W1](../end-conditions/conditions.md)), newest last, max `CFG.ELO_RECENT_WINDOW` | empty | END.W1 append; trim to `CFG.ELO_RECENT_WINDOW` | Length ≤ `CFG.ELO_RECENT_WINDOW` |
| `GS.whiteSeat` | Configuration | Top or Bottom plays White | Bottom player | Before Shared game starts | Locked when Shared game starts |
| `GS.clock` | Configuration | Untimed, Blitz, or Rapid | Untimed | Before Shared game starts | Locked when Shared game starts |
| `GS.increment` | Configuration | 3 s or 5 s when timed | 3 s | Before Shared game starts when timed | Locked when Shared game starts |
| `GS.advice` | Configuration | Advice On or Off | On | Before and during Shared game | Shared game only |
| `GS.locale` | Configuration | `en`, `zh-Hant`, or `ja` | Browser locale when shipped, else `en` | Player setting | One of the shipped locales |
