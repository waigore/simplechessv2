# Notes — #334 acceptance, headless run

Build: `origin/main` `d0e827d`, Godot `4.7.2.stable.official.ed1daf0bf`.
Per-criterion derivations and raw output: `criteria.md`, `logs/`.

## What was judged

Every acceptance criterion was re-derived this run on a clean detached worktree.
The implementation and verification comments were not taken as the verdict; the
merged tree and the specs were read directly. All eight pass.

The substance of the leaf is AC5: the completeness gate had been hard-coded, so a
misspelled or removed owner entry could read as a green run. This run reproduced
all four required states by mutation — clean passes, a dropped `zh-Hant` key
fails naming `puzzle-play.<key>`, an `en`-copied varying key fails, and an
`en`-copied marked L3 piece row passes. The gate cannot pass vacuously.

## AC8 — the playtest half, and why it is judged as pass

This is the one criterion that is not a unit-level reading, so the reasoning is
recorded rather than assumed.

The body's `## Preconditions` draws the line itself: the `UI-puzzle-play`
per-locale run, the C4-switch-reads-puzzle-copy check, and the ~40% growth cover
over R2–R3 / S2–S5 "all need that panel. They are **#333's evidence**, not an AC
of this task."

| Evidence on `main` | Covers | Verdict |
|---|---|---|
| `issue-550/headless-20261024T000000Z/` | `PTU-localization` P2 / P5 — copy differs per locale, values not raw keys | pass |
| `issue-550/graphical-20261024T000000Z/` | `PTU-localization` P1 / P2 on the rendered build; screenshots `01`–`03` walk `en` → `zh-Hant` → `ja` on mode-pick | **pass** |

The `puzzle-play` S2/S3 string legs are **not judged** in those runs and this
acceptance does not claim them. The cause is outside this leaf: defect
[#655](https://github.com/waigore/simplechessv2/issues/655) *(open,
`pending-verification`)* means the shipped-path stream deals nothing, so the
graphical run records `04-puzzle-play-entry.png` as "an openable but inert
puzzle-play screen" — with no open attempt there is no puzzle screen state to
list strings on. #550 owns that leg at wave level and is
`status:pending-implementation`.

So every AC this leaf owns is met on evidence in the repo. The `puzzle-play`
screen strings will be read by #333's and #550's runs once #655 clears. This is
not a defect against #334, and no screenshot is owed by it — missing screenshots
alone are not a fail under `accept-project-issue`.

## Non-blocking observations

- `gdscript_tests.py coverage` was not re-measured here: it refuses when
  gdtoolkit is not importable by the script's interpreter in this environment.
  CI's `Coverage` check ran SUCCESS on PR #584's head (`cbff807`), the same tree.
- `spec_lint.py` reports one warning (`specs/view/glossary.md` duplicate
  `Diagram`), pre-existing on `main` and unrelated to this task.
- The unit-test count is 28 on current `main`, up from the 26 the verify pass
  saw; later tasks added tests. The #334 gate itself is unchanged.
