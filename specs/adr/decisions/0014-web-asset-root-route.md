# ADR-0014: Asset root route into the Web build

Authoring rules: [`.agents/specs/rules/adr/decision.md`](../../../.agents/specs/rules/adr/decision.md).

- **Status**: Accepted
- **Date**: 2026-10-24
- **Category**: Integration
- **Supersedes**: None
- **Informed by**: Web platform (definition); Load time, Reliability, Observability (quality); ADR-0001, 0005, 0007, 0009

## Context

ADR-0005 puts the asset root at the repo root (`game_assets/`) beside the project `game/`; ADR-0007 puts the export at `build/web/`. Neither records how the root reaches the browser. Godot 4.7.2 exports only the project tree, so the build ships no asset file and `EX.loading` never ends (#630).

## Purpose

How does the repo-root asset root reach a shipped Web build, and what proves it did?

In scope: the export step, shipped location, Web read path. Out of scope: roots, output dir, publish path.

## Decision

- **Route**: the export stages `game_assets/` and `audio_runtime/` as `game/<root>/`, exports, then deletes them.
- **Shipped location**: the staged copies are exported like any project file — packed into `build/web/index.pck` under `res://game_assets/…` and `res://audio_runtime/…`. Measured: 35/35 cataloged loadable files, 15 audio copies present.
- **Resolver**: on Web it reads `res://<asset_root>/…` and `res://audio_runtime/<asset ID>.ogg`; elsewhere the repo-root read stays. Names come from the manifest and the resolver constant.
- **Boundary**: `game_assets/` is the only source; `game/<root>/` is generated, never committed.
- **Check**: a Web export fails when the tree carries no cataloged loadable file, only some of them, or no audio copy (`--check-assets`), run by `web-release.yml`.
- **Open**: presence is not readability. Measured on a served export (headless Chrome, 390×844): `Image.load` and `FontFile.load_dynamic_font` on `res://game_assets/…` both fail (`Error opening file`), and Boot leaves 9 IDs unresolved. The read must become HTTP-fetched bytes or imported resources; this ADR records presence only.

## Reasoning

1. Only the project tree is exportable; staging is the minimal in-tree step.
2. ADR-0005 keeps the root at the repo root, so the export copies and discards.
3. Only the export sees `build/web/` after the engine writes it (Observability, Reliability).

Costs: several MB per export; a larger `index.pck`; exporting outside the script skips staging; presence is not yet readability.

## Rejected alternatives

Moved to [`rejected-alternatives.md`](0014-web-asset-root-route/rejected-alternatives.md): five measured or rejected routes.

## Non-functional requirements

### Quality expectations

N/A — see [`non-functional.md`](0014-web-asset-root-route/non-functional.md).

### Engineering qualities

N/A — see [`non-functional.md`](0014-web-asset-root-route/non-functional.md).

## Imposes

| Spec or element | Constraint |
|-----------------|------------|
| `specs/technical/asset-access.md` `AST.R2`, `AST.G1`–`G3` | A preload group resolves from the shipped tree on Web; none waits on an asset the build lacks |
| `specs/technical/components/asset-resolver.md` `R1` | Read path is platform-dependent: `res://<asset_root>/…` on Web, repo root elsewhere |
| `specs/technical/contracts/asset-resolve.md` `O1` | Resolve reads the path the shipped tree carries; E4 covers failure |

## Validation

| Check | Method | When |
|-------|--------|------|
| Shipped tree carries the root and audio copies | `--check-assets` in `web-release.yml`; `test_web_export.py` red/green | Every release |
| Staged copies never committed | `.gitignore` review; the staging test | Every release |
| Build reaches mode pick on the published URL | #630 steps: `Preload boot left 0 approved IDs unresolved` | Every release |
