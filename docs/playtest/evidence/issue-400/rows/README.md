# Story rows — #400

One file per protocol, listing the rows the sweep judged with the headless outcome and every `not-judged` reason.
Protocol files and rows: `specs/playtest/traceability/story-protocol/`.

Design rows (headless only): [shared-game](shared-game.md), [puzzle-stream](puzzle-stream.md),
[move-advice](move-advice.md), [mode-and-config](mode-and-config.md), [end-conditions](end-conditions.md),
[game-state](game-state.md), [pieces-common](pieces-common.md), [pieces-king](pieces-king.md),
[pieces-officers](pieces-officers.md), [pieces-pawn](pieces-pawn.md), [difficulty](difficulty.md),
[progression](progression.md).

UX rows (headless and graphical): [shared-session](shared-session.md), [puzzle-session](puzzle-session.md),
[mode-pick](mode-pick.md), [shared-setup](shared-setup.md), [shared-play](shared-play.md),
[shared-result](shared-result.md), [puzzle-play](puzzle-play.md), [controls](controls.md), [navigation](navigation.md),
[exceptions](exceptions.md), [localization](localization.md).

The seven `actors/*-choices`, `*-host` and `*-puzzle` rows belong to `PTU-actors`, which the `playtest.md` index does not
list; they are outside this sweep's eleven UX protocols and are recorded as such in the [summary](../SUMMARY.md).

Runs: [headless](../headless-20261025T230918Z/manifest.md), [graphical](../graphical-20261025T231024Z/manifest.md).
