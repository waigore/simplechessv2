# Sound Style

Authoring rules: [`.agents/specs/rules/aesthetics/sound.md`](../../.agents/specs/rules/aesthetics/sound.md).

- **Serves**: P1, P3; Cafe calm; Instant play; [experience.md](../design/experience.md) sound intent; [view/audio.md](../view/audio.md)

## Music

| ID | Context | Genre and instrumentation | Tempo (BPM) | Mood |
|----|---------|---------------------------|-------------|------|
| M1 | Mode pick and both play loops — Shared game and Puzzle stream (~3 min bed A; [mode pick](../design/flows/mode-pick.md)); first bed when mode pick becomes ready | Soft cafe ambient — acoustic guitar / light jazz; no lyrics | 70–90 | Quiet table; unhurried |
| M2 | Mode pick and both play loops — Shared game and Puzzle stream (~3 min bed B; [mode pick](../design/flows/mode-pick.md)); second bed after M1, then repeats | Same as M1 (shared style) | 70–90 | Same as M1 |

Playlist order and when beds change: [experience.md](../design/experience.md). First music start from the play loop's `play_cue` (BED_M1/M2): [`presentation`](../technical/contracts/presentation.md) E3.

## Sound effects

| ID | Category | Character | Duration range |
|----|----------|-----------|----------------|
| X1 | Touch / select | Wood / tactile tap | 0.05–0.15 s — piece selected ([experience/feedback.md](../design/experience/feedback.md)) |
| X2 | Movement | Soft wood place / settle | 0.08–0.15 s — move completed ([experience/feedback.md](../design/experience/feedback.md)); ends with travel ([PHY.M1](../view/physics.md)) |
| X3 | Impact / check | Short taut cue | 0.10–0.25 s — check ([experience/feedback.md](../design/experience/feedback.md)) |
| X4 | Ability / end | Slightly longer resolved cue | 0.20–0.40 s — checkmate, resign, or clock loss ([experience/feedback.md](../design/experience/feedback.md)) |
| X5 | Interface / puzzle fail | Soft negative tap | 0.08–0.20 s — wrong puzzle move ([experience/feedback.md](../design/experience/feedback.md)) |

- **Draw endings play no end cue** (`D1`–`D5`: [end-conditions/conditions.md](../design/end-conditions/conditions.md)). They satisfy the medium "Draw end" feedback through the `result_draw` copy on the result screen ([shared-result.md](../ux/screens/shared-result.md)). `X4`'s resolved end cue stays for checkmate, resign, and clock loss. Fewest resolved cues, per P3 Cafe calm.
- Sound alone never required for a rules outcome ([experience.md](../design/experience.md)).

## Voice

| ID | Speaker class | Voice kind | Tone |
|----|---------------|------------|------|
| V1 | N/A — no spoken characters | none | — |

## Mix

| ID | Category | Target loudness | Relation to other categories |
|----|----------|-----------------|------------------------------|
| L1 | Music (M1, M2) | −18 LUFS integrated (BS.1770) | Always under SFX; no ducking of moves |
| L2 | Sound effects (X1–X5) | −14 dBTP true peak, measured with a 4× oversampling true-peak meter (ITU-R BS.1770-4) | Above ambient; never gate a local move |
| L3 | Voice | N/A — no voice | — |
