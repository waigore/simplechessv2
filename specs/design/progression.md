# Progress Management

Authoring rules: [`.agents/specs/rules/design/progression.md`](../../.agents/specs/rules/design/progression.md).

## Progression axes

| ID | Axis | Kind | Advanced by | Cap |
|----|------|------|-------------|-----|
| A1 | [Player Elo](glossary.md) | rating | Classic Elo update per [DIF.Y1](difficulty.md): [W1](end-conditions/conditions.md) is a win; [L4](end-conditions/conditions.md), [L5](end-conditions/conditions.md), or abandoning the puzzle is a loss | None |

[Shared game](glossary.md) has no progression axis.

## Unlocks

None — no content or mode unlocks.

## Persistence

| ID | What | Persists across | Lost or reset when |
|----|------|-----------------|--------------------|
| P1 | [Player Elo](glossary.md) (A1) | Sittings, in the browser's storage for this game | The browser clears this game's storage |

## Committing progress

- **M1**: A1 commits after each puzzle result (W1, L4, L5) or abandon. After an interruption, play resumes by dealing the next puzzle at the current [Player Elo](glossary.md).

## Failure consequences

- **F1**: A [Shared game](glossary.md) carries nothing forward. On L4, L5, or abandon, the [Puzzle stream](glossary.md) continues and only A1 updates per [DIF.Y1](difficulty.md).

## Completion

- **Z1**: None — the player stops the [Puzzle stream](glossary.md) when they choose.
- **Z2**: Ends.
- **Z3**: Same as finishing.

## Experience intent

Each puzzle result gently steers the next one via [Player Elo](glossary.md). A commute [Sitting](glossary.md) feels adaptive, not like climbing a career ladder.
