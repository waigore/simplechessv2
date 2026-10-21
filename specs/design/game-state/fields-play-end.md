# Game-state fields — play endings

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../../.agents/specs/rules/design/game-state.md).

Part of [`fields-play.md`](fields-play.md). Shared-game ending fields for [`end-conditions`](../end-conditions.md).

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.gameEnded` | Session / run | Shared game over | false | End conditions | True ⇒ no further Shared moves |
| `GS.drawOffer` | Session / run | Side with pending draw offer, or none | none | Offer; decline; withdraw; move (lapse); end | None or one side; only while Shared open |
| `GS.repetitionHistory` | Session / run | `END.D3` occurrences: position, side, castling, en passant | Empty; record start on new session | After each legal move | Game-long; clear only on new session |
| `GS.fiftyMoveCount` | Session / run | `END.D4` half-moves since capture or pawn move | 0 | +1 per legal move; clear on capture, pawn move, or new session | 0–100; draw at 100 |
