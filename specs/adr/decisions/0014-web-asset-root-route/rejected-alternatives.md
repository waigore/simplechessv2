# ADR-0014: Rejected alternatives

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../../.agents/specs/rules/adr/decision.md).

Split from [ADR-0014](../0014-web-asset-root-route.md) per [`decision.md`](../../../../.agents/specs/rules/adr/decision.md). The route is in that ADR's Decision.

## Context

N/A — the forces are in the parent ADR.

## Purpose

N/A — this file holds the parent ADR's Rejected alternatives only.

## Decision

N/A — see the parent ADR's Decision.

## Reasoning

N/A — see the parent ADR's Reasoning.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Export-preset `include_filter` / `export_files` for `../game_assets/*` | Godot silently drops paths outside the project tree; four filter forms all measured asset-less (#630) |
| Symlink `game/asset_files → ../game_assets` | Still outside the export's file scan; measured asset-less (#630) |
| Serve `game_assets/` beside `build/web/`, no staging | The Pages publish of `build/web/` cannot reach a sibling directory (ADR-0009) |
| Pack the assets into `index.pck` | Needs an import cache for bare SVG/WOFF2/OGG and hides the files the resolver opens by path |
| Move `game_assets/` under `game/` | Changes ADR-0005's roots and every catalog entry path |

## Non-functional requirements

### Quality expectations

N/A — see [`non-functional.md`](non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](non-functional.md).

## Imposes

N/A — see the parent ADR's Imposes.

## Validation

N/A — see the parent ADR's Validation.
