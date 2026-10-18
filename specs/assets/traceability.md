# Asset Pipeline Traceability

Authoring rules: [`.agents/specs/rules/assets/traceability.md`](../../.agents/specs/rules/assets/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Instant play / Clear board / Cafe calm | vision | [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md), [`sound-effects`](kinds/sound-effects.md), [`music`](kinds/music.md) |
| Shared game + Puzzle stream; no AI opponent art | definition | Hub kinds; content limits via aesthetics |
| No-install browser game (market constraint on licenses) | definition | [`fonts`](kinds/fonts.md) S3 Web-embed license; [`catalog.md`](catalog.md) `CAT.F12` license field |
| Load time; Accessibility; Localization | quality | [`access.md`](access.md) G1 G2; [`fonts`](kinds/fonts.md); piece silhouette checks |
| E-pieces; FRM; PAL; P2 P3 | design / aesthetics | [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md) |
| SND.M1 M2 X1–X5; UI T* I1 F* | aesthetics | [`music`](kinds/music.md), [`sound-effects`](kinds/sound-effects.md), [`interface-art`](kinds/interface-art.md), [`icons`](kinds/icons.md), [`fonts`](kinds/fonts.md) |
| Mode pick; Shared/Puzzle play screens | ux | [`access.md`](access.md) G1 G2; icons / interface |
| Catalog / asset roots | adr | [ADR-0005](../adr/decisions/0005-asset-catalog-roots.md); [`assets.md`](assets.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Asset kinds | [`assets.md`](assets.md), [`kinds/`](kinds/) | Applies |
| AI generation | [`tools.md`](tools.md), [`kinds/`](kinds/) | Applies |
| Procedural generation | [`tools.md`](tools.md), [`kinds/`](kinds/) | N/A — hub Sources |
| Third-party sourcing | [`procedures.md`](procedures.md), [`kinds/fonts.md`](kinds/fonts.md) | Applies |
| Human-made assets | [`procedures.md`](procedures.md), [`catalog.md`](catalog.md) | Applies |
| Tool roles | [`tools.md`](tools.md) | Applies |
| Procedures | [`procedures.md`](procedures.md) | Applies |
| Catalog | [`catalog.md`](catalog.md) | Applies |
| Asset access and load groups | [`access.md`](access.md) | Applies |
| Sound assets | [`sound-effects`](kinds/sound-effects.md), [`music`](kinds/music.md) | Applies |
| Localized assets | [`fonts`](kinds/fonts.md) | Applies — script coverage; no voice locales |
| Accessible variants | [`kinds/`](kinds/) | N/A — shape-led pieces and contrast via palette; no alternate asset set required |
