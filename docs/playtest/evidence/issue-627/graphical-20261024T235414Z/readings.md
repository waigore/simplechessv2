# Readings — one line per `SND.*` element

Build: published `69a03d4` (see `manifest.md`). Environment: Chrome 156 phone-viewport
emulation, **no physical speaker**. Outcomes use `specs/playtest/evidence.md`'s
vocabulary: `pass`, `fail`, `not-judged`, `none`.

## Ambience

| Element | Reading | Outcome |
|---|---|---|
| `SND.M1` | The first bed is requested at mode pick, held silent by the browser's autoplay gate, and becomes audible **0.79 s after the first gesture**; the stream is one 180.036 s stereo buffer started once. | `pass` for *starts within one gesture after the first interaction* (AC 2); **not judged for character** (acoustic guitar / light jazz, 70–90 BPM, no lyrics) — no listening occurred. |
| `SND.M2` | Never heard. The bed only advances in `_on_music_finished`, and one bed is 180.036 s, so `M1 → M2` needs an uninterrupted sitting of ≈3 min 0 s that this run did not take. | `not-judged` |
| `SND.M1 → M2 → M1` switch (AC 4) | Not heard; no click/gap judgement possible. | `not-judged` |
| `SND.L1` (−18 LUFS, always under SFX) | No loudness measurement and no listening; the bed does start, which is all this run can say. | `not-judged` |
| `SND.L2` (−14 dBTP, above ambient, never gates a move) | Not judged: no cue was heard, and loudness is out of scope per the issue. | `not-judged` |

## Cues

None of the five cues was reached: a press inside "Shared game" is **delivered and
ignored** on the published build (#879), so no board, puzzle, or result screen was
entered in four sessions on two published shas. Details in `notes.md`.

| Element | Reading | Outcome |
|---|---|---|
| `SND.X1` pick-up | Not reached. Pick-up cue build: `943d5f0` (#570 / PR #684) is in the build under test, so a later run grades it **post-landing**; this run records no pre-landing average. | `not-judged` |
| `SND.X2` place / settle | Not reached. | `not-judged` |
| `SND.X3` check | Not reached. | `not-judged` |
| `SND.X4` end (checkmate, resign, clock loss) | Not reached. | `not-judged` |
| `SND.X5` wrong puzzle move | Not reached (puzzle entry not reached on this build). | `not-judged` |
| Distinguishable from each other (AC 3) | Not judged. | `not-judged` |
| No cue lost, clipped, or doubled (AC 5) | Nothing was heard, so no cue can be called lost; none can be called clean either. No cue defect was filed on this point. | `not-judged` |

## Observation outside the `SND.*` elements

The page creates its `AudioContext` **suspended** and asks for the bed 2.2 s later,
before any gesture. The browser refuses; the bed is queued and starts in the same
call stack that resumes the context after the first gesture. That behaviour is
correct for a phone (autoplay policy respected) — it is recorded because AC 2 asks
for it, not as a defect.
