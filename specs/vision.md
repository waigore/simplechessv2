# Game Vision

Authoring rules: [`.agents/specs/rules/vision.md`](../.agents/specs/rules/vision.md).

## Elevator pitch

A zen web chess game where you play a friend on one device, or work a stream of puzzles matched to your level, to enjoy a quiet game, set at a cafe table.

## High-level description

You sit down at a quiet cafe table, in the browser, and either play a friend on the same device or take the next puzzle in a stream matched to your level. The board is classic mahogany and the pieces are distinct vectors, so a casual player can read the position at a glance. Moves snap into place, with sounds for touch, move, check, checkmate, and resign, under cafe ambient music. Untimed play leaves as long as you want to think. Timed play offers blitz and rapid, with time added after each move. The other seat is always a person. When you are online and Advice is on, the best move and eval can appear on the board without holding up the move.

## Target audience and player fantasy

- **Audience**: Casual chess players on a commute, in sessions of about 15–40 minutes, playing in the browser by touch.
- **Player fantasy**: Sitting at a quiet cafe table with a beautiful board, taking the time you want.

## Essential qualities

| # | Quality | Description | Supports it if… |
|---|---------|-------------|-----------------|
| 1 | Instant play | A move never waits on a server. | Piece motion and sound finish on the device with no network round-trip. |
| 2 | Clear board | Every piece type is readable at a glance. | A casual player can name each piece from its shape alone. |
| 3 | Cafe calm | The presentation feels like a quiet cafe, not a competitive chess site. | Cafe ambient music plays for the whole session, including blitz and rapid. |

## Tradeoffs

1. Instant play over Clear board: a move stays immediate even when that means a simpler effect.
2. Instant play over Cafe calm: a move stays immediate even when that shortens a calmer beat.
3. Clear board over Cafe calm: piece shapes stay readable even when that limits ornamental detail.

## Non-goals

- A computer opponent.
- Online matchmaking.
