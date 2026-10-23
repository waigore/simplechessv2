# Asset tools

Known tools for image and audio generation, editing, and touch-up, and the tools this project bans. Specs stay product-neutral: most generation tools realize a tool role in [`specs/assets/tools.md`](../specs/assets/tools.md) through an Accepted Integration ADR. Tools this file marks **ADR-free**, and touch-up options, need no ADR. Touch-ups run through `APR.touch-up` ([`specs/assets/procedures/touch-up.md`](../specs/assets/procedures/touch-up.md)).

**Style series lock**: visual kinds **with a binding** require **Recraft**; music, SFX, and voice kinds require the **ElevenLabs CLI**. A soft-enforced third-party/human-made visual kind with no product style id needs no tool binding — anchors plus review carry the series.

## Banned tools

| Tool | Scope |
|------|-------|
| Pixellab | Never used for anything. Agents do not call it, even when its MCP server is connected. No Integration ADR may name it. `register-asset` refuses assets made or edited with it. CI rejects catalog entries whose generation or touch-up tool names it. |

## Preference

| Situation | Prefer |
|-----------|--------|
| Visual style establish (`create_style`) or style-constrained generate (`input_style_id`) | Recraft (required) |
| Audio style establish (finetune / voice) or style-constrained music/voice/SFX generate | ElevenLabs CLI (required) |
| Exploratory image work, editing, graphic design, vector art | Recraft |
| Default when Recraft can do the job | Recraft |
| High-throughput batch image generation (expect Recraft touch-up after); visual series not `active` | fal.ai |
| Specific image model Recraft lacks; visual series not `active` | fal.ai |

## Generation and design

- **Recraft**: [`asset-tools-recraft.md`](asset-tools-recraft.md) (ADR-free; required for visual style series).
- **ElevenLabs**: [`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md) (ADR-free; CLI only; required for audio style series).
- **fal.ai**: [`asset-tools-fal.md`](asset-tools-fal.md) (needs Integration ADR; not for active style series).

## Touch-up

A touch-up is an optional edit to an asset's files that brings it closer to its kind spec, aesthetics, or a quality target. It never replaces a recipe. Record in `touchups` (`CAT.F19`); source type and series binding stay. Recraft is the visual touch-up option ([`asset-tools-recraft.md`](asset-tools-recraft.md)). Audio post-steps (trim, loudness) stay in the kind recipe's post-processing unless a later tool doc adds an audio touch-up option.

## Enabling tools

- **Recraft / fal**: MCP servers `recraft` and `fal` ship disabled. Enable locally per [`mcp.md`](mcp.md); use `setup-project-mcp`. Do not commit enabled state.
- **ElevenLabs**: CLI only ([`asset-tools-elevenlabs.md`](asset-tools-elevenlabs.md)). No MCP server. Assume `ELEVENLABS_API_KEY` is in the environment.
