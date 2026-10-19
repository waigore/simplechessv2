# Actor: Top player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience on Shared game (second seat); Instant play, Cafe calm
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Top player](../../design/glossary.md)

## Who they are

The person at the far edge of the shared device. They only operate Shared play for their seat: move, promote, resign, and offer a draw on their turn, and answer Bottom's offer. They do not host mode pick, setup, results, or Puzzle stream.

## Goals

- Make legal moves and resign on their turn
- Use the shared Advice control when they want suggestions for the side to move

## Can operate

- **C1**: On `shared-play`, when Top’s seat is [Side to move](../../design/glossary.md): select, move, clear selection, promotion choice, resign, offer draw, and withdraw Top’s offer
- **C2**: On `shared-play`: Advice toggle anytime (one shared control)
- **C3**: Confirm and Cancel for resign or draw-offer `EX.confirm` on their turn
- **C4**: On `shared-play` `EX.draw-offer` opened by Bottom: Accept and Decline

## Cannot operate

- **K1**: `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play` controls — do not activate
- **K2**: On `shared-play`, select, move, clear, promote, resign, or offer when Bottom’s seat is side to move — do not activate
- **K3**: Accept or Decline an offer Top made — those controls do not activate for Top

## Relationship to play

None — seats are not design characters. Operates the Top seat in Shared game ([configuration.md](../../design/configuration.md)).
