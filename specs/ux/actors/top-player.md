# Actor: Top player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience on Shared game (second seat); Instant play, Cafe calm
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Top player](../../design/glossary.md)

## Who they are

The person at the far edge of the shared device. In a Shared game they fill the [Top player](../../design/glossary.md) seat. That seat is only a game concept: which side sits at the far edge, and whether that side plays White. The interface does not identify people and does not allow or refuse any control because of this seat. Whoever touches the screen operates it, on every screen. This actor and the Bottom player do not differ in what the interface allows.

## Goals

- Start a Shared game or Puzzle stream, leave a result, or leave the stream
- Make legal moves and resign on the Top seat's turn
- Use the shared Advice control when they want suggestions for the side to move

## Can operate

- **C1**: On `shared-play`, when Top’s seat is [Side to move](../../design/glossary.md): select, move, clear selection, promotion choice, resign, offer draw, and withdraw Top’s offer
- **C2**: On `shared-play`: Advice toggle anytime (one shared control)
- **C3**: Confirm and Cancel for resign or draw-offer `EX.confirm` on their turn
- **C4**: On `shared-play` `EX.draw-offer`: Accept or Decline. Whoever touches the panel operates it. The game records the answer as the other seat's.
- **C5**: All controls on `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play`. Whoever touches them operates them. The Bottom player spec lists the same controls.

## Cannot operate

- **K2**: On `shared-play`, when the Bottom seat is side to move, a touch does not select, move, clear, promote, resign, or offer for the Top seat. The interface ignores that touch. It does not check which person touched.

## Relationship to play

None — seats are not design characters. Operates the Top seat in Shared game ([configuration.md](../../design/configuration.md)).
