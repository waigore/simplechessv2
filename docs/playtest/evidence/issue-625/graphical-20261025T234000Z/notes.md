# Notes — #625, `graphical-20261025T234000Z`

## What this run is, and what it is not

This run produced the **build** #625 names (the `Web Release` export of the commit carrying
#647's repair, `491554e`) and read it once on the dev machine. It is **not** the off-device
run #625 asks for. Every row the body names is `not-judged`, and that is the honest outcome:
the acceptance criteria require Performance and Reliability to be read on a phone or a
non-development low-end machine, and to be `not-judged` when only the laptop could read them —
here not even the laptop reading exists, because the only hardware present is the dev machine.

Why the sitting could not be taken: [blockers.md](blockers.md).

## What the run does establish

- The build under test exists, builds clean from `main`, and carries #647's asset root:
  `--check-boot` resolves **14/14** boot assets, `--check-assets` **35/35** cataloged files
  from `build/web/` ([builds.md](builds.md) §2).
- It is the **seam-stripped release scene**: `game/main_release.tscn`, no `PlaytestSeams`
  node, **0** `TEL.*` lines in the console — which is why the correlation key is the export
  path plus the commit sha and no session id exists to record.
- On the dev machine at 390×844 DPR 2 the export reaches mode pick with **no console error**
  ([readings.md](readings.md)). That matches #854's published-`c5b8189` re-read (`#833`'s
  near-invisible focused label is fixed on this build) and is *not* a row verdict.
- The published URL still serves `c5b8189` (26 commits behind `main`); the fallback the body
  defines is therefore the correct build choice, and no `Web release` run id exists for
  `491554e` — a future run that wants the published reading must wait for Pages to serve a
  commit carrying the repair ([builds.md](builds.md) §1).
- **[build-identity.md](build-identity.md) corrects two of those points for the next run**:
  #647's repair *is* an ancestor of `c5b8189`, so a published-URL reading was available on
  2026-10-25; and ADR-0016 (Accepted, 2026-10-25) has since withdrawn the public host entirely —
  the site answers 404 and `Web release` no longer publishes, so the local export is now the
  only source. The rows below are unaffected — there was no device either way.

## Defects

None filed. Nothing failed, because nothing on the required device class was measured. The
gap is the task's own (`funded hardware + a person's sitting`), and attaching a #856-style
load-time finding here would duplicate the open #856 that #854 and #855 already cite.

## Next step for this task

Re-dispatch only where a person with a phone can run it: open
`http://<host>:8625/` (or the published URL once Pages serves the repair) on the phone over
named café Wi-Fi or a hotspot, then walk the four legs in the body. This folder is the
starting point — swap `readings.md` for the device readings and rewrite the four rows.
