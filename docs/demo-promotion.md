# Demo promotion

Main-code work waits on this gate. [`require-demo-promotion`](../.agents/skills/require-demo-promotion/SKILL.md) applies it. Do not add gates.

## Gate

- At least one demo exists under `demos/`. Its scope may be as small as the owner chooses.
- Every demo under `demos/` has a completed promotion act in its README. A demo added later blocks further main-code work until its act is done. A completed act is not walked again.
- The act walks each included element, default keep. The user may drop any, including all. Drops stay in the demo and are recorded.
- A kept decision that disagrees with another demo or with the current spec stops for the user. The user picks the behavior. It is written into `specs/`. A losing decision is not promoted. Demo behavior is left as it was.
- The act is complete only after any spec PR from those choices has merged.

The README records the act: each included element is keep or drop, plus any conflict choice, and whether the act is complete.

## Reimplementation

A non-empty keep list is reimplemented by [`promote-gameplay-demo`](../.agents/skills/promote-gameplay-demo/SKILL.md), one demo per task. An empty list completes the act and does not start that skill.

That reimplementation writes every assumption it relies on into `specs/`, confirmed by the user; adds the technical design the code needs; approves every draft asset it uses; and passes `review-code` and the normal test bar. Main code never imports from `demos/`. The demo folder stays as it was.
