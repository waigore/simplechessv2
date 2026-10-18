# Design Traceability

Authoring rules: [`.agents/specs/rules/design/traceability.md`](../../.agents/specs/rules/design/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play | vision | [`loops/`](loops/); [`features/move-advice.md`](features/move-advice.md) (never delays a move); [`entities/pieces.md`](entities/pieces.md) |
| Clear board | vision | [`entities/pieces.md`](entities/pieces.md); [`experience.md`](experience.md) clarity |
| Cafe calm | vision | Untimed default in [`configuration.md`](configuration.md); [`flows/mode-pick.md`](flows/mode-pick.md); [`experience.md`](experience.md); [`world.md`](world.md) |
| Shared game; clocks; new session | definition | [`loops/two-player-game.md`](loops/two-player-game.md); [`configuration.md`](configuration.md); [`end-conditions.md`](end-conditions.md) |
| Puzzle stream + Elo matching | definition | [`loops/puzzle-stream.md`](loops/puzzle-stream.md); [`difficulty.md`](difficulty.md); [`progression.md`](progression.md) |
| Optional Stockfish advice | definition | [`features/move-advice.md`](features/move-advice.md) |
| Win / lose (shared + puzzle) | definition | [`end-conditions.md`](end-conditions.md) |
| Web / commute sitting | definition | Genre profile in [`design.md`](design.md); loop timescales |
| No computer opponent / matchmaking | definition (out of scope) | Conventions rejected in [`design.md`](design.md) — not served as a goal |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Core loop and mechanics | [`loops/`](loops/), [`features/`](features/) | Applies |
| Characters | [`characters/`](characters/) | N/A — the people playing are not authored characters |
| Entities (items, objects, hazards) | [`entities/`](entities/) | Applies — chess pieces |
| World and narrative | [`world.md`](world.md) | Applies — cafe framing only |
| Flows and transitions | [`flows/`](flows/) | Applies — mode pick |
| Stages and scenes | [`stages/`](stages/) | N/A — no stages; board play only |
| Game state | [`game-state.md`](game-state.md) | Applies |
| Configuration | [`configuration.md`](configuration.md) | Applies |
| Difficulty settings | [`difficulty.md`](difficulty.md) | Applies — puzzle Elo only |
| Scenarios | [`scenarios/puzzle-stream-visit.md`](scenarios/puzzle-stream-visit.md) | Applies |
| Progress management | [`progression.md`](progression.md) | Applies |
| Sub-games | [`sub-games/`](sub-games/) | N/A — the puzzle stream is a primary mode, not a minigame inside a match |
| Win and loss conditions | [`end-conditions.md`](end-conditions.md) | Applies |
| Economy and resources | [`features/`](features/) | N/A — no economy |
| Opponent and NPC behavior | [`characters/`](characters/), [`features/`](features/) | N/A — both seats are people; no NPC |
| Experience and feel | [`experience.md`](experience.md) | Applies |
