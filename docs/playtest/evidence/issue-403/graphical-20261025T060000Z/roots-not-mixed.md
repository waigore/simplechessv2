# Roots not mixed — Review evidence at `c5b8189`

Method, quoted: `Review of this ADR, ACC.P1–P2, and specs/technical/asset-access.md`. Its inputs
are two documents: `ACC.P1`/`ACC.P2` live in [`specs/assets/access.md`](../../../../../specs/assets/access.md),
and `R1`/`R2`/`O2` in
[`specs/technical/asset-access.md`](../../../../../specs/technical/asset-access.md).

## P1 — the asset root holds cataloged asset files and sidecars only

`game_assets/` holds **38 asset files plus its `.gitkeep`** across `board-backgrounds/`, `fonts/`,
`icons/`, `interface-art/`, `music/`, `piece-sprites/`, `sound-effects/`.

The set on disk and the set named by the 32 catalog entries' `files` are **the same 38**:

```
on disk but not cataloged: []
cataloged but missing: []
```

Extensions: 12 `.png`, 11 `.svg`, 7 `.ogg`, 5 `.woff2`, 3 `.txt`. The three `.txt` files are the
OFL licence texts, and each is named in its font entry's `files` and `license.proof` — catalogued
content, not stray files. No `.import`/`.uid` sidecar is committed, which is consistent with P1
(Godot writes them on import) rather than a breach of it.

## P2 — engine resources and build outputs live outside it

`game/project.godot`, `game/asset_manifest.json`, `.godot/` and `build/web/` are all outside
`game_assets/`, and **no catalog entry names them**. No `.gd`, `.tscn`, `.pck`, `.wasm` or
`.godot` file exists under `game_assets/`.

`asset_catalog/` itself holds the 32 entry JSONs plus `.gitkeep`; no asset file sits in it.

## R1 / O2 — the manifest is generated, committed, and current

`game/asset_manifest.json` is committed outside both roots with `asset_root: "game_assets"` and
**32** assets. A fresh `asset_manifest.py --write` produced a **byte-identical** file, so it is
generated rather than hand-edited. `asset_manifest.py --check` reports **0 errors**
(`logs/manifest-generated-not-edited-c5b8189.log`, `logs/asset-manifest-check-c5b8189.log`).

## Cited, not re-run

- **R2** — the resolver reads the manifest by asset ID; covered by `game/asset_resolver_test.gd`.
- **R3** — an unresolved ID in a Release build is skipped, the session continues, one log line.
  That is a Release-build observation and belongs to **#654**'s *Sitting survives a failed
  resolve*, which this review hands it to rather than claiming it.

## Verdict

**`pass` for `ACC.P1`, `ACC.P2`, and `R1`/`O2`'s generation and currency.** The numbers match the
write-time measurement in #403's Description (32 entries / 38 files / 0 missing / 0 errors), which
this pass re-ran on the commit it records — `c5b8189`.

Raw output: `logs/roots-not-mixed-audit-c5b8189.log`.
