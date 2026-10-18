# Asset Tools

Authoring rules: [`.agents/specs/rules/assets/tools.md`](../../.agents/specs/rules/assets/tools.md).

## Tool roles

| ID | Role | Source type | Kinds served | Required capabilities | Realized by |
|----|------|-------------|--------------|-----------------------|-------------|
| TL.1 | Visual generation | AI generation | [`piece-sprites`](kinds/piece-sprites.md), [`board-backgrounds`](kinds/board-backgrounds.md), [`interface-art`](kinds/interface-art.md), [`icons`](kinds/icons.md) | Transparent or clean vector/PNG; fixed canvas; Recraft `create_style` / `input_style_id`; palette-aware | ADR-free — Recraft per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.2 | Sound-effect generation | AI generation | [`sound-effects`](kinds/sound-effects.md) | Short cues; duration ranges; soft style via anchors | ADR-free — ElevenLabs per [`docs/asset-tools.md`](../../docs/asset-tools.md) |
| TL.3 | Music generation | AI generation | [`music`](kinds/music.md) | Loopable ambient; finetune / Audio Reference; loudness toward [SND.L1](../aesthetics/sound.md) | ADR-free — ElevenLabs per [`docs/asset-tools.md`](../../docs/asset-tools.md) |

Fonts use third-party or human-made sources only (no generate role).

## Access

| Role | Access | Run by | Cost or quota limit |
|------|--------|--------|---------------------|
| TL.1 | Recraft MCP / agent tool (credentials outside repo) | Agent | Account quota; stop on limit |
| TL.2 | ElevenLabs MCP / agent tool | Agent | Account quota; stop on limit |
| TL.3 | ElevenLabs MCP / agent tool | Agent | Account quota; stop on limit |

Credentials never enter the repository.

## Constraints on ADR

Every role a recipe uses needs an Accepted Integration ADR that realizes all of its required capabilities, **or** realization by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) marks ADR-free (today: Recraft for visual; ElevenLabs for music / SFX / voice). Until then the role is Pending and its recipes do not run. An ADR that changes a role reopens every recipe that uses it for review.

Style-series establish and style-constrained generate require the modality style-binding capability: visual → Recraft; music / SFX / voice → ElevenLabs (both ADR-free) per that doc. Touch-ups ([`APR.touch-up`](procedures/touch-up.md)) are not tool roles and need no ADR. No role is realized by a tool that [`docs/asset-tools.md`](../../docs/asset-tools.md) bans. This project does not use fal for visual generation ([ADR-0005](../adr/decisions/0005-asset-catalog-roots.md)).
