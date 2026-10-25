# Notes — #767 headless run

**Judge**: acceptance testing for #767, `status:pending-acceptance`, build `origin/main` `41f36e4`.
**Environment**: `ENV.1` headless, no display.
**Scope**: `PTU-shared-play` step S4 against `UI-shared-play.US2.7` — the check cue this task's single gap row built.

## What was judged

Untimed Shared game entered by the player-facing controls (`mode-pick` C1 → `shared-setup` C5). The seats were driven through `SessionRouter.handle_input_commit` — the same path board input takes — to `1.e4 e5 2.Qh5 Nc6 3.Qxf7+`, which puts White's check on Black's King, then `4.Kxf7` answers it.

`US2.7` reads: "R2 shows the word Check and the PAL.C8 mark." All three parts were observed in production state:

1. **The word** — the `CheckCue` label carries the localized `check` key (`StringTable.shared_play("check","en")` → `Check`), not hard-coded English (A1's localization path).
2. **The PAL.C8 mark in R2** — the `CheckChip` keyline is `#C28A86`, i.e. `CheckMarks.COLOR_CHECK` = `PAL.C8`, at 4 px (≥ UIS.I1 1.5 px).
3. **The PAL.C8 mark on the board** — `CheckMarks` puts two L-frames on `e8`, the black King's square, in `PAL.C8`, 4.32 screen px wide.

Both cues clear when the check is answered and are absent beforehand, so the cue tracks the rules outcome rather than a stale flag.

## Outcome

`UI-shared-play.US2.7` — **pass**. Protocol `PTU-shared-play` — **pass** for the S4 read of the check cue.

## Blockers

None.

## Notes on this run's limits

- **Screenshots** are not in this folder by design: a headless session has no framebuffer. The graphical run of the same build (`../graphical-20261025T221000Z/`) writes them, and acceptance cites that folder for images.
- **Contrast 6.39:1** is recorded as a reading, not a `quality.md` claim. It differs from the 12.73:1 the delivering PRs quoted because this run reads the theme colour actually applied to the label in this build; both are above `PER.R6`'s 4.5:1 floor.
- **`VS2.4` / `VS2.4b` are view stories**, out of playtest scope. The runs read them only to corroborate `US2.7`; they are not judged here and no verdict is claimed for them.
- **The 1/12 frame-height half of `PER.R6`** is not part of `US2.7`'s Then clause. See the graphical run's notes for the reading taken there.
- No audio was involved: `PER.R6` requires the cue be non-audio, and the run asserts the cue from state and colours only, with the sound path untouched.
