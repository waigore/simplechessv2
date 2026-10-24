# Builds read — what is the shipped release, and what is only a comparator

#403's rows are about **the shipped release**: the build published by #399 to
`https://waigore.github.io/simplechessv2/` (ADR-0009). Everything below names which build a
number came from. A local export is never labelled published.

## The shipped build

| Field | Value | Read from |
|---|---|---|
| URL | `https://waigore.github.io/simplechessv2/` | `curl -sI`, `200`, `last-modified: Sat, 24 Oct 2026 17:57:05 GMT` |
| `Web release` run | `40118381611` | `gh run list --workflow=web-release.yml` |
| Commit | `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96` (`c5b8189`) | the run's `headSha` |
| Published | 2026-10-24T17:56:09Z, conclusion `success` | the run record |
| Pages `last-modified` | 2026-10-24T17:57:05 GMT — one minute after the run | `curl -sI` |

**This build is at or after #647's merge** (`bccdb1c`, 2026-10-24T01:58:58Z, PR #712). That
is the difference from #402's record: #402 read `dd15479` (run `40049651531`, the then-newest
successful publish), which **predates** the asset-root repair. At #403's write time that is no
longer the newest successful publish — `40118381611` is, and it serves. So #403 does not
inherit #402's *build*, only its *outcome rule*.

`40118381611` was confirmed to be the newest `success` run at record time by sorting
`gh run list --workflow=web-release.yml` on `createdAt`: the run below it (`40116392457` at
`9907bd0`, `success`) is 26 minutes earlier (17:30:02Z vs 17:56:09Z), and every later-listed
run is older still. Nothing has been published since the Pages `last-modified` above.

## The fallback comparator (never a published reading)

`/tmp/orc403` — a detached worktree at `c5b8189`, exported with
`python3 .github/scripts/web_export.py --preset "Web Release"`, `exit 0`, `build/web/`.

It exists to answer *"does this commit export and pass its gates"* when a published page
cannot be trusted to be the same code. It is used here for:

- `--check-engine build/web` → exit 0 (`logs/check-engine-c5b8189.log`);
- `asset_manifest.py --check` → 0 errors (`logs/asset-manifest-check-c5b8189.log`);
- `gdscript_tests.py test` → 30 passed (`logs/unit-tests-c5b8189.log`);
- `advice_client_test.gd` → exit 0, 0 `FAIL ` lines (`logs/advice-client-test-c5b8189.log`).

**No timing, frame-time, or readability number in `readings.md` comes from this export.**
Every one is from the published URL.

## Why #402's record cannot supply a pass here

#402's published reading (`dd15479`, run `40049651531`) never left `Loading…` and was blocked
by the asset-root defect that #647 repaired. Its own record says so
(`docs/playtest/evidence/issue-402/graphical-20261024T020500Z/readings.md`: *"No move was
reachable"*). Its rows are therefore cited by #403 for their **outcome rule** — a judged
`fail` inherits as `fail` — and never for a `pass`. Where #403 re-timed a measurement that
#402 also took, `readings.md` says which reading the row uses and why.

## Published build: console noise that is not a row failure

The published build logs, on every open:

- `ERROR: Can't open file from path 'res://game_assets/music/cafe-ambient-*.ogg'` and the
  matching `Unresolved asset ID` warnings (`01a15200-…` ambient pair);
- `ERROR: Preload ambient left 2 approved IDs unresolved`;
- `ERROR: Preload play left 5 approved IDs unresolved`.

The **picture and the move path still work**: the build reaches mode pick, a shared board, and
accepts `e2`→`e4` (`readings.md`). The two *play* music files resolve later in the open than
the preload expects. This is the residue #785 names (ambient group), not one of #403's rows,
and it is recorded here so a reader does not mistake it for a cold-open failure.
