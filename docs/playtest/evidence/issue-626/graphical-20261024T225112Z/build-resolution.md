# Build under test — resolved for #626

AC 1 of #626 says the manifest must state **which build was read** — the published URL when it serves a commit carrying #647's repair and passing #715's served-tree check, otherwise the `Web Release` export of such a commit. This file resolves that field from the tracker and the published host. It is the only part of #626 an agent can answer; the rows themselves need the phone.

## Fields

| Field | Value |
|---|---|
| URL | `https://waigore.github.io/simplechessv2/` |
| Served commit | **`c5b8189b704b8e7ebaa930c2940b0c9f27cf9d96`** — *Keep the PER.R6 Check word on one line (#767) (#817)* |
| Attributing `Web release` run | **`40118381611`** — `completed` / `success`, 2026-10-24T17:56:09Z, on `main` |
| Its jobs | `Release export` **success**, `Deploy to Pages` **success** |
| `TEL.3` session id | none — the release export strips the seam (ADR-0004 `G2`, #729); none recorded, none invented |
| Source | published URL — **the preferred source**; the export fallback is **not** used |

## Why this is the right build

- **#647's repair is in it.** `bccdb1c` (*Implement the asset-root route for the Web build*, 2026-10-24T01:58:58Z, PR #712) is an ancestor of `c5b8189` (`git merge-base --is-ancestor bccdb1c c5b8189` → true).
- **Pages serves it, not an older tree.** `HEAD /` → `200`, `Last-Modified: Sat, 24 Oct 2026 17:57:05 GMT`; `HEAD /index.pck` → `200`, same `Last-Modified`, `content-length` ≈ 9.6 MB — the asset-carrying size, not the 221 228-byte asset-less one #630 measured.
- **No newer successful release exists.** `gh run list --workflow="Web release" --branch main` → every later run is either absent or non-successful; `40118381611` is the newest `success` on `main`.
- **The served build reached the screen.** #402's re-record read this same commit and run, cold open to mode pick, with the asset group resolved (`docs/playtest/evidence/issue-402/graphical-20261025T031500Z/builds.md`). The served-tree readability question ADR-0014 left *Open* is not re-opened here; #715 was superseded after that reading.

## What the fallback would have been, and why it is not used

`python3 .github/scripts/web_export.py --preset "Web Release"` → `build/web/` (ADR-0007), of a commit at or after `bccdb1c`. It is not used because the published URL already serves such a commit with a green deploy. `main` is 43 commits ahead of `c5b8189` as measured today; none of them is published, and publishing them is out of this issue's scope (*Out of scope*: re-publishing, and #510 is closed `accepted`).

## What a completing run still must measure

Resolving the build is not reading a row. A phone run still needs a physical phone, iOS Safari plus one Chromium mobile browser, a café-grade network or hotspot, and a person at the table for one 15–40 minute sitting — see [notes.md](notes.md).
