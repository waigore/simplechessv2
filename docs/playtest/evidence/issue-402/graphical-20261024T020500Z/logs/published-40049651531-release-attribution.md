# Release attribution — which commit the published URL served on 2026-10-24

Query (rule: `specs/playtest/procedures.md` *Prep*; the published export carries no commit stamp, so
the workflow run is the attribution):

```
gh api "repos/waigore/simplechessv2/actions/workflows/web-release.yml/runs?status=success&branch=main&per_page=3"
```

Result at the time of the re-record (`2026-10-24T02:0xZ`):

| Run id | Commit | Created | Title |
|---|---|---|---|
| `40049651531` | `dd1547913c71b623629c66711c098bdd42581d69` | `2026-10-24T01:24:36Z` | Land the playtest story-row rule the sweeps and the map depend on (#660) (#705) |
| `40041185072` | `46cec71aaaa72439d9dce4fb19299f374efe2cdb` | `2026-10-23T23:42:44Z` | Record the string-table completeness gate and copy-owner rule (#495) |
| `40040099921` | `3f81b59578fda7280d6ddf858f8f44feb308156d` | `2026-10-23T23:30:48Z` | Centre chrome panels on the frame instead of a fixed x (#616) (#682) |

`40049651531` is the newest successful `Web release` on `main`, so the published reading below is
attributed to `dd15479`. `dd15479` **predates** #712's merge (`bccdb1c919…` at `2026-10-24T01:58:59Z`),
so the published build does **not** carry #647's asset-root repair. That is why the repaired commit was
also read on the fallback export.

```
gh api "repos/waigore/simplechessv2/actions/workflows/web-release.yml/runs?head_sha=bccdb1c9790b9033e790a425587215490607da36"
→ {"total_count": 0, ...}
```

No `Web release` run exists on `bccdb1c`, so the repaired commit is unpublished and the fallback export of
it can never be recorded as a published reading.

Observed at read time: the published cold open failed with `Preload boot left 9 approved IDs unresolved`
and no `Boot assets failed` line — the pre-#647 shape — consistent with `dd15479` being the served commit.
