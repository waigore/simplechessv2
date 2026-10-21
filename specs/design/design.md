# Game Design

Authoring rules: [`.agents/specs/rules/design/design.md`](../../.agents/specs/rules/design/design.md).

## Genre and platform profile

- **Genre(s)**: Turn-based chess, with a solo puzzle mode.
- **Conventions adopted**:
  - Orthodox chess on an 8×8 board. Two sides alternate a single piece move. The shared game and every puzzle use the same movement and capture rules.
  - Clocked and unclocked play. A timed game is blitz or rapid, with the same starting time on both clocks and time added after each move. An untimed game has no clock.
  - A puzzle stream. One puzzle is dealt at a time. The player moves the [Solving side](glossary.md); the game plays each required reply. Solving it makes the next puzzle harder. Failing or abandoning it makes the next puzzle easier. The player stops when they choose.
- **Conventions rejected or changed**:
  - A computer opponent. Both seats in a shared game are people, because a computer opponent is a vision non-goal.
  - Online matchmaking. Both people share one device, because matchmaking is a vision non-goal.
  - A required clock. Untimed play stays available so a commute game can stay calm.
  - Chess variants, including Chess960. Play is orthodox chess only.
- **Platform implications**: Web sessions of about 15–40 minutes → one shared game is meant to finish in that session, and a puzzle session is as many single puzzles as fit that window.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`game-state.md`](game-state.md), [`game-state/fields.md`](game-state/fields.md), [`game-state/fields-play.md`](game-state/fields-play.md), [`game-state/fields-play-end.md`](game-state/fields-play-end.md), [`game-state/fields-persist.md`](game-state/fields-persist.md), [`configuration.md`](configuration.md), [`difficulty.md`](difficulty.md), [`progression.md`](progression.md), [`end-conditions.md`](end-conditions.md), [`end-conditions/conditions.md`](end-conditions/conditions.md), [`world.md`](world.md), [`experience.md`](experience.md), [`experience/feedback.md`](experience/feedback.md).

- **Characters**: None — the people playing are not authored characters.
- **Entities**: [`pieces.md`](entities/pieces.md) ([common](entities/pieces/common.md), [king](entities/pieces/king.md), [officers](entities/pieces/officers.md), [pawn](entities/pieces/pawn.md))
- **Loops**: [`two-player-game.md`](loops/two-player-game.md), [`puzzle-stream.md`](loops/puzzle-stream.md)
- **Features**: [`move-advice.md`](features/move-advice.md), [`puzzle-catalog.md`](features/puzzle-catalog.md)
- **Flows**: [`mode-pick.md`](flows/mode-pick.md)
- **Stages**: None — no stages; board play only.
- **Scenarios**: [`scenarios/puzzle-stream-visit.md`](scenarios/puzzle-stream-visit.md)
- **Sub-games**: None — the puzzle stream is a primary mode, not a minigame inside a match.
