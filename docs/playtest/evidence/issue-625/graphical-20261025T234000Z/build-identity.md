# Build identity — #625, `graphical-20261025T234000Z`

Independent verify passes (2026-10-25, 2026-10-26) re-measured the build facts this folder
rests on. This file changes no row — all four stay `not-judged` ([manifest.md](manifest.md)) —
but the next run should start from it.

## 1. #647's repair landed before `c5b8189`

`bccdb1c` (*Implement the asset-root route for the Web build*, #712) is an ancestor of
`c5b8189` (57 commits), of `491554e` (99) and of `main` (142). `e41a6f5` (#630's serve-route
fix) is in all three too, and `game/main_release.tscn` carries 0 `PlaytestSeams` nodes.

[builds.md](builds.md) §1 reads "26 commits behind `main`, so it does not carry #647". That
compared against `main`, not against the repair, and said nothing about whether the repair was
present. Measured against the repair, the published deployment served a repaired build on
2026-10-25 — the commit #402's re-record and #626's phone-viewport run both read.

This is now history: that host no longer exists (§2), so the folder's export of `491554e` was a
legal build and remains the record of what was read. The correction matters for one reason
only — the next run must not repeat the reasoning that a build "behind `main`" lacks the repair.

## 2. There is no published client URL any more (2026-10-26)

[ADR-0016](../../../../../specs/adr/decisions/0016-no-public-client-host.md) is **Accepted** and
supersedes ADR-0009: the project publishes no client. Measured on 2026-10-26:

| Check | Result |
|---|---|
| `https://waigore.github.io/simplechessv2/` | **404** |
| `GET repos/…/pages` | **404** — no Pages site |
| `.github/workflows/web-release.yml` on `main` | no deploy job; header reads *"Does not publish"* |

`specs/playtest/procedures.md` *Prep* follows: the build under test "is a local export into
`build/web/` (ADR-0007) or an in-process run of that commit. The project publishes no client URL
(ADR-0016)."

**What this means for #625.** The body's **Build under test** field still reads *"the published
release URL `https://waigore.github.io/simplechessv2/` when it serves the commit that carries
#647's repair; otherwise the `Web Release` export"*. Its preferred branch can no longer be
taken, and its fallback is now the only source. The local `Web Release` export is the build, and
the obstacle is serving it to a phone: [blockers.md](blockers.md) §2 records that the host's
LAN address is firewalled for unattended runs, so the device pass needs a tunnel or a firewall
allowance — a setup decision for the owner, not a body defect and not a defect to file here.

The body's build and correlation-key fields need a refine pass to match ADR-0016 before the next
attempt, since AC 1 asks the manifest to name a source that no longer exists.

## 3. The folder name is not a `Web release` run id

`graphical-20261025T234000Z` is a local timestamp. No `Web release` run exists for `491554e`,
which [manifest.md](manifest.md) already states; nothing in the folder claims otherwise. This
line is here so a later reader does not take the suffix as a run id.
