# Story-to-protocol map

Authoring rules: [`.agents/specs/rules/playtest/traceability.md`](../../../.agents/specs/rules/playtest/traceability.md).

Index over which protocol judges which story row. [Procedures](../procedures.md) step 2 maps an issue to stories and step 4 judges each cited story; this map names the rows, their judging protocols, and the rows no protocol reaches.

## Rule this map applies

No story-row rule exists under `specs/playtest/` yet. [#660](https://github.com/waigore/simplechessv2/issues/660) owns it and lands it in one place, with [procedures](../procedures.md) steps 2 and 4 citing that place and [evidence](../evidence.md) gaining a verdict for a story no protocol reaches. **This map states no rule of its own.** The rules below are that defect's intended shape, recorded per issue [#481](https://github.com/waigore/simplechessv2/issues/481), and are restated against the landing when it lands.

- **Row unit**: one row per story heading, never per file — `<file>#US<n>` or `<file>#PS<n>`.
- **UX judge rule**: a protocol judges a UX row when its **Cites** names that row's story ID; a journey key judges the journey row. Steps only record which scenarios run.
- **Design judge rule**: a protocol judges a design row when its **Cites** covers an element the row proves **and** that element belongs to the row's `Spec key`. Element IDs repeat across keys, so a cross-key cite never covers a row. A key-level cite (`GS`, `CFG`, `PRG`, `DIF`) covers every element of that key.
- **`none`**: `none — <reason>` plus a linked defect, for a row no protocol judges and for a scenario no step reaches.

## Views

| View | Rows | Lists |
|------|------|-------|
| [UX story view](story-protocol/ux.md) | 32 | Every non-journey UX heading, its protocols, reached and unreached scenarios |
| [Journey and actor view](story-protocol/journeys-actors.md) | 11 | The 2 journey rows, the 9 actor rows, and how a bare journey key resolves |
| [Design story view](story-protocol/design/index.md) | 41 | Every design heading, its `Spec key`, element range, protocols |
| [Protocol view](story-protocol/protocols.md) | 23 | Each protocol and the rows it judges, split by level |

## Split rules

- **UX**: a story-ID cite reaches every file carrying that heading — `UI-mode-pick.US1` covers `screens/mode-pick.md#US1` and `screens/mode-pick-unavailable.md#US1`. No protocol cites a scenario ID today, so a scenario-level split case does not apply; one would reach only its own file.
- **Design**: each `## PS<n>` heading is its own row, including the three splits continuing at `PS2` (`common-attack.md`, `puzzle-catalog-select.md`, `progression-mode.md`). Within `E-pieces`, [pieces.md](../../design/entities/pieces.md) assigns each `I` range to its owning split.

## Tally

| Level | Rows | Judged | `none` |
|-------|------|--------|--------|
| UX | 34 (32 non-journey + 2 journey) | 19 | 15 |
| Design | 41 | 37 | 4 |
| **Total** | **75** | **56** | **19** |

No row is `out`. Scenario-cell `none` is counted apart from row-level `none`.

## Worked row

`stories/controls-drag.md#US2` (`IN.US2`, `US2.1`–`US2.4`, Full) → [controls](../ux/controls.md) **Cites** `IN.US2` → judged, all four scenarios reached.

## Downstream

[coverage](../coverage.md) intersects this row set with issue scope in [procedures](../procedures.md) step 3. The per-protocol story lists in the [protocol view](story-protocol/protocols.md) are what the wave sweeps copy.
