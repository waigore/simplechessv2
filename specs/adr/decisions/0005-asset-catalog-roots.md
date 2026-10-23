# ADR-0005: Asset catalog and asset roots

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-18
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Asset pipeline Catalog (`catalog.md` Catalog root); Asset pipeline Access (`access.md` A1–A3, G1–G3); Asset pipeline Tools (roles TL.1–TL.3, ADR-free Recraft and ElevenLabs CLI); Load time; Instant play; Reliability; Localization; ADR-0001

## Context

Art and sound need catalog records and importable files without treating entry JSON as Godot resources.

## Purpose

Where do catalog entries and asset files live, and how is the asset manifest produced?

In scope: roots, default entry format, manifest boundary, file kinds, Godot project root for the manifest. Out of scope: recipes.

## Decision

- **Catalog root**: `asset_catalog/` — entry JSON only; never Godot-imported.
- **Asset root**: `game_assets/` — cataloged files + `.import`/`.uid` sidecars; entry paths relative here.
- **Godot project root**: `game/` (repo root sibling of the catalog and asset roots).
- **Formats**: file medium is SVG preferred / PNG alpha for still art, OGG (Ogg Opus, matching `catalog.md` `CAT.I11` duration checks) for audio, and TTF/OTF/WOFF2 for fonts (Web-embed license). The kind specs carry these per kind (`AK-piece-sprites.S2`, `AK-board-backgrounds.S3`, `AK-interface-art.S2`, `AK-icons.S3`, `AK-sound-effects.S4`, `AK-music.S5`, `AK-fonts.S4`); approving a catalog entry with any other medium is a violation.
- **Manifest**: generated from catalog, approved-only, at `game/asset_manifest.json`; committed; regenerate on catalog change (including CI).
- **Tool realization**: tool roles and their realization stay in [`tools.md`](../../assets/tools.md); this ADR sets none. Visual roles stay ADR-free (Recraft per `docs/asset-tools.md`) and audio roles ADR-free (ElevenLabs CLI per that doc). fal realizes no role and is not used for visual generation.

## Reasoning

1. Split JSON catalog from importable files (definition Asset pipeline; Catalog).
2. Repo-root folders work before the Godot scaffold exists (definition Asset pipeline; ADR-0001).
3. Default one-JSON-per-asset keeps PRs safe (Catalog Format; Load time).
4. Roles stay ADR-free and fal realizes none (Tools TL.1–TL.3; Instant play — no visual-generation service sits on the play path).

Costs accepted: repo-root layout constraints; manifest tooling to maintain.

## Rejected alternatives

| Alternative | Why rejected |
|-------------|--------------|
| Catalog under `res://` | Entry JSON would import |
| fal batch images | Recraft only, and fal realizes no tool role |
| Custom catalog DB | Default JSON enough |

## Non-functional requirements

Moved to [`0005-asset-catalog-roots/non-functional.md`](0005-asset-catalog-roots/non-functional.md): quality expectations, including the Reliability sitting-soak how-checked, and engineering qualities.

### Quality expectations

N/A — see the split file above.

### Engineering qualities

N/A — see the split file above.

## Imposes

Moved to [`0005-asset-catalog-roots/imposes-validation.md`](0005-asset-catalog-roots/imposes-validation.md): one row per constrained spec element, including the kind-spec format rows and `tools.md`, which this ADR does not credit with any tool realization.

## Validation

Moved to [`0005-asset-catalog-roots/imposes-validation.md`](0005-asset-catalog-roots/imposes-validation.md): each check, its method, and when it runs, including the sitting soak and the failed-resolve path.
