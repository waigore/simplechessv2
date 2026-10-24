# Route probe, `Web Release` export built from the pre-patch tree (`origin/main` 8cdfd45)

Two `Web Release` exports of the pre-patch tree were made in `/private/tmp/accept785b`
(`web_export.py --preset "Web Release"`, Godot 4.7.2), served from `build/web/`, and
opened in headless Chrome 390x844 (same capture script as #402). Nothing in the app
changed: a probe autoload (`game/zz_probe785.gd`, temporary, not committed) called the
resolver's public route once the session was up.

## What the app did (probe capture, `route-probe-fetch.log`)

- `FileAccess.get_file_as_bytes(res://game_assets/music/cafe-ambient-a.ogg)` was not the
  failing read on this tree. Per this log, the browser executed the pre-patch resolver's
  `AudioStreamOggVorbis.load_from_file(path)` on the catalogued Opus source and reported
  every `Unresolved asset ID` / `Preload ambient left 2 approved IDs unresolved`.
- No boot failure and no render failure: the mode pick rendered on every capture.

## Why this file is the control, not the evidence

The build's own state depends on whether the shared `.godot/imported/` cache (git-ignored)
has already imported the runtime copies. An export taken immediately after the patch
already loads: the byte probe on `/private/tmp/accept785c` reports

```
[zz_probe785]   runtime-path=res://audio_runtime/01a15200-69b2-7d13-a30d-696fa4ff390b.ogg
[zz_probe785]   FileAccess.open=false err=7
[zz_probe785]   ResourceLoader.load=(res://audio_runtime/01a15200-69b2-7d13-a30d-696fa4ff390b.ogg):<AudioStreamOggVorbis#-9223371996237134536>
[zz_probe785]   stream-length-s=180.04
[zz_probe785]   resolver.resolve=(res://audio_runtime/01a15200-69b2-7d13-a30d-696fa4ff390b.ogg):<AudioStreamOggVorbis#-9223371996237134536>
[zz_probe785] ambient-unresolved=0
```

So the shipped defect on `main` reproduces only on a clean importing machine; once the
route has been imported once, even the pre-patch tree loads its `ambient` group. That is
exactly the gap #785 asks for (a guard that does not depend on import cache state) and is
recorded in the defect filed from this run.
