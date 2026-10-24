# Notes — #767 graphical run

**Judge**: acceptance testing for #767, `status:pending-acceptance`, build `origin/main` `41f36e4`.
**Environment**: `ENV.2` graphical, native macOS window at the applied 720 × 1280 frame.
**Scope**: `PTU-shared-play` step S4 against `UI-shared-play.US2.7`.

## What was judged

The same scenario as the headless run, rendered: `White to move` → `1.e4 e5 2.Qh5 Nc6 3.Qxf7+` → `4.Kxf7`.

On the rendered frame at the check, R2 shows the word **Check** inside a chip keylined in `PAL.C8`, and the black King at `e8` carries one `PAL.C8` L-frame — the form `palette/rules.md` K9 reserves for check, distinct from the selection ring, legal-move diamonds, promotion corner brackets, and the refused-place flash. Answering the check removes both. Nothing about the cue depends on audio.

## Outcome

`UI-shared-play.US2.7` — **pass**. Protocol `PTU-shared-play` — **pass** for the S4 read of the check cue.

## The drive's one non-`ok` reading, and why it is not a fail here

The drive also measured `VS2.4b`'s view rule — "the side-to-move indicator is ≥ 1/12 frame height" — and read the `SideToMove` **label** at **82 px** against a floor of **106.7 px** (1280/12) on the applied frame.

That reading is recorded, and it is deliberately **not** treated as a protocol fail:

- `VS2.4b` is a **view** story, and `specs/playtest/playtest.md` puts view stories out of playtest scope. It is not cited by `PTU-shared-play` and is not a row this run judges.
- `US2.7`'s Then clause is "R2 shows the word Check and the PAL.C8 mark". It carries no size clause, and the rendered frame satisfies it in full.
- The same ambiguity was already raised to the tracker during verification: `PER.R6` says "the side-to-move **and check** indicator is ≥ 1/12 frame height" without saying whether the floor binds the word alone, the chip, or the whole status row. This run does not resolve that wording; it records what it measured.

It is not a defect for this task: the label's height is pre-existing chrome, not something the `PER.R6` gap PR introduced, and the check cue itself (chip 52 px; the whole status stack 82 px + 8 px gap + 52 px chip) is at or above the floor as a stack.

## Notes on this run's limits

- **Contrast reading**: 6.39:1 is the theme colour actually applied to the word on this build's chip, above `PER.R6`'s 4.5:1 floor. It is recorded as a reading, not a `quality.md` claim.
- **Repeat count**: one driven cycle per build state (not-in-check → in check → answered). Unlike `SIT.4` timing, no repeat count is required for this judgement.
- **Frame times** were not sampled: `PTU-shared-play` S5/SIT.4 timing is outside this issue's deliverable, and one sample would not be evidence anyway.
- **Audio** was not exercised. `PER.R6` asks for a *non-audio* cue; that was judged from state and colours, so the sound-off/sound-on path is irrelevant here.
- `pocs/shared-game/` was not read as a behavioral source: main code imports nothing from `pocs/` (`grep` → 0), and the run drove `res://main.tscn` only.
