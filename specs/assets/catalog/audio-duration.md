# Audio duration integrity

Authoring rules: [`.agents/specs/rules/assets/catalog.md`](../../../.agents/specs/rules/assets/catalog.md).

Part of [`integrity.md`](integrity.md) (`CAT.I11`).

## CAT.I11

Check an `approved` entry whose kind is `sound-effects` or `music`. A `draft` entry, a `deprecated` entry, and any other kind stay out.

Measure each file as Ogg Opus: `(last granule − OpusHead pre-skip) / 48000`. Granule units are the 48 kHz decode clock. Pre-skip is encoder delay and is not part of the cue. Bounds are inclusive. An unreadable file, a non-OGG file, or an OGG that is not Opus fails `CAT.I11`.

Sound effects map the entry's `AK-sound-effects.Vn` coverage to the `Xn` range in kind specification `S1` ([`sound-effects.md`](../kinds/sound-effects.md)). The entry must resolve to exactly one of those ranges. Check `K1` is this measure. The `S1` bands stay in that kind spec.

Music uses one inclusive band, read from specification `S4` and check `K3` in [`music.md`](../kinds/music.md), not from `S1`. Check `K3` is this measure.

CI: `asset_catalog.py`.
