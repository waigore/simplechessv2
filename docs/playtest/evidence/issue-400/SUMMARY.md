# Sweep summary — #400, full coverage, wave 4

**Build**: `820f202` (the `#846` fix branch tip), `Web Playtest` scene `res://main.tscn`, Godot `4.7.2`. One build across
every run folder: `TEL.3` sessions `sess-1792879521801-55149-playtest-466860` (headless) and
`sess-1792879524222-55186-playtest-446768` (graphical).

**Coverage mode**: `full` — the 23 protocols of `specs/playtest/playtest.md` §Index (12 design headless, 11 UX headless
and graphical), judged against the story-to-protocol map.

**Runs**: [`headless-20261025T230918Z/`](headless-20261025T230918Z/manifest.md) (all protocols and rows) and
[`graphical-20261025T231024Z/`](graphical-20261025T231024Z/manifest.md) (the UX display rows and screenshots). Method:
[notes.md](notes.md).

## Verdicts

**Headless**: 11 pass, 12 `not-judged` over the 23 protocols. Pass: `PTD-puzzle-stream`, `PTD-move-advice`,
`PTD-game-state`, `PTD-difficulty`, `PTD-progression`, `PTU-shared-session`, `PTU-puzzle-session`, `PTU-mode-pick`,
`PTU-shared-setup`, `PTU-shared-result`, `PTU-navigation`. Every other protocol carries at least one `not-judged` row,
named in its [`rows-<protocol>.md`](headless-20261025T230918Z/manifest.md).

**Graphical**: the display rows of `PTU-localization` and `PTU-controls` **pass**; `PTU-shared-play` stays
`not-judged` (`UI-shared-play.US3.13` has no reachable last-rank pawn). Every other graphical verdict is `not-judged`
because the run did not re-judge those rows on the display. Per-protocol rows and counts: both manifests.

## Row counts

**Design 41 rows** — 32 pass, 9 `not-judged`. **UX 26 rows** — 25 pass, 6 `not-judged`, 1 `none`.

The `none` is the map's and is never recorded `not-judged`: `localization.md#US2` (`none — LOC.US2 is out of playtest
scope; judged by spec read`, [#788](https://github.com/waigore/simplechessv2/issues/788)). Design row-level `none` is 0
on the map, so the four design rows the issue body names as `none` are judged here.

## Defects

**None.** No protocol failed, so no `type:defect` was filed (AC7); `#846` does not reproduce on `820f202`.

## Acceptance

The runs are complete deliverables. The sweep is not accepted while a **judged** row is `not-judged`: 15 exist, so the
next `accept-project-issue` pass judges them again on a build that can enter those positions. A `none` row does not
hold acceptance.
