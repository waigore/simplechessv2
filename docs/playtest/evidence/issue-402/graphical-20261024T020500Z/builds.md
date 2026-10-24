# Builds under test — #402 re-record, 2026-10-24

Two readings, deliberately paired. The published reading says what a player gets today; the fallback says
whether #647's repair moves any row. Neither is converted into the other, and the fallback is never recorded
as a published reading.

| Reading | Commit | Source | Attribution |
|---|---|---|---|
| **Published** | `dd1547913c71b623629c66711c098bdd42581d69` | `https://waigore.github.io/simplechessv2/` | `Web release` run **`40049651531`** (`2026-10-24T01:24:36Z`, success) |
| **Fallback** | `bccdb1c9790b9033e790a425587215490607da36` | `Web Release` export at `build/web/` of a detached worktree at that commit, served by `python3 -m http.server` | **Why**: `GET .../web-release.yml/runs?head_sha=bccdb1c…` → `total_count: 0` — the commit is unpublished |

`dd15479` **predates** #712's merge (`bccdb1c`, `2026-10-24T01:58:59Z`), so the published build does not
carry #647's asset-root repair. `bccdb1c` does. That is why the pair was read together.

Attribution query and full result table: [logs/published-40049651531-release-attribution.md](logs/published-40049651531-release-attribution.md).

## Environment

macOS arm64; Google Chrome (headless, `--headless=new`, SwiftShader WebGL); 390×844 CSS px at DPR 2; touch
emulation; `Runtime`, `Log`, `Page` and `Network` domains enabled over CDP. `SIT.4` sampler installed at
500 ms and screenshots at 500 ms / 1 / 2 / 3 / 5 / 10 / 15 / 20 / 25 s. Regenerate with
[capture_release.js](capture_release.js).

**Repeat count**: 4 published cold opens (25 s, 20 s, 20 s, 20 s) and 1 fallback cold open (25 s). A single
sample is not evidence ([`specs/playtest/evidence-manifest.md`](../../../../../specs/playtest/evidence-manifest.md)
*Timing*).

**No `TEL.3` session id** on either reading: the release export carries no seam, which is the defect cited
for the Observability row (#729), not a measurement omission.

## What each reading may and may not do

- A published row is a reading of the shipped build and may be compared with a later published row. ✔
- A fallback row is a reading of an unpublished export. It may be compared with another fallback row of the
  **same** commit. It may never be recorded as a published reading or compared with one as if it were. ✘
- Where a row could only be read on one of them, `manifest.md` says which.
