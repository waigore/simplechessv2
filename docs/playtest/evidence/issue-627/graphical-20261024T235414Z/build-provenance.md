# Build provenance — #627 listening run

Measured on this machine during the run (2026-10-25, ~07:54–08:33 UTC session clock).

## Build under test — the published release URL ([B1])

```
URL:                 https://waigore.github.io/simplechessv2/
HTTP:                200
index.pck at 07:56:  9 568 028 B   (deployment c5b8189, 2026-10-24T17:56:45Z)
index.pck at 08:30:  9 572 540 B   (deployment 69a03d4, 2026-10-25T00:26:00Z)
GET asset_resolver.gd: 404  (the loose route is not served; the pack carries it)
```

Both deployed shas are ancestors of `origin/main` (`69a03d4`), and both carry #647's
repair (`bccdb1c`) and #570's landing commit `943d5f0`. The published URL therefore
satisfied [B1]; **no export fallback reason applies** and the published build is what
the run grades.

**The published build changed mid-run.** `c5b8189` was what I first graded (07:56);
a `Web release` publish of `69a03d4` landed at 00:26Z, which is 08:26 local, while
the run was in progress. The two builds differ in what the browser is asked to
play, so both are recorded and labelled by sha. The **per-cue** readings are taken
on the current build (`69a03d4`); the `c5b8189` reading is kept as the earlier
snapshot of the same defect.

## Fallback export (control only)

```
worktree:   /private/var/.../opencode/627-export @ c5b8189
commands:   godot --headless --path game --import --quit
            python3 .github/scripts/web_export.py --preset "Web Release" --check-boot --check-assets
check:      35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)
served:     python3 -m http.server 8767 --bind 127.0.0.1 (from a copy of build/web)
index.pck:  9 571 388 B
```

The export is a **control**, never the reading: it shows what the same commit plays
when its loose `audio_runtime/` copies and the catalog files are on disk. It is cited
only to show which half of the published failure is the pack route and which half is
the missing loose audio route.
