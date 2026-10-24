# Asset Tools

Authoring rules: [`.agents/specs/rules/assets/tools.md`](../../.agents/specs/rules/assets/tools.md).

## Tool roles

| ID | Role | Source type | Kinds served | Required capabilities | Realized by |
|----|------|-------------|--------------|-----------------------|-------------|
| TL.1 | Visual generation | AI generation | [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md), [`interface-art`](kinds/interface-art.md), [`icons`](kinds/icons.md) | Fixed square canvas with alpha outside the body ([AK-piece-sprites.S1](kinds/piece-sprites.md), [AK-piece-sprites.S2](kinds/piece-sprites.md)); opaque body at its [FRM.P2](../aesthetics/form.md) height ([AK-piece-sprites.S3](kinds/piece-sprites.md)); board-aspect canvas with no piece art ([AK-board-backgrounds.S3](kinds/board-backgrounds.md), [AK-board-backgrounds.S4](kinds/board-backgrounds.md)); panel alpha and no baked-in copy ([AK-interface-art.S2](kinds/interface-art.md), [AK-interface-art.S3](kinds/interface-art.md)); 24×24 icon grid ([AK-icons.S1](kinds/icons.md)); Recraft `create_style` / `input_style_id` for [AK-piece-sprites.SS1](kinds/piece-sprites.md) [AK-board-backgrounds.SS1](kinds/board-backgrounds.md) [AK-interface-art.SS1](kinds/interface-art.md) [AK-icons.SS1](kinds/icons.md); palette-aware fills ([PAL.S3](../aesthetics/palette.md), [AES.P3](../aesthetics/aesthetics.md)) | ADR-free — Recraft per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.2 | Sound-effect generation | AI generation | [`sound-effects`](kinds/sound-effects.md) | Short cues within the per-cue ranges ([AK-sound-effects.S1](kinds/sound-effects.md)); wood / tactile character that never gates a move ([AK-sound-effects.S2](kinds/sound-effects.md), [AES.P1](../aesthetics/aesthetics.md)); OGG output ([AK-sound-effects.S4](kinds/sound-effects.md)); soft style via anchors for [AK-sound-effects.SS1](kinds/sound-effects.md) | ADR-free — ElevenLabs CLI per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.3 | Music generation | AI generation | [`music`](kinds/music.md) | Continuous 150–210 s bed, not a loop ([AK-music.S4](kinds/music.md)); cafe ambient genre from [SND.M1](../aesthetics/sound.md) [SND.M2](../aesthetics/sound.md) ([AK-music.S1](kinds/music.md)); loudness toward [SND.L1](../aesthetics/sound.md) ([AK-music.S3](kinds/music.md)); finetune / Audio Reference for [AK-music.SS1](kinds/music.md) | ADR-free — ElevenLabs CLI per [`docs/asset-tools.md`](../../docs/asset-tools.md) |

Fonts use third-party or human-made sources only (no generate role).

## Access

| Role | Access | Run by | Cost or quota limit |
|------|--------|--------|---------------------|
| TL.1 | Recraft MCP / agent tool (credentials outside repo) | Agent | Account quota; stop on limit |
| TL.2 | ElevenLabs CLI (`ELEVENLABS_API_KEY` in environment; no MCP) | Agent | Account quota; stop on limit |
| TL.3 | ElevenLabs CLI (`ELEVENLABS_API_KEY` in environment; no MCP) | Agent | Account quota; stop on limit |

Credentials never enter the repository.

## Constraints on ADR

Every role a recipe uses needs an Accepted Integration ADR that realizes all of its required capabilities, **or** realization by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) marks ADR-free (today: Recraft for visual style series and preferred visual design; Cheaper Inference for non-series visual generate / reference-anchor; Poly Haven for third-party texture/model catalog import; ElevenLabs CLI for music / SFX / voice). Until then the role is Pending and its recipes do not run. An ADR that changes a role reopens every recipe that uses it for review.

Style-series establish and style-constrained generate require the modality style-binding capability: visual with a binding → Recraft; music / voice → ElevenLabs CLI (both ADR-free) per that doc. A soft-enforced kind (SFX, or a third-party/human-made visual kind with no product style id) needs no tool style-binding capability — anchors plus review carry the series. Fonts use import/register only. Cheaper Inference and Poly Haven must not realize those capabilities. Touch-ups ([`APR.touch-up`](procedures/touch-up.md)) are not tool roles and need no ADR. No role is realized by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) bans. This project does not use fal for visual generation ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md)).
