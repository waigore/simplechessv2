# Progress Management

Authoring rules: [`.agents/specs/rules/design/progression.md`](../../.agents/specs/rules/design/progression.md).

## Progression axes

| ID | Axis | Kind | Advanced by | Cap |
|----|------|------|-------------|-----|
| A1 | Puzzle difficulty | rank | [W1](end-conditions/conditions.md) raises it. [L4](end-conditions/conditions.md), [L5](end-conditions/conditions.md), or abandoning the puzzle lowers it | None |

Shared games have no progression axis.

## Unlocks

None — no content or mode unlocks.

## Persistence

| ID | What | Persists across | Lost or reset when |
|----|------|-----------------|--------------------|
| P1 | Puzzle difficulty rank (A1) | Sittings, in the browser's storage for this game | The browser clears this game's storage |

## Committing progress

- **M1**: A1 commits after each puzzle result (W1, L4, L5) or abandon. After an interruption, play resumes by dealing the next puzzle at the current rank.

## Failure consequences

- **F1**: A shared game carries nothing forward. On L4, L5, or abandon, the stream continues and only A1 is lowered for the next puzzle.

## Completion

- **Z1**: None — the player stops the puzzle stream when they choose.
- **Z2**: Ends.
- **Z3**: Same as finishing.

## Experience intent

Each puzzle result gently steers the next one. A commute sitting feels adaptive, not like climbing a career ladder.
