# Builds read — shipped release, and the comparator

#403's rows are about **the shipped release**. Everything below names which build a number came
from; a local export is never labelled published.

## The shipped build

| Field | Value | Read from |
|---|---|---|
| URL | `https://waigore.github.io/simplechessv2/` | `curl -sI`: `200`, `last-modified: Sat, 24 Oct 2026 17:57:05 GMT` |
| `Web release` run | `40118381611` | `gh run list --workflow=web-release.yml` |
| Commit | `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96` | the run's `headSha` |
| Published | 2026-10-24T17:56:09Z, `success` | the run record |

It is **at or after #647's merge** (`bccdb1c`, PR #712). That is the difference from #402's first
record, which read `dd15479` (run `40049651531`) — the then-newest publish, but **before** the
asset-root repair. `40118381611` is now the newest `success` run: the next one below it
(`40116392457` at `9907bd0`) is 26 minutes earlier, and every later-listed run is older. Nothing
has been published since the Pages `last-modified` above.

## The comparator (never a published reading)

`/tmp/orc403` — a detached worktree at `c5b8189`, exported with
`web_export.py --preset "Web Release"` (exit 0, `build/web/`). It answers *"does this commit
export and pass its gates"*:

- `--check-engine build/web` → exit 0
- `asset_manifest.py --check` → 0 errors
- `gdscript_tests.py test` → 30 passed
- `advice_client_test.gd` → exit 0, 0 `FAIL ` lines

**No timing, frame-time or readability number in this folder comes from it.** Every one is from
the published URL.

## Why #402's first record supplies no pass

That reading (`dd15479`) never left `Loading…`, blocked by the asset-root defect #647 repaired;
its own `readings.md` says *"No move was reachable"*. So it is used for its **outcome rule** — a
judged `fail` inherits as `fail` — never for a `pass`. #402's **re-read on `c5b8189`**
(`graphical-20261025T031500Z`, commit `161b4a9`) is the citation source for this build and is
inherited row by row.

## Console noise that is not a row failure

The published build logs on every open:

- `ERROR: Can't open file from path 'res://game_assets/music/cafe-ambient-*.ogg'` and matching
  `Unresolved asset ID` warnings;
- `ERROR: Preload ambient left 2 approved IDs unresolved`;
- `ERROR: Preload play left 5 approved IDs unresolved`.

The picture and the move path still work: the build reaches mode pick, a shared board, and
accepts `e2`→`e4`. This is the residue **#785** names, not one of #403's rows, and is recorded
so a reader does not mistake it for a cold-open failure.

## Timing environment

macOS 27.0.1, Apple M5; Chrome 156.0.8078.47 headless (`--headless=new`) with
`--use-angle=swiftshader --enable-unsafe-swiftshader`, 390×844 CSS at DPR 2, CDP over a local
debugging port. Repeats: cold open 4 (+1 control), move window 2, forced write 1.
