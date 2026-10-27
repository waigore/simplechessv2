# #882 acceptance — how the failure was reached

The build under test is the `Web Release` export of `main` @ `79d5780` (`build/web`, started at `main_release.tscn`), served at 390×844 with every `game_assets/` and `audio_runtime/` file removed.

## The body's recipe alone does not reach the failure

`scripts/strip_served_assets.py` strips 47 served files (only `game_assets/.gitkeep` remains). `AssetResolver._load_texture` / `_load_font` fall back to `ResourceLoader` on Web, and the export stages the imported derivatives into the pack, so the release scene still resolves Boot and opens on mode-pick. The probe scene confirms it on the identical tree: `PROBE boot ids=11`, `PROBE boot_outcome=0`.

## Reaching the surface deliberately

`scripts/build-probe.sh` exports the same tree with one extra scene as the main scene: `probe882web.tscn`, a `Node` that resolves an 11-ID Boot group against the same empty served tree. Its page console shows:

```
PROBE web=true release=true
PROBE boot ids=11
PROBE boot_outcome=0            <- with assets served
ERROR: Preload boot left 9 approved IDs unresolved
ERROR: Boot assets failed: 9 approved IDs unresolved   <- served tree stripped
```

It writes `build/probe882f` and `build/served-probe`, restores `game/project.godot` and `game/export_presets.cfg`, and removes the probe scene from `game/`. `SessionRouter` is not in that scene, so the router's `STAGE_LOAD_FAILED` transition is covered by the headless suite (`_router_loads_again_after_failure`, `_check_load_failure_surface`) rather than re-shot.

## Servers and drivers

- `python3 -m http.server` on `build/web-served` (acceptance, `scripts/accept.mjs`) and `build/served-probe` (probe, `scripts/probe.mjs`); both torn down after capture.
- `scripts/cdp.mjs` is the CDP session from the #879 acceptance run, unchanged.
