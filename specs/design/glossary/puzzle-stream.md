# Glossary — Puzzle-stream terms

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../../.agents/specs/rules/design/glossary.md).

Part of [`glossary.md`](../glossary.md).

| Term | Definition | Detailed in |
|------|------------|-------------|
| Abandon puzzle | Leave current Puzzle unsolved; Elo loss ([END.L6](../end-conditions/conditions.md)); next dealt | [`loops/puzzle-stream.md`](../loops/puzzle-stream.md) |
| Leave stream | Quit Puzzle stream; Elo kept; open puzzle not abandon | [`loops/puzzle-stream.md`](../loops/puzzle-stream.md) |
| Player Elo | Puzzle rating; starts at `CFG.ELO_START`; Elo updates | [`difficulty.md`](../difficulty.md), [`progression.md`](../progression.md) |
| Puzzle | One dealt position with a required sequence in Puzzle stream | [`end-conditions.md`](../end-conditions.md) |
| Puzzle catalog | Host-held source of dealt puzzles for the 2026-10-05 snapshot: id, position, required sequence, and Puzzle Elo; not shipped in the client | [`features/puzzle-catalog.md`](../features/puzzle-catalog.md) |
| Puzzle Elo | Fixed pre-rated puzzle difficulty; never changes | [`difficulty.md`](../difficulty.md) |
| Puzzle stream | Solo continuous puzzles; next pick follows Player Elo | [`loops/puzzle-stream.md`](../loops/puzzle-stream.md) |
| Required sequence | Correct move sequence that solves a puzzle | [`end-conditions.md`](../end-conditions.md) |
| Reveal solution | Show the required sequence; the puzzle fails ([END.L5](../end-conditions/conditions.md)) | [`end-conditions/conditions.md`](../end-conditions/conditions.md) |
| Solving side | The side the player moves in a Puzzle: the side to move in the dealt position | [`loops/puzzle-stream.md`](../loops/puzzle-stream.md) |
| Wrong move | Solving side move that misses the next required step; any checkmating move counts only when that puzzle's mate-in-one mark holds | [`features/puzzle-catalog.md`](../features/puzzle-catalog.md) |
