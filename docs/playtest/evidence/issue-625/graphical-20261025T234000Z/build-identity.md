# Build identity — #625, `graphical-20261025T234000Z`

Re-measured by an independent verify pass (2026-10-25). This file changes no row — all four
stay `not-judged` ([manifest.md](manifest.md)) — but the next run should start from it.

## 1. The Pages deployment record over-reports what is served

Both deployments checked have **`Deploy to Pages` successful** while the `Release export` job's
step 12 reads **`Pages not enabled — deploy skipped`**:

| Deployment | Commit | `Web release` run | `Release export` step 12 |
|---|---|---|---|
| `7302318984` | `c5b8189` | `40118381611` (2026-10-24T17:56) | deploy skipped |
| `7306478742` | `69a03d4` | `40146630737` (2026-10-25T00:26) | deploy skipped |

A newest-successful-deployment lookup therefore names a commit the site may not serve. The
live site answers `200` with `index.pck` **9 572 540 B**, published `2026-10-25T00:26:08Z`.
The public URL carries no commit, so the serving commit can only be taken from a deployment
whose deploy step actually ran.

## 2. #647's repair landed before `c5b8189`, so a phone reading was available on it

`bccdb1c` (*Implement the asset-root route for the Web build*, #712) is an ancestor of
`c5b8189` (57 commits), of `491554e` (99) and of `main` (142), and `game/main_release.tscn`
carries 0 `PlaytestSeams` nodes at all three. The **Build under test** condition for reading
the published URL was met on `c5b8189` — the commit #402's re-record and #626's
phone-viewport run both read.

[builds.md](builds.md) §1 reads "26 commits behind `main`, so it does not carry #647". That
compared against `main`, not against the repair, so the export was used where it was not
owed. Reading the artefact the site actually serves is the first choice for the device run,
not the fallback.

## 3. The folder name is not a `Web release` run id

`graphical-20261025T234000Z` is a local timestamp. No `Web release` run exists for `491554e`,
which [manifest.md](manifest.md) already states; nothing in the folder claims otherwise. This
line is here so a later reader does not take the suffix as a run id.
