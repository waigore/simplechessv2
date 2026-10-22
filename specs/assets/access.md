# Asset Access

Authoring rules: [`.agents/specs/rules/assets/access.md`](../../.agents/specs/rules/assets/access.md).

- **Serves**: Instant play; Load time (board playable ≤ 3 s); Clear board; Cafe calm; Localization; [mode-pick](../ux/screens/mode-pick.md); Shared/Puzzle play screens
- **Technical counterpart**: [`specs/technical/asset-access.md`](../technical/asset-access.md)

## Addressing

| ID | Rule |
|----|------|
| A1 | Code and data name an asset only by its asset ID, never by file path or handle. |
| A2 | An asset manifest generated from the catalog ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md)), never hand-edited, maps each asset ID to its files. The asset manifest main code uses lists only approved entries. |
| A3 | **Development / playtest**: unresolved ID (unknown, draft, or deprecated) fails loud — log the ID and show the playtest debug overlay when that build has one (Observability). **Release**: do not draw that asset; keep the sitting playable and log once (Instant play, Reliability). |

## Placement

| ID | Rule |
|----|------|
| P1 | The asset root ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md)) holds only cataloged asset files and the engine's import sidecars. |
| P2 | Engine resources and build outputs live outside the asset root (ADR-0005), are not cataloged, and are listed in the technical counterpart. |

## Load groups

| ID | Group | Members | Load point | Unload point | Serves |
|----|-------|---------|------------|--------------|--------|
| G1 | Boot | [`fonts`](kinds/fonts.md), [`interface-art`](kinds/interface-art.md), [`icons`](kinds/icons.md) | Cold open / mode pick (`EX.loading` → ready) | Never in a sitting | Load time; [mode-pick](../ux/screens/mode-pick.md) |
| G2 | Play | [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md), [`sound-effects`](kinds/sound-effects.md) | First enter Shared play or Puzzle play | Never in a sitting | Instant play; Clear board; [SND.X*](../aesthetics/sound.md) |
| G3 | Ambient | [`music`](kinds/music.md) | Mode pick becomes ready (`EX.loading` → ready; [mode-pick](../ux/screens/mode-pick.md)); [SND.M1](../aesthetics/sound.md) | Never in a sitting | Load time; Cafe calm; [SND.M1](../aesthetics/sound.md); [experience.md](../design/experience.md) playlist |
