# Asset Update

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md).

## `APR.update`

- **Trigger**: a fail, changed aesthetics/recipe/tool role/style series, or a request.
- **Inputs**: the catalog entry and its files, the kind spec and recipe, the prior prompt and `generation`, and the current Style series.

1. Keep the asset ID; raise version; record the reason. Append `history` with the prior generation (and touch-ups added) before overwrite.
2. Prefer the prior prompt as a guide; keep series style when `active` (Recraft or ElevenLabs CLI per modality). Regenerate or edit per recipe; audio re-runs mix post-process to `SND.L1` (music) or `SND.L2` (sound effects). Checks and `APR.review`.
3. Re-check assets built from this one.

**Outputs**: same asset ID at a raised version with `history` appended; regenerated files; `APR.review` verdict; dependents re-checked.
