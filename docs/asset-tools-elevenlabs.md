# ElevenLabs (asset tool)

Part of [`asset-tools.md`](asset-tools.md).

Primary audio generation product for music, sound effects, and voice — style-series establish and style-constrained generate for those modalities.

- **ADR**: music, SFX, and voice generation and style series need **no** Integration ADR. Catalog `tool_role.adr` is `adr-free` when ElevenLabs realizes the role.
- **Style series (music)**: `APR.establish-style` uploads anchors and creates a Music Finetune; the kind registry stores `elevenlabs_finetune_id`. Series-active `APR.generate` / `APR.update` must pass that id as `finetune_id`. Optional **Audio Reference** (~30s clip) may accompany a generate when the series policy allows it. Do not invent a parallel style.
- **Style series (voice)**: establish clones or selects a voice from anchors; registry stores `elevenlabs_voice_id`. Series-active generate must pass that `voice_id`.
- **Style series (SFX)**: soft enforce until the product exposes a durable style binding — anchors + `prompt_policy` + listen review; no finetune/reference id required. Full series generate still requires Style series `active`.
- **Options**: before choosing an operation, read ElevenLabs docs (Music, Sound Effects, Voices) and the connected MCP tool list.
- **Access**: hosted MCP `https://api.elevenlabs.io/v1/mcp`, OAuth on first use, no API key in-repo. Usage billed to the signer. If MCP lacks an operation, a person runs it in the web app or via SDK with `ELEVENLABS_API_KEY` outside the repo; record them as `run_by`.
- **Terms**: confirm rights fit the definition's market constraints; only upload copyright-compliant anchors; record in `terms` / generation license fields.
- **Fit**: loudness, duration, and loop must match kind specs citing `SND.L` / `SND.X` / `SND.M`. Rerun kind checks after generation. If there is no native negative channel, append avoid-clauses from `prompt_policy` into the prompt; still record `negative_prompt` source clauses in the catalog.
