# Piece rules — queen, rook, bishop, knight

Authoring rules: [`.agents/specs/rules/design/entities.md`](../../../../.agents/specs/rules/design/entities.md).

## Purpose

N/A — split from [`pieces.md`](../pieces.md). Blocking and capture: [common.md](common.md).

## Properties

N/A — split from [`pieces.md`](../pieces.md).

## Lifecycle and states

N/A — split from [`pieces.md`](../pieces.md).

## Interactions

### Sliding rule (queen, rook, bishop)

- **I23**: A sliding move follows a straight ray. Every square before the destination is empty. The destination is empty or holds an opponent. The piece stops there; it does not continue past a capture.

### Queen

- **I24**: Any number of squares vertically, horizontally, or diagonally (I23).

### Rook

- **I25**: Any number of squares vertically or horizontally (I23). After it moves, that rook cannot castle (`P4`).

### Bishop

- **I26**: Any number of squares diagonally (I23).

### Knight

- **I27**: Moves to a square two steps orthogonal and one step perpendicular (eight 2×1 targets). Jumps intervening pieces. Destination empty or opponent-occupied.

## Placement and availability

N/A — split from [`pieces.md`](../pieces.md).

## Experience intent

N/A — split from [`pieces.md`](../pieces.md).
