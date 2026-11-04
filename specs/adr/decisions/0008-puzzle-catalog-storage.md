# ADR-0008: Host-side Lichess puzzle catalog

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-21
- **Category**: Data storage
- **Supersedes**: None
- **Informed by**: Cafe calm (vision); Puzzle stream and no-install Web (definition); load time and performance (quality); [DIF.Y1](../../design/difficulty.md); `GS.recentSolved` ([PRG](../../design/progression.md)); [F-puzzle-catalog](../../design/features/puzzle-catalog.md)

## Context

Puzzle stream deals from a catalog. The owner chose the Lichess puzzle export of 2026-10-05 (6,157,341 rated, tagged puzzles), CC0, kept off the client. PuzzleIds in `GS.recentSolved` must stay meaningful. The raw dump must not be anonymously fetchable.

## Purpose

Where does the puzzle catalog live, and how may the client read it?

In scope: dataset, license, host storage, snapshot date, and anonymous access to the raw export. Out of scope: the Elo formula, session play, and API credentials.

## Decision

The catalog is that Lichess export on the game host as snapshot 2026-10-05, not in the client. Columns are PuzzleId, FEN, Moves, Rating, RatingDeviation, Popularity, NbPlays, Themes, GameUrl, OpeningTags, and DailyDate. `GS.recentSolved` stores PuzzleId from this snapshot. The client uses a secured API only. The raw export is not a public static file.

## Reasoning

1. Load time and the no-install commute keep the export off the client.
2. CC0 fits a browser game with no install.
3. One snapshot keeps PuzzleIds meaningful. [DIF.Y1](../../design/difficulty.md) stays a numeric window, not a band list.
4. A secured API blocks anonymous bulk reads.

Cost: a deal waits on the host.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Bundle the export in the client | Breaks host storage and the cold-open budget |
| In-repo puzzles with Elo bands | Drops the export and invents bands |
| Public static file | Leaves the dump open to abuse |

## Non-functional requirements

Quality and engineering rows: [non-functional requirements](0008-puzzle-catalog-storage/non-functional.md).

### Quality expectations

Performance and load time are Affects. The other categories are No effect. Detail is in the split.

### Engineering qualities

CC0, Web-only, and a secured API read. Detail is in the split.

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| [F-puzzle-catalog](../../design/features/puzzle-catalog.md) | Host snapshot, not client bytes; cite this ADR for the export and API |
| [SCH-puzzle-catalog](../../technical/schemata/puzzle-catalog.md) | Record shape and snapshot id follow this export |

## Validation

| Check | Method | When |
|-------|--------|------|
| Bundle omits the export | Review of the Web build | Every release |
| Move frames ignore catalog IO | Frame-time capture during a move | Every release |
| Cold open within 3 seconds | Timed cold open | Every release |
