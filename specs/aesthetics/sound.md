# Sound Style

Authoring rules: [`.agents/specs/rules/aesthetics/sound.md`](../../.agents/specs/rules/aesthetics/sound.md).

- **Serves**: P1, P3; Cafe calm; Instant play; [experience.md](../design/experience.md) sound intent; [view/audio.md](../view/audio.md)

## Music

| ID | Context | Genre and instrumentation | Tempo (BPM) | Mood |
|----|---------|---------------------------|-------------|------|
| M1 | All play and mode pick | Soft cafe ambient — acoustic guitar / light jazz; no lyrics | 70–90 | Quiet table; unhurried |

## Sound effects

| ID | Category | Character | Duration range |
|----|----------|-----------|----------------|
| X1 | Touch / select | Wood / tactile tap | 0.05–0.15 s — piece selected ([experience/feedback.md](../design/experience/feedback.md)) |
| X2 | Movement | Soft wood place / settle | 0.08–0.20 s — move completed; ends with travel ([PHY.M1](../view/physics.md)) |
| X3 | Impact / check | Short taut cue | 0.10–0.25 s — check |
| X4 | Ability / end | Slightly longer resolved cue | 0.20–0.40 s — checkmate, resign, or clock loss |
| X5 | Interface / puzzle fail | Soft negative tap | 0.08–0.20 s — wrong puzzle move |

Sound alone never required for a rules outcome ([experience.md](../design/experience.md)).

## Voice

| ID | Speaker class | Voice kind | Tone |
|----|---------------|------------|------|
| V1 | N/A — no spoken characters | none | — |

## Mix

| ID | Category | Target loudness | Relation to other categories |
|----|----------|-----------------|------------------------------|
| L1 | Music (M1) | About −18 LUFS integrated | Always under SFX; no ducking of moves |
| L2 | Sound effects (X1–X5) | About −14 LUFS for peaks of short cues | Above ambient; never gate a local move |
| L3 | Voice | N/A — no voice | — |
