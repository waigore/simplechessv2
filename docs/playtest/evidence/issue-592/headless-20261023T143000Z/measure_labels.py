#!/usr/bin/env python3
"""Coordinate-label pixel measurement for defect #592 (PER.R7), before/after.

Band field is constant, so a band pixel that is neither band wood nor the
bevel outline hairline is label ink. Cream PAL.C10 reads 7.38:1 on the band
(#6E4430) and 1.28:1 on the light table margin (#E8D5B5), so ink on the margin
is a contrast miss, and ink inside the 8x8 is a placement miss.

Usage: measure_labels.py BEFORE.png AFTER.png
"""
import sys
from collections import Counter
from PIL import Image

U, OX, OY = 72, 72, 352
BAND = (110, 68, 48)
LINE = (46, 27, 19)
CREAM = (247, 241, 232)
MARGIN = (232, 213, 181)
BOARD = (139, 90, 60)


def lum(c):
    def f(v):
        v /= 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = (f(x) for x in c[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(a, b):
    hi, lo = sorted((lum(a), lum(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def probe(im, x0, x1, y0, y1, by_row):
    """Signed ink mass per scanline: + cream, - anything darker than the band."""
    mass = Counter()
    for y in range(y0, y1):
        for x in range(x0, x1):
            p = im.getpixel((x, y))
            if p in (BAND, LINE):
                continue
            d = lum(p) - lum(BAND)
            mass[y if by_row else x] += 1 if d > 0.02 else (-1 if d < -0.02 else 0)
    return mass


def glyphs(mass, expected, gap=8):
    """Cream runs only; merged runs that straddle a darker pixel are glyph+overlay."""
    keys = sorted(k for k, v in mass.items() if v > 0)
    if not keys:
        return []
    runs, cur = [], [keys[0]]
    for k in keys[1:]:
        if k - cur[-1] <= 2:
            cur.append(k)
        else:
            runs.append(cur)
            cur = [k]
    runs.append(cur)
    return runs


for path in sys.argv[1:]:
    im = Image.open(path).convert("RGB")
    print(f"\n# {path}")
    print(f"# cream on band {ratio(CREAM, BAND):.2f}:1; cream on margin {ratio(CREAM, MARGIN):.2f}:1")

    # files: bottom band rows 930..933, one glyph per file
    mass = probe(im, OX, OX + 8 * U, OY + 8 * U + 2, OY + 8 * U + 5, by_row=False)
    runs = glyphs(mass, [int(OX + f * U + U / 2) for f in range(8)])
    off = sum(1 for x in range(OX, OX + 8 * U) for y in range(OY + 8 * U + 2, OY + 8 * U + 5)
              if im.getpixel((x, y)) in (MARGIN, BOARD))
    print(f"# files: {len(runs)} glyph clusters in rows 930..933; "
          f"{off} ink px on the light margin or board")
    print(f"#   {[(r[0], r[-1]) for r in runs]}; file centres "
          f"{[int(OX + f * U + U / 2) for f in range(8)]} (+1 px raster offset)")

    # ranks: left band, glyph rows, skipping rows an overlay crosses
    mass = probe(im, 65, 71, OY, OY + 8 * U, by_row=True)
    runs = glyphs(mass, [int(OY + (8 - r) * U + U / 2) for r in range(1, 9)])
    print(f"# ranks: {len(runs)} cream row runs in the left band (x 65..70)")
    print(f"#   {[(r[0], r[-1]) for r in runs]}; rank centres "
          f"{[int(OY + (8 - r) * U + U / 2) for r in range(1, 9)]}")
