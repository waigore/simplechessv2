# Actor: Bottom player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience (casual web/touch); Instant play, Cafe calm; Shared game and Puzzle stream scope
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Bottom player](../../design/glossary.md)

## Who they are

The person at the near edge of the shared device. In a Shared game they fill the [Bottom player](../../design/glossary.md) seat. That seat is only a game concept: which side sits at the near edge, and whether that side plays White. The interface does not identify people and does not allow or refuse any control because of this seat. Whoever touches the screen operates it, on every screen. This actor and the Top player do not differ in what the interface allows.

## Goals

- Start a Shared game or Puzzle stream quickly
- Finish a commute session and return to mode pick
- Play again after a Shared result without reopening the site

## Can operate

- **C1**: All controls on `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play`. Whoever touches them operates them. The Top player spec lists the same controls.
- **C2**: On `shared-play`, when Bottom’s seat is [Side to move](../../design/glossary.md): select, move, clear selection, promotion choice, resign, offer draw, and withdraw Bottom’s offer. Advice toggle anytime
- **C3**: Confirm and Cancel on exceptions those screens use
- **C4**: On `shared-play` `EX.draw-offer`: Accept or Decline. Whoever touches the panel operates it. The game records the answer as the other seat's.

## Cannot operate

- **K1**: On `shared-play`, when the Top seat is side to move, a touch does not select, move, clear, promote, resign, or offer for the Bottom seat. The interface ignores that touch. It does not check which person touched.

## Relationship to play

None — seats are not design characters. Operates the Bottom seat in Shared game ([configuration.md](../../design/configuration.md)).
