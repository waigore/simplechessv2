# Manifest — #785 acceptance run

- **Issue**: #785 — shipped release plays no cafe ambience (both `ambient` music IDs fail)
- **Environment**: `ENV.2` Graphical — headless Chrome 156 (`--headless=new`, CDP), 390×844 CSS px, DPR 2, `--autoplay-policy=no-user-gesture-required`, `--mute-audio`, WebGL 2.0 (SwiftShader)
- **Build under test**: `Web Release` export of **PR #799 head `d21bbf6`**, from `/private/tmp/accept785b` (`web_export.py --preset "Web Release"`, Godot 4.7.2), served from `build/web/` on `127.0.0.1:8767`. The published URL is not used: it serves `main` `8cdfd45`, which does not carry the fix until #799 merges. Fallback per [procedures.md](../../../specs/playtest/procedures.md) "Prep".
- **Control**: a `Web Release` export of **`origin/main` `8cdfd45`** (pre-patch), same capture, same viewport. Its route-state probe is in `logs/repro-export-prepatch.md` — read its caveat before treating it as red/green.
- **Repeat count**: one cold open per build for the console reading; the route probe ran on a second export of each tree.
- **Capture script**: [`issue-402/graphical-20261024T020500Z/capture_release.js`](../issue-402/graphical-20261024T020500Z/capture_release.js) (unchanged), 25 s window.

## Scope

#785 changes game code (the Web audio read route), so playtesting is required ([playtest.md](../../../specs/playtest/playtest.md) gate). The playable surface it changes is **the `ambient` music group and `SND.M1` starting at mode pick**. No design or UX protocol judges audio: `specs/playtest` has no story row for `SND.M1`/`SND.M2` (a grep for `SND.M1` in `specs/playtest/` returns nothing), the `FS.*` filmed seating judges no story and needs `SIT.7`, whose seam is still `TBD`, and view stories are out of playtest scope. So no protocol row is selected; this run records the build behaviour #785 names instead (below).

## Results

| Observation | Build | Evidence |
|---|---|---|
| Mode pick renders at 390×844 within 25 s | #799 `d21bbf6` | `screenshots/mode-pick-390x844.png` |
| `Preload ambient` line (unresolved count) | #799 `d21bbf6` | absent — group settled with 0 unresolved (`logs/graphical-cold-open.log`) |
| `Unresolved asset ID` warnings for either music ID | #799 `d21bbf6` | 0 (`logs/graphical-cold-open.log`) |
| Console `ERROR` lines | #799 `d21bbf6` | 0 (`logs/graphical-cold-open.log`) |
| `FileAccess.open(res://audio_runtime/<id>.ogg)` | #799 `d21bbf6` | **fails**, err 7 — the loose route does not open |
| `ResourceLoader.load(res://audio_runtime/<id>.ogg)` | #799 `d21bbf6` | `AudioStreamOggVorbis`, 180.04 s / 174.03 s |
| `resolver.resolve(<ambient id>)` | #799 `d21bbf6` | returns `AudioStreamOggVorbis` for both IDs |
| Ambient bound and playing at mode pick | #799 `d21bbf6` | `bound=2 started=true playing=true`, stream `res://audio_runtime/…390b.ogg`, bed index 0 (`logs/playback-position.log`) |
| Music position advances | #799 `d21bbf6` | 8.94 s → 10.94 s → 12.96 s over 4 s (`logs/playback-position.log`) |
| Read of the runtime route with no import cache | #799 `d21bbf6`, second export | `FileAccess.get_file_as_bytes(...)` = 0 B; `load_from_buffer` decodes nothing (`logs/route-probe-fetch.log`) |

This run does **not** claim `SND.M1` audibility on the published build, and does not judge what a player hears: that is #627's surface. It claims the audio path #785 names opens, binds, and advances.

## Not claimed

- The published URL. It will serve the fix only after #799 merges and `Web release` republishes; that byte-for-byte check belongs to a published-build run.
- Audibility, mix, or autoplay behaviour (#627).
- Any `quality.md` row.

## Paths

- `logs/graphical-cold-open.log` — console + network, #799 export, 25 s cold open
- `logs/playback-position.log` — `AudioStreamPlayer` bind/position probe
- `logs/route-probe-fetch.log` — the loose-route fetch probe on a fresh export
- `logs/repro-export-prepatch.md` — the pre-patch control and its caveat
- `screenshots/mode-pick-390x844.png` — mode pick, #799 export, 25.0 s

## Defects

- #812 — the `ambient` group can ship unresolved again: the "resolves" state depends on the build machine's `.godot` import cache, and no release guard reads this group.
