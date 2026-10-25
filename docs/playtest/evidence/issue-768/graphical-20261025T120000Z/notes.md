# Notes — #768 acceptance playtest

## Independence

This session did not write #768's code. It reads `origin/main` `c4202bb` in a clean
worktree and drives the shipped scene. The branch this run ships carries this evidence
only.

## How the run drove the screen

Entry, leave, moves, the deal, the peer, and the persisted document: see `drive.md`.

## What the checks showed

`logs/headless-run.log` and `logs/graphical-run.log`: **70 `CHECK PASS`, 0 `CHECK
FAIL`, `FAILURES=[]`** in each. Three further headless repeats
(`logs/headless-repeat-run-{1,2,3}.log`) are also 70/0; the deal picks a member of the
winning rung with `randi()`, so repeats matter.

The two protocols are Design and headless-only. The graphical leg is the same build
driven the same way, and is the source of `screenshots/`.

## Reading an ending from the shipped scene

Three things happen inside one judged place: the attempt settles
(`last_result`), the R2 cue is painted, and `advance()` raises the K3 read that drops
the attempt. So an ending is read as:

- `last_result` — `PuzzleSession.last_result`;
- the cue — the `cue_key` on the screen the panel painted for the ending;
- `requiredSequence` — the attempt's own sequence, captured while that screen is up.

No product internals were changed to make this readable: `puzzle_play_flow.gd` is
byte-identical to `origin/main`. The only main-tree edit is the 11-line install hook in
`probe/session-router-install-seam.diff`, which sets the existing
`_puzzle_sim_factory()`.

## The solved cue in pixels — recorded honestly

`screenshots/s2-solved-cue.png` and `screenshots/s3-mate-in-one-solved.png` show the
post-solve Elo (1010, and the advanced deal) but **not** the "Solved" cue itself.

That is a capture-timing artifact of this probe, not a finding: the cue is on screen
only inside the ending's own frame, and the K3 deal clears it on the next tick. The
probe confirmed at shot time that the panel held `cue_key=cue_solved` with the
`ResultCue` label reading `Solved` at 99×48. The same mechanism paints where the cue
persists — `s7-wrong-move-reset.png` shows `Wrong move`, `s10-end-l4.png` shows `Failed`.

The cue's *form and legibility* are covered by `game/puzzle_play_test.gd` and were
judged graphically for #333. Nothing new about the cue's appearance was concluded from
these two images.

## Not judged

- Every Design protocol other than `PTD-puzzle-stream` and `PTD-difficulty`, and every
  UX protocol: out of scope for this task (`not-judged`).
- `SIT.4` timing: not measured by this run.
- The web build: this run is the native scene graph, not the exported Web build.
