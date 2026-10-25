# UX Story Coverage

Authoring rules: [`.agents/specs/rules/ux/story-coverage.md`](../../.agents/specs/rules/ux/story-coverage.md).

- **Serves**: Instant play, Clear board, Cafe calm; the Full-coverage bar for UX stories, including the [design](../design/ids.md) and [view](../view/ids.md) facts they cite.

This is the record that each Full-level spec met that bar, and the index of which story file proves which spec. It states no requirement: the rule file owns the requirements by kind.

## Parts

- **Per-spec record**: [`story-coverage/specs.md`](story-coverage/specs.md) — one row per spec in [`stories.md`](stories.md): level, element kinds covered, and the story file plus scenarios that prove them.
- **Exceptions**: [`story-coverage/exceptions.md`](story-coverage/exceptions.md) — one proving row per `EX.<name>` element.
- **UI actions**: [`story-coverage/controls.md`](story-coverage/controls.md) — one proving row per `IN.<name>` element.

12 specs are Full and `localization.md` is Baseline. Every indexed story file carries a coverage table whose rows cite at least one scenario.

## Split story files

A split story file is proof for its base spec and never a row of its own: it carries no coverage table, continues its base file's story IDs, and takes its base spec's level. The `Story file` cell in [`stories.md`](stories.md) lists each split after its base file. 20 splits belong to 8 base specs; 5 indexed specs have none.

- [`controls.md`](controls.md): [`controls-drag.md`](stories/controls-drag.md), [`controls-point.md`](stories/controls-point.md)
- [`exceptions.md`](exceptions.md): [`exceptions-play.md`](stories/exceptions-play.md)
- [`navigation.md`](navigation.md): [`navigation-conditions.md`](stories/navigation-conditions.md)
- [`actors/bottom-player.md`](actors/bottom-player.md): [`choices`](stories/actors/bottom-player-choices.md), [`exceptions`](stories/actors/bottom-player-exceptions.md), [`host`](stories/actors/bottom-player-host.md), [`puzzle`](stories/actors/bottom-player-puzzle.md)
- [`actors/top-player.md`](actors/top-player.md): [`choices`](stories/actors/top-player-choices.md), [`host`](stories/actors/top-player-host.md), [`puzzle`](stories/actors/top-player-puzzle.md)
- [`screens/mode-pick.md`](screens/mode-pick.md): [`mode-pick-unavailable.md`](stories/screens/mode-pick-unavailable.md)
- [`screens/shared-play.md`](screens/shared-play.md): [`choices`](stories/screens/shared-play-choices.md), [`place`](stories/screens/shared-play-place.md), [`regions`](stories/screens/shared-play-regions.md), [`unavailable`](stories/screens/shared-play-unavailable.md)
- [`screens/puzzle-play.md`](screens/puzzle-play.md): [`choices`](stories/screens/puzzle-play-choices.md), [`confirm`](stories/screens/puzzle-play-confirm.md), [`place`](stories/screens/puzzle-play-place.md), [`regions`](stories/screens/puzzle-play-regions.md)

`shared-setup.md`, `shared-result.md`, both journeys, and `localization.md` have no split.

## Baseline

[`localization.md`](localization.md) is Baseline: `US1.1`–`US2.4`, one per element, including L7–L10 in [`localization-marked-set.md`](localization-marked-set.md) ([`stories/localization.md`](stories/localization.md)). It is a chosen lighter depth, not a gap — the copy it owns is checked on the mockup during review and acceptance.
