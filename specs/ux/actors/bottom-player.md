# Actor: Bottom player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience (casual web/touch); Instant play, Cafe calm; Shared game and Puzzle stream scope
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Bottom player](../../design/glossary.md)

## Who they are

The person at the near edge of the shared device. They host mode pick, setup, results, and Puzzle stream. In Shared play they move, promote, resign, and offer a draw when their seat is the side to move, and they answer the other seat's offer.

## Goals

- Start a Shared game or Puzzle stream quickly
- Finish a commute sitting and return to mode pick
- Play again after a Shared result without reopening the site

## Can operate

- **C1**: All controls on `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play`
- **C2**: On `shared-play`, when Bottom’s seat is [Side to move](../../design/glossary.md): select, move, clear selection, promotion choice, resign, offer draw, and withdraw Bottom’s offer. Advice toggle anytime
- **C3**: Confirm and Cancel on exceptions those screens use
- **C4**: On `shared-play` `EX.draw-offer` opened by Top: Accept and Decline

## Cannot operate

- **K1**: On `shared-play`, select, move, clear, promote, resign, or offer when Top’s seat is side to move — those controls do not activate for Bottom
- **K2**: Accept or Decline an offer Bottom made — those controls do not activate for Bottom

## Relationship to play

None — seats are not design characters. Operates the Bottom seat in Shared game ([configuration.md](../../design/configuration.md)).
