# Build resolved for #625 — published `c5b8189`, no fallback used

The **Build under test** check in *Reproduction step 1* was run; the run itself was not (see
[`notes.md`](notes.md)). This file records the resolution so a completing run does not have to
re-derive it.

## Published URL serves #647's commit

| Fact | Value | How read |
|---|---|---|
| URL | `https://waigore.github.io/simplechessv2/` | `GET`, 2026-10-25 |
| HTTP status | `200` | response headers |
| Last modified | `Sat, 24 Oct 2026 17:57:05 GMT` | `Last-Modified` header |
| `Web release` run | [`40118381611`](https://github.com/waigore/simplechessv2/actions/runs/40118381611), `success`, `push` | Actions API, `web-release.yml`, newest run |
| Commit sha | `c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96` | run `head_sha` |
| #647 repair present | yes — `bccdb1c9790b9033e790a425587215490607da36` (*Implement the asset-root route for the Web build*, #712) is an ancestor of `c5b8189` | `git merge-base --is-ancestor` |

The header timestamp matches run `40118381611`'s `created_at` (`2026-10-24T17:56:09Z`) and no
later `Web release` run exists, so the URL serves that commit.

## Consequences

- **Source read**: published URL. The `Web Release` export fallback (`python3
  .github/scripts/web_export.py --preset "Web Release"`, `build/web/`, ADR-0007) is **not** used and
  must not be recorded as this run's source.
- **Correlation key**: `Web release` run id `40118381611` plus commit sha `c5b8189`. No `TEL.3`
  session id exists on this build and none is recorded: the `Web Release` preset exports
  `main_release.tscn` without the `PlaytestSeams` node, `game/session_router.gd` `_emit_tel` is a
  no-op without it, `game/playtest_seams.gd` is the only `TEL.3` writer (ADR-0004 `G2`), and #729
  measured **0** `TEL.1`–`TEL.5` lines on both the published build and the `Web Release` export.
