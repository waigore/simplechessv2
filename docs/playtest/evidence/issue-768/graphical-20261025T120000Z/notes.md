# Notes — #768 acceptance playtest

## Independence

This session did not write #768's code. It reads `origin/main` `c4202bb` in a clean
worktree and drives the shipped scene. The branch this run ships carries this evidence
only.

## How the run drove the screen

- **Entry and leave** through the shipped controls: `mode-pick` `C2` and
  `puzzle-play` `C3` / `C4` / `C5` / `confirm`.
- **Moves** through `SessionRouter.handle_input_commit()` (select, then place) — the
  same gesture path the board uses.
- **The deal** through the production stream: `PuzzleStream.request()` →
  `CatalogDealClient` → `Accept768CatalogPeer` → `PuzzleStream.poll()` →
  `PuzzleSession.deal()`. Earlier puzzle evidence injected records with
  `deal([...])`; this run does not, so S4's `recent_solved` and S5's widen are
  observed on a real catalog read.
- **The peer** answers every read from a queue, and holds a read open when the queue
  is empty — that open read is the X2 case. It carries `recent_solved` from the O1
  message, so S4 checks what the session *asked for*, not only what came back.
- **The persisted document** is `PersistStore.memory_backend`, the store's own path.

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
probe confirmed at shot time that the panel held `cue_key=cue_solved`, the
`ResultCue` label read `Solved`, was visible in the tree, and measured 99×48 at
(711, 12). The same mechanism paints where the cue persists — `s7-wrong-move-reset.png`
shows `Wrong move` and `s10-end-l4.png` shows `Failed` beside the Elo, both legibly.

The cue's *form and legibility* are covered by `game/puzzle_play_test.gd` and were
judged graphically for #333. Nothing new about the cue's appearance was concluded from
these two images.

## Deal order under S4

S4's step asks that a solved id inside `CFG.ELO_RECENT_WINDOW` is not dealt. The run
checks both halves: the O1 request the session sent carries the solved id in
`recent_solved`, and `PuzzleProgression.candidate_set` — the function `deal()` itself
calls, at the session's live Elo and recent list — returns only the unsolved member.
One offer in this run (`accept768-s1`) was already solved, so it is skipped, as `I1`
requires.

## Not judged

- Every Design protocol other than `PTD-puzzle-stream` and `PTD-difficulty`, and every
  UX protocol: out of scope for this task (`not-judged`).
- `SIT.4` timing: not measured by this run.
- The web build: this run is the native scene graph, not the exported Web build.
