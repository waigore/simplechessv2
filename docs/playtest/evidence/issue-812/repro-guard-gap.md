# #812 — a `Web Release` bundle whose `ambient` group is unopenable ships with every existing guard green

Measured while implementing #812. Godot 4.7.2, `python3 .github/scripts/web_export.py
--preset "Web Release"`, tree `git archive HEAD` (cold checkout, then
`godot --headless --path game --import --quit`, then the export).

## What the build actually carries

On this builder the export staged seven playable copies loose under
`build/web/audio_runtime/`, and each is a real Vorbis stream (`OggS` + `vorbis`
header, e.g. `01a15200-69b2-7d13-a30d-696fa4ff390b.ogg` 3 299 929 B). The engine's
`index.pck` file table carries only the `.import` sidecar route
`res://audio_runtime/<id>.ogg.import` for each copy, never the loose route.

A real pack directory (v4) parsed with the engine's layout
(`file_access_pack.cpp`, `PackedSourcePCK::try_open_pack`): magic, version,
three engine version words, flags, file base, directory offset, reserved run,
then per entry a length-prefixed path **including its NUL terminator**, offset,
size, checksum and flags. 158 entries on this bundle.

## The reading that matters

The shipped resolver reads audio from `res://audio_runtime/<asset ID>.ogg`
(`game/asset_resolver.gd` `_runtime_audio_path`, `ResourceLoader.load`), not from
the catalog path. Running the resolver itself against the cold-export bundle:

```
probe812 group=boot    resolved=11 unresolved=0
probe812 group=play    resolved=19 unresolved=0
probe812 group=ambient resolved=2  unresolved=0
```

So this bundle plays. The defect is what happens to a bundle where those two
copies never reach the shipped tree.

## The guard gap (the defect's own signature)

With both ambient copies removed from the bundle, the existing release guards
stay green and nothing reports the group:

```
--check-assets  -> 35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)   rc=0
--check-boot    -> 14 of 14 boot asset file(s) resolved                                rc=0
--check-groups  -> 0 of 2 ambient asset file(s) resolved — no route serves: ...        rc=1
```

`--check-groups` is the check this change adds. Its red reading names the route
the resolver reads, not the catalog path:

```
0 of 2 ambient asset file(s) resolved — no route serves:
  01a15200-69b2-7964-a602-ad5b19583125 (audio_runtime/01a15200-69b2-7964-a602-ad5b19583125.ogg),
  01a15200-69b2-7d13-a30d-696fa4ff390b (audio_runtime/01a15200-69b2-7d13-a30d-696fa4ff390b.ogg)
```

## The packed-only route is not mis-graded

The issue asks the guard to use the resolver's read rule rather than a loose-file
check. With the ambient-b copy absent loose and its route added to the pack as a
real directory entry, the group resolves:

```
route packed: True    ambient-b loose: False    missing ambient: []
```

A `.import` sidecar that merely spells the route in its `path=` text is not an
entry, and the guard does not see it as one.

## The route is the resolver's

`_load_audio` takes the Vorbis copy only when the catalog stream's header carries
`OpusHead`; any other stream plays where it lies. Copies removed, real manifest:
`14 of 19 play asset file(s) resolved`; with `check.ogg` plain Vorbis: `15 of
19`, that route unnamed — a bundle that plays, not refused. The defect's
signature still refuses `ambient` 0 of 2.

## Green on a healthy real bundle

Fresh export of the same cold checkout, all three existing release checks plus
the new one:

```
35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies)
14 of 14 boot, 19 of 19 play, 2 of 2 ambient asset file(s) resolved   rc=0
```
