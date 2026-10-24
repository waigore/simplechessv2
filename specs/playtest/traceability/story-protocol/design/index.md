# Design story view

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [story-to-protocol map](../../story-protocol.md). 41 rows — one per `## PS<n>:` heading across 41 files, 284 `PS<n>.<m>:` scenarios (40 files carry more than one). A split is its own row.

Design protocols cite element IDs and keys, never `PS` IDs, so a row is judged when its `Spec key`, its [pieces.md ID ranges](../../../../design/entities/pieces.md), or a `Proves` entry is covered by a protocol's **Cites**. Each file below names the element token that covers its rows.

## Files

| File | Rows | Protocols |
|------|------|-----------|
| [shared-game.md](shared-game.md) | 3 | `PTD-shared-game`, `PTD-mode-and-config` |
| [puzzle-stream.md](puzzle-stream.md) | 5 | `PTD-puzzle-stream` |
| [move-advice.md](move-advice.md) | 3 | `PTD-move-advice`, `PTD-mode-and-config` |
| [mode-and-config.md](mode-and-config.md) | 3 | `PTD-mode-and-config` |
| [end-conditions.md](end-conditions.md) | 5 | `PTD-end-conditions` |
| [game-state.md](game-state.md) | 9 | `PTD-game-state` |
| [pieces-common.md](pieces-common.md) | 4 | `PTD-pieces-common` |
| [pieces-king.md](pieces-king.md) | 2 | `PTD-pieces-king` |
| [pieces-officers.md](pieces-officers.md) | 1 | `PTD-pieces-officers` |
| [pieces-pawn.md](pieces-pawn.md) | 1 | `PTD-pieces-pawn` |
| [difficulty.md](difficulty.md) | 3 | `PTD-difficulty`, `PTD-mode-and-config` |
| [progression.md](progression.md) | 2 | `PTD-progression` |

## Row-level `none` — 0

Every design row's `Spec key`, element range, or `Proves` entry is covered by a protocol's **Cites**, so no row carries a linked `type:defect`. `entities/pieces.md#PS1` is judged by `PTD-pieces-common`, which cites `P1`–`P4`, `S1`–`S3`, and `Placement`. The two `F-puzzle-catalog` rows and the `SC-puzzle-stream-visit` row are judged by `PTD-puzzle-stream`, whose **Cites** names both keys ([#702](https://github.com/waigore/simplechessv2/issues/702)). There is no `puzzle-catalog-select.md#PS1`: the file carries only `PS2`.

## Tally

41 rows = **41 judged + 0 `none`**. Splits numbered `PS2` (`common-attack.md`, `puzzle-catalog-select.md`, `progression-mode.md`) are rows in their own right, not additions to a base heading.
