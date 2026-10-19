# Actor: Top player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience on Shared game (second seat); Instant play, Cafe calm
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Top player](../../design/glossary.md)

## Who they are

The person at the far edge of the shared device. By convention they join only Shared play: move, promote, resign, and offer a draw on their turn, and answer Bottom's offer. The interface does not identify people, so host screens remain operable if touched; hosting is Bottom's social role.

## Goals

- Make legal moves and resign on their turn
- Use the shared Advice control when they want suggestions for the side to move

## Can operate

- **C1**: On `shared-play`, when Top’s seat is [Side to move](../../design/glossary.md): select, move, clear selection, promotion choice, resign, offer draw, and withdraw Top’s offer
- **C2**: On `shared-play`: Advice toggle anytime (one shared control)
- **C3**: Confirm and Cancel for resign or draw-offer `EX.confirm` on their turn
- **C4**: On `shared-play` `EX.draw-offer`: Accept or Decline (the other seat's social role)

## Cannot operate

- **K2**: On `shared-play`, select, move, clear, promote, resign, or offer when Bottom’s seat is side to move — the interface ignores them

## Relationship to play

None — seats are not design characters. Operates the Top seat in Shared game ([configuration.md](../../design/configuration.md)).
