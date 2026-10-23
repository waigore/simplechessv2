# Quality Regression Owners

Authoring rules: [`.agents/specs/rules/quality.md`](../../.agents/specs/rules/quality.md). Targets and methods: [`quality.md`](quality.md).

A row that fails on the shipped build is filed as a `type:defect` against the wave epic below; it is never fixed inside the release gate that found it.

| Category | Owning epic |
|----------|-------------|
| Performance | #34 Shared game — a move-path hitch is [`CMP-presentation`](../technical/components/presentation.md) R5 with the session's move handling |
| Load time / latency — board playable on cold open | #34 Shared game — the board is reachable from the first screen ([`CMP-session-router`](../technical/components/session-router.md)) |
| Load time / latency — advice ready | #36 Advice |
| Reliability — sitting soak | #34 Shared game and #35 Puzzle stream — whichever screen was running when it failed |
| Reliability — reopen at mode pick with committed Player Elo and Last mode | #35 Puzzle stream — the last commit is a puzzle result ([`CMP-persist-store`](../technical/components/persist-store.md), [`CMP-session-router`](../technical/components/session-router.md)) |
| Observability | #37 Release — logging and story-ID overlay span every screen (ADR-0004) |
| Save durability | #35 Puzzle stream — the commit path is the puzzle result; a shared-game sitting writes nothing |
| Accessibility — piece readability and no color-only information | #34 Shared game — pieces render on the shared board ([`PAL`](../aesthetics/palette.md) K1 K2) |
| Accessibility — legibility at the smallest text size | #37 Release — it covers every screen at every locale |
| Localization | #34 Shared game and #35 Puzzle stream for screen copy; #37 Release for the string-table gate and locale coverage |
