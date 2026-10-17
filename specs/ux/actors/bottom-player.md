# Actor: Bottom player

Authoring rules: [`.agents/specs/rules/ux/actors.md`](../../../.agents/specs/rules/ux/actors.md).

- **Serves**: Vision audience (casual web/touch); Instant play, Cafe calm; Shared game and Puzzle stream scope
- **Platforms**: Web (touch)
- **Glossary terms**: [Actor](../glossary.md); design [Bottom player](../../design/glossary.md)

## Who they are

The person at the near edge of the shared device. They host mode pick, setup, results, and Puzzle stream. In Shared play they move and resign when their seat is the side to move.

## Goals

- Start a Shared game or Puzzle stream quickly
- Finish a commute sitting and return to mode pick
- Play again after a Shared result without reopening the site

## Can operate

- **C1**: All controls on `mode-pick`, `shared-setup`, `shared-result`, and `puzzle-play`
- **C2**: On `shared-play`: select and move when Bottom’s seat is [Side to move](../../design/glossary.md); resign then; Advice toggle anytime
- **C3**: Confirm and Cancel on exceptions those screens use

## Cannot operate

- **K1**: On `shared-play`, select, move, or resign when Top’s seat is side to move — those controls do not activate for Bottom

## Relationship to play

None — seats are not design characters. Operates the Bottom seat in Shared game ([configuration.md](../../design/configuration.md)).
