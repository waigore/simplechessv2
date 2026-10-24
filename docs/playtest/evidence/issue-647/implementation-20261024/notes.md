# #647 implementation run — 2026-10-24

Branch `task/647-asset-root-route` off `origin/main` `f7d089f`. Godot 4.7.2 stable (`ed1daf0bf`), macOS arm64, headless Chrome 390×844.

## What landed

| Unit | Where |
|---|---|
| S1 spec correction (E4 `boot_failed`, `CMP.R2`, `AST.G1`–`G3`, `CTR-asset-resolve` E4 + O1) | `specs/technical/*` |
| Route record (ADR-0014 + split files) | `specs/adr/decisions/0014-web-asset-root-route*` |
| Export stages the asset root, exports, discards; `--check-assets` gate | `.github/scripts/web_export.py` |
| `Web release` runs the check | `.github/workflows/web-release.yml` |
| `_preload` emits E4 instead of returning; `_check_preload_gap` inverted | `game/asset_resolver.gd`, `game/asset_resolver_test.gd` |
| Router observes the E4 failure | `game/session_router.gd` (`_on_boot_failed`) |

## Verification actually run

- `python3 .github/scripts/gdscript_tests.py test` → **26 passed**
- `python3 .github/scripts/gdscript_tests.py coverage` → **86.5%** (threshold 80)
- `pytest .github/scripts/tests/test_web_export.py` → **25 passed**
- `python3 .github/scripts/spec_lint.py` → **0 errors** (1 pre-existing glossary warning)
- `web_export.py --check-assets` on a real `Web Release` export → **`35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)`**, exit 0
- Same check on a tree whose `index.pck` carries no asset → **exit 1**, `the shipped tree carries no game_assets/ asset file`

## What did NOT work — AC3 is not met

A real `Web Release` export was served (`python3 -m http.server`) and driven in headless Chrome at 390×844 for 25 s.

- The files **are** in the build: `index.pck` is 9 552 900 bytes (was 221 228 at #630), containing `res://game_assets/…` and `res://audio_runtime/…`.
- The browser still logs, per asset: `ERROR: Error opening file 'res://game_assets/icons/quit.svg'`, `ERROR: Can't open file from path 'res://game_assets/fonts/noto-sans-latin-400.woff2'`.
- Then: `ERROR: Preload boot left 9 approved IDs unresolved` and — the new S1 behaviour — `ERROR: Boot assets failed: 9 approved IDs unresolved`.
- Screenshot at 390×844 (`/tmp/shot-now.png`, not committed): still `Loading…`.

So E4 now surfaces the failure (S1/S3 work), but the build does not leave `EX.loading`: no specified `EX.loading` failure exit exists (S2 is still a defect to file against `#37`).

### Attempts that failed and were reverted

1. `filesystem/import/<dir>/keep_file=*` in `export_presets.cfg` → ConfigFile parse error at line 21, export aborted.
2. `filesystem/import/<dir>/import_filter/{include,exclude}` → engine then imports the bare Opus `.ogg` copies and aborts the export (`Ogg Vorbis decoding failed` ×7).
3. `.gdignore` in each staged directory → excluded the files from the PCK entirely (no `game_assets/` byte in the pack).

## Honest AC status

| AC | Status |
|---|---|
| AC1 (S1 spec surfaced failure) | met |
| AC2 (export carries a cataloged asset file) | met — 35/35 in `index.pck` |
| AC3 (reaches mode pick, 0 unresolved) | **not met** — measured above |
| AC4 (unresolved group surfaces; caller observes; `STAGE_LOADING` left) | surfaced half met (test + `boot_failure_count`); `STAGE_LOADING` left: **not met**, blocked on S2 |
| AC5 (`Web release` red on an asset-less tree, green on a good one) | red/green proven locally by `--check-assets`; CI run URLs exist only after this branch runs |
| AC6 (tests pass, lint clean, no new player copy) | met |
| AC7 (outcome recorded on #630/#636) | posted with this run |
