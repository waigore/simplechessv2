# Game Definition

Authoring rules: [`.agents/specs/rules/definition.md`](../../.agents/specs/rules/definition.md).

## Scope

### In scope

- Two people play chess on one device in the browser.
- Untimed play, and timed blitz and rapid with time added after each move.
- A continuous solo puzzle stream that gets harder or easier from each result.
- Optional Stockfish move advice when the browser is online and Advice is On.
- Starting a new two-player session after a game ends.

### Out of scope

- A computer opponent.
- Online matchmaking between remote players.

## Objectives

### Player objectives

- **Goal**: Win the shared game, or solve the puzzle currently dealt.
- **Win / lose conditions**: A game ends by checkmate, resignation, stalemate, agreement, threefold repetition, the fifty-move rule, or clock expiry. In a timed game, a side whose clock reaches zero loses if the other side can still checkmate, and the game is drawn otherwise. Only the side to move has a clock running. The players may begin a new session. A puzzle is solved when its required sequence is played with no wrong move. A wrong move does not deal the next puzzle. Revealing the solution, or completing the sequence only after a wrong move, is a failure, and the next puzzle is dealt.
- **Progression**: Puzzle selection tracks each result and deals a harder or easier puzzle next. Two-player games have no long-term progression.

### Product objectives

- A casual player can finish a two-player game or a puzzle in the browser during a commute.

## Supported platforms

| Platform | Primary input | Priority |
|----------|---------------|----------|
| Web | Touch | Primary |

## Engine

- **Engine**: Godot — It can ship a 2D browser game with touch input and keep move presentation on the device.
- **Implications**: The game is 2D and ships in the browser with touch as the primary input. Optional move advice does not gate a local move.

## Constraints

### Design

- Both players share one browser for a game — a commute session does not need a remote opponent.

### Technical

- A local move completes without waiting on the network — Stockfish advice is optional, asynchronous, and time-capped.

### Market

- A commuter opens the game in the browser with no install — sessions are short and on the web.

## Spec depth

- **Depth**: full — The game is a complete two-mode product, so downstream specs carry full story coverage and visual artifacts.

## Quality expectations

[`quality.md`](quality.md).
