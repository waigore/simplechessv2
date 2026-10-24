# First attempt, and why it is in the folder — issue #616 acceptance run (graphical)

Index: [`manifest.md`](manifest.md) · The judged run: [`run.md`](run.md) · Logs: [`paths.md`](paths.md).

`logs/graphical-drive-first-attempt.log` is the run before the drive was corrected. It read
`RESULT fails=0` and wrote 12 screenshots that were **not evidence**: the shared result's `confirm`
ends the session, and from then on `handle_control` ignores every control (`session_ended`), so the
puzzle legs measured hidden dialogs (which the visibility requirement caught) and the 390×844 frame
never applied (`set_viewport` needs a live tree). Captures were all identical because the capture
buffer lagged the state by one frame.

What the correction changed, in the drive only — no `game/` file was touched:

- a fresh instance per sitting for the legs the ended session could not reach, fitted to the running
  viewport so no resize is re-applied (that would emit `resized` and bypass the `#708` reflow path);
- 20 frames of settle before each capture, plus `tree panel visible=` logged beside each shot;
- every new sitting sets `force_write_failure` deliberately, and the store clears
  it on the attempt. The drive does not reset it afterwards: doing so once left
  the flag latched on a later sitting and failed a commit that was meant to
  succeed, which changed that frame's state mid-pass.

The corrected run is `logs/graphical-drive.log` and the 19 screenshots [`paths.md`](paths.md) lists.
