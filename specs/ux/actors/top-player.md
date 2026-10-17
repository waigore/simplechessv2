# Actor: Top player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience on Shared game (second seat); Instant play, Cafe calm
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Top player](../../design/glossary.md)

## Who they are

The person at the far edge of the shared device. They only operate Shared play for their seat. They do not host mode pick, setup, results, or Puzzle stream.

## Goals

- Make legal moves and resign on their turn
- Use the shared Advice control when they want suggestions for the side to move

## Can operate

- **C1**: On `shared-play`: select and move when Top’s seat is [Side to move](../../design/glossary.md); resign then
- **C2**: On `shared-play`: Advice toggle anytime (one shared control)
- **C3**: Confirm and Cancel for resign `EX.confirm` on their turn

## Cannot operate

- **K1**: `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play` controls — do not activate
- **K2**: On `shared-play`, select, move, or resign when Bottom’s seat is side to move — do not activate

## Relationship to play

None — seats are not design characters. Operates the Top seat in Shared game ([configuration.md](../../design/configuration.md)).
