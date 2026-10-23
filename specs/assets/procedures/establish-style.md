# Establish Style Series

Authoring rules: [`.agents/specs/rules/assets/procedures.md`](../../../.agents/specs/rules/assets/procedures.md).

Part of [`procedures.md`](../procedures.md). Skill: `establish-asset-style`.

## `APR.establish-style`

- **Trigger**: a kind’s Style series is `none`, `bootstrapping`, or `stale`, and the project needs an `active` series for consistent generation.
- **Inputs**: the kind spec (Style series + recipes), cited aesthetics / `REF`s, approved or seed assets, modality tool per [`docs/asset-tools.md`](../../../docs/asset-tools.md) (Recraft for a visual series with a binding; ElevenLabs CLI for music / SFX / voice; none for a soft-enforced kind — SFX, or a third-party/human-made visual kind with no product style id).
- **Pillars**: enforced styling, master/negative `prompt_policy`, review (look or listen) — all three required for identity.

1. Gate: Style series and cited aesthetics hold no undecided placeholders. Confirm **modality** and **enforce**. Set state `bootstrapping` if `none`.
2. If `style_anchors` is empty: bootstrap seed assets via `APR.generate` (bootstrap prompt template + `prompt_policy`) or `APR.register` / human supply; run checks and `APR.review`. Stop until Pass and the user confirms which approved IDs are anchors.
3. Confirm tool terms fit the definition. Create the modality binding:
   - **visual (hard)**: upload anchors; Recraft `create_style`; store `recraft_style_id` + model/base.
   - **visual (soft)**: no Recraft `create_style`; record the approved anchors only. Allowed only when every asset is third-party or human-made and no product style id exists.
   - **music (hard)**: upload anchors; create Music Finetune via the ElevenLabs CLI; store `elevenlabs_finetune_id` + model; set Audio Reference policy.
   - **voice (hard)**: clone or select voice from anchors via the ElevenLabs CLI; store `elevenlabs_voice_id`.
   - **sfx (soft)**: no product style id; record anchors only. Soft enforce stays until a durable binding exists.
4. Write the kind Style series registry: modality, enforce, `style_anchors`, style binding (hard id or `none (soft exemplars)`), `built_from` (anchor IDs + date), `aesthetics` cites, `prompt_policy` if still a fill-in. Set state `active`.
5. On refresh (`stale`): recreate binding from current anchors; replace the stored hard id (or reaffirm the soft anchors); do not keep an old hard id silently, and do not replace a soft binding with a hard id silently. Re-review assets that cited the old id via `APR.update` as needed.

**Outputs**: updated kind Style series section; optional new catalog entries for seeds.
