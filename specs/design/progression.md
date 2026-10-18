# Progress Management

Authoring rules: [`.agents/specs/rules/design/progression.md`](../../.agents/specs/rules/design/progression.md).

- **Serves**: Puzzle stream + Elo matching (definition scope); design side of save durability ([quality.md](../definition/quality.md)).

## Progression axes

| ID | Axis | Kind | Advanced by | Cap |
|----|------|------|-------------|-----|
| A1 | [Player Elo](glossary.md) | rating | Classic Elo update per [DIF.Y1](difficulty.md): [END.W1](end-conditions/conditions.md) is a win; [END.L4](end-conditions/conditions.md), [END.L5](end-conditions/conditions.md), or [END.L6](end-conditions/conditions.md) (abandoning the puzzle) is a loss | None |

[Shared game](glossary.md) has no progression axis.

## Unlocks

None — no content or mode unlocks.

## Persistence

| ID | What | Persists across | Lost or reset when |
|----|------|-----------------|--------------------|
| P1 | [Player Elo](glossary.md) (A1) | Sittings, in the browser's storage for this game | The browser clears this game's storage |
| P2 | Last mode (Shared game or Puzzle stream) | Sittings, in the browser's storage for this game | The browser clears this game's storage |
| P3 | `GS.recentSolved` (recent solved puzzle IDs) | Sittings, in the browser's storage for this game | The browser clears this game's storage |

## Committing progress

- **M1**: A1 commits after each puzzle result (END.W1, END.L4, END.L5, or END.L6). `GS.recentSolved` commits with each END.W1 (append newest; trim to `CFG.ELO_RECENT_WINDOW`). P2 commits when the player chooses a mode ([FL-mode-pick.T1](flows/mode-pick.md) / [T2](flows/mode-pick.md)). After an interruption, the next open is mode pick ([FL-mode-pick.U1](flows/mode-pick.md)); re-entering Puzzle stream deals at the committed A1 and `GS.recentSolved` per [DIF.Y1](difficulty.md).

## Failure consequences

- **F1**: A [Shared game](glossary.md) carries nothing forward. On END.L4, END.L5, or END.L6 (abandon), the [Puzzle stream](glossary.md) continues and only A1 updates per [DIF.Y1](difficulty.md).

## Completion

- **Z1**: None — the player stops the [Puzzle stream](glossary.md) when they choose.
- **Z2**: Ends.
- **Z3**: Same as finishing.

## Experience intent

Each puzzle result gently steers the next one via [Player Elo](glossary.md). A commute [Sitting](glossary.md) feels adaptive, not like climbing a career ladder.
