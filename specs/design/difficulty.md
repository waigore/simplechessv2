# Difficulty

Authoring rules: [`.agents/specs/rules/design/difficulty.md`](../../.agents/specs/rules/design/difficulty.md).

- **Approach**: Dynamic Elo matching in [Puzzle stream](glossary.md) only. Each [Puzzle](glossary.md) has a fixed [Puzzle Elo](glossary.md). The player has a [Player Elo](glossary.md) ([PRG.A1](progression.md)). [Shared game](glossary.md) has no difficulty system.
- **Why**: Vision “puzzles matched to your level” and Cafe calm for a casual commute — adaptive pick, not selectable levels.

## Difficulty levels

N/A — no Easy/Medium/Hard labels. Challenge is continuous [Player Elo](glossary.md).

## Parameter adjustments

N/A — no named levels. Elo tunables live in [configuration.md](configuration.md).

## Rule adjustments

None — the same orthodox movement and capture rules apply at every Elo. Only which puzzle is dealt and how [Player Elo](glossary.md) updates change.

## Dynamic adjustment

- **Y1**: Observed signal is a puzzle result. [END.W1](end-conditions/conditions.md) is a win (S = 1). [END.L4](end-conditions/conditions.md), [END.L5](end-conditions/conditions.md), or [END.L6](end-conditions/conditions.md) (abandoning the puzzle) is a loss (S = 0). Expected score `E = 1 / (1 + 10^((puzzleElo − playerElo) / 400))`. Then `playerElo ← playerElo + CFG.ELO_K × (S − E)`. [Puzzle Elo](glossary.md) never changes. First-time [Player Elo](glossary.md) is `CFG.ELO_START`. No cap. The player sees their [Player Elo](glossary.md). Prefer the next [Puzzle](glossary.md) whose [Puzzle Elo](glossary.md) is within ±`CFG.ELO_MATCH_RANGE` of current [Player Elo](glossary.md) and that the player has not solved ([END.W1](end-conditions/conditions.md)) among the last `CFG.ELO_RECENT_WINDOW` puzzles in the [Puzzle stream](glossary.md). If none fit, relax either or both rules: widen the ± band by `CFG.ELO_BAND_WIDEN`, and/or allow a recently solved puzzle; repeat until one is found. Puzzles may otherwise repeat within a [Sitting](glossary.md) and across sittings.

## Challenge curve

Each result gently drifts [Player Elo](glossary.md). No mode spikes. A commute [Sitting](glossary.md) feels adaptive. [Shared game](glossary.md): N/A.

## Changing difficulty

- **C1**: The player cannot set [Player Elo](glossary.md) by hand. Only END.W1, END.L4, END.L5, or END.L6 (abandon) update it. It resets only when the browser clears this game's storage ([PRG.P1](progression.md)).

## Fairness

Same movement and capture rules every puzzle. A [Wrong move](glossary.md) returns the puzzle to its start. No [Advice](glossary.md) in [Puzzle stream](glossary.md). Failure never ends the stream.
