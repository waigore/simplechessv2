# Build observations — #557 graphical run `20261024T204223Z`

The issue's central rule is that this run is measured on the **published release build**, and that a local export is never recorded as the shipped build. This file states how the recorded commit was established, and what the build did that this task does not judge.

## Which commit did the published URL serve?

| Check | Value |
|---|---|
| URL | `https://waigore.github.io/simplechessv2/` |
| HTTP status at run time | `200` (`index.js`, `index.wasm`, `index.pck` all `200`) |
| Recorded commit | `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96` |
| Establishing `Web release` run | [`40118381611`](https://github.com/waigore/simplechessv2/actions/runs/40118381611) — `conclusion: success`, head `c5b8189`, created 2026-10-24T17:56:09Z |
| `github-pages` deployment | id `7302318984`, sha `c5b8189`, status `success`, created 2026-10-24T17:57:13Z, environment URL the published URL |
| Response `last-modified` | 2026-10-24T17:57:05Z, consistent with that deployment |

The commit was read from the deployment that served the URL and cross-checked against a release run whose conclusion is `success`, not taken from a failed run — which is what invalidated the previous #557 record.

## Is the published build the current `main`?

**No.** The published build is `c5b8189`; `main` at run time was `906b8b3`, so the shipped build is **12 commits behind**. In particular the focused-control label fix `c605ce3` (#833) is not in it.

That matters for one thing only: the focused `Shared game · Last` label renders almost invisible on this build (measured ~1.003:1 against the cream panel). It was already observed and recorded on #833 by a separate pass, and it **does not affect these legs**, which read Last mode from the document and from a legible captured state. It is noted in `notes.md` as a non-blocking mark.

## What the build did that these legs do not judge

| Observation | Where | Owner / disposition |
|---|---|---|
| `puzzle stream: deal read failed (status)` — no puzzle dealt, so no result commits | Leg 1 | #648 (catalog route ships enabled, delivery owed by #479). The reason leg 1 is `not-judged`. |
| `Preload ambient left 2 approved IDs unresolved`; unresolved audio under `game_assets/music/` and `game_assets/sound-effects/` | All legs | Ambient audio belongs to #567. Not a durability row. |
| `Save failed. Prior values kept.` shown after the forced write failure | Leg 3 | Expected behaviour, judged by leg 3. |
| Mode pick renders no Elo label | All legs | By design: Elo is read from the document, and from the `puzzle-play` R2 region when it is on screen. |

## What the previous #557 runs got wrong, and why this one differs

- They recorded commit `fb1e57e`, deployed by run `40053375882` — a run with `conclusion: failure`. That commit was never served by Pages.
- All three legs were `not-judged` because the build never left `EX.loading` (#630, since closed). This run reaches mode pick and `puzzle-play`.
- Their driver never pressed a control, so it never entered the stream, never produced an uncommitted mid-session state, and never triggered a persist write.
