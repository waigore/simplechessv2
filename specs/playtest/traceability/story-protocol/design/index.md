# Design story view

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../../../.agents/specs/rules/playtest/traceability.md).

Part of the [story-to-protocol map](../../story-protocol.md). 41 rows — one per `## PS<n>:` heading across 41 files, 284 `PS<n>.<m>:` scenarios (40 files carry more than one). A split is its own row.

Design protocols cite element IDs and keys, never `PS` IDs, so a row is judged when its `Spec key`, its [pieces.md ID ranges](../../../../design/entities/pieces.md), or a `Proves` entry is covered by a protocol's **Cites**. Each file below names the element token that covers its rows.

## Files

| File | Rows | Protocols |
|------|------|-----------|
| [shared-game.md](shared-game.md) | 3 | `PTD-shared-game`, `PTD-mode-and-config` |
| [puzzle-stream.md](puzzle-stream.md) | 2 | `PTD-puzzle-stream` |
| [move-advice.md](move-advice.md) | 3 | `PTD-move-advice`, `PTD-mode-and-config` |
| [mode-and-config.md](mode-and-config.md) | 3 | `PTD-mode-and-config` |
| [end-conditions.md](end-conditions.md) | 5 | `PTD-end-conditions` |
| [game-state.md](game-state.md) | 9 | `PTD-game-state` |
| [pieces-common.md](pieces-common.md) | 3 | `PTD-pieces-common` |
| [pieces-king.md](pieces-king.md) | 2 | `PTD-pieces-king` |
| [pieces-officers.md](pieces-officers.md) | 1 | `PTD-pieces-officers` |
| [pieces-pawn.md](pieces-pawn.md) | 1 | `PTD-pieces-pawn` |
| [difficulty.md](difficulty.md) | 3 | `PTD-difficulty`, `PTD-mode-and-config` |
| [progression.md](progression.md) | 2 | `PTD-progression` |

## Row-level `none` — 4

No design protocol's **Cites** covers these rows' `Proves` elements. Each carries a linked `type:defect`.

| Story row | `Spec key` | Reason | Defect |
|-----------|-----------|--------|--------|
| [`entities/pieces.md#PS1`](../../../../design/stories/entities/pieces.md) | `E-pieces` | `none — proves P1–P4, S1–S3, Placement; no E-pieces cite names them` | [#703](https://github.com/waigore/simplechessv2/issues/703) |
| [`features/puzzle-catalog.md#PS1`](../../../../design/stories/features/puzzle-catalog.md) | `F-puzzle-catalog` | `none — no protocol cites F-puzzle-catalog` | [#702](https://github.com/waigore/simplechessv2/issues/702) |
| [`features/puzzle-catalog-select.md#PS2`](../../../../design/stories/features/puzzle-catalog-select.md) | `F-puzzle-catalog` | `none — no protocol cites F-puzzle-catalog` | [#702](https://github.com/waigore/simplechessv2/issues/702) |
| [`scenarios/puzzle-stream-visit.md#PS1`](../../../../design/stories/scenarios/puzzle-stream-visit.md) | `SC-puzzle-stream-visit` | `none — no protocol cites SC-puzzle-stream-visit` | [#702](https://github.com/waigore/simplechessv2/issues/702) |

`entities/pieces.md#PS1` is the piece **identity and lifecycle** story ([`entities/pieces.md`](../../../../design/entities/pieces.md) `P1`–`P4`, `S1`–`S3`, `Placement`). The four `PTD-pieces-*` protocols cite *move* ranges only — I1–I11, I12–I22, I23–I27, I28–I34 — so nothing covers it. `puzzle-stream.md` cites only `L-puzzle-stream` (K1–K4, E1), `END.L4`, `END.L5`, and `DIF.Y1`, none of which is one of the other three keys. There is no `puzzle-catalog-select.md#PS1`: the file carries only `PS2`.

## Tally

41 rows = **37 judged + 4 `none`**. Splits numbered `PS2` (`common-attack.md`, `puzzle-catalog-select.md`, `progression-mode.md`) are rows in their own right, not additions to a base heading.
