#!/usr/bin/env python3
"""Independent acceptance measurement for #63: where the coordinate ink actually rendered.

Written for the acceptance run only; it imports no demo code. The demo's own probe prints
*predicted* boxes and its own ink counter, and an earlier round of this issue passed on a
predicted box while the render was wrong (#592), so this script measures pixels instead.

Frames
- `screenshots/demo-shared-game-exercise.png` - the graphical autodrive exercise frame.
- `screenshots/nolabels.png` - the same build rendered by `make_nolabels_probe.gd` with the
  `Coordinates` control hidden. The board, pieces, and camera are the same; only the labels
  differ, and the second frame shows exactly what each glyph was painted on.

Method
1. The 8x8 is found from the frame, not assumed: a column/row belongs to the square field
   when it contains dark square wood (PAL.C2, (139, 90, 60)) - the two square woods
   alternate, so only square columns and rows carry it. The light inlay bands and the
   coordinate margins carry none.
2. The two bands are the light-wood margins adjacent to the square field: columns left of
   it and rows below it.
3. Label ink = pixels that differ between the two frames inside those margins. The rest of
   the frame differs only where pieces moved or state changed, never in the margins.
4. Per rank row and file column: the glyph cluster, its extent, and the WCAG contrast of
   the darkest ink against the wood the labels-off frame shows at the same pixel.

Usage: python3 measure_independent.py screenshots/demo-shared-game-exercise.png screenshots/nolabels.png
"""
from __future__ import annotations

import sys

from PIL import Image

BAND_RGB = (232, 213, 181)   # PAL.C1 light inlay wood (also the light square)
DARK_RGB = (139, 90, 60)     # PAL.C2 dark square wood
TOL = 3


def lum(rgb) -> float:
    def channel(value: int) -> float:
        c = value / 255.0
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = (channel(v) for v in rgb[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a: float, b: float) -> float:
    hi, lo = max(a, b), min(a, b)
    return (hi + 0.05) / (lo + 0.05)


def near(p, ref) -> bool:
    return all(abs(p[c] - ref[c]) <= TOL for c in range(3))


def square_field(img):
    """The 8x8 as (x0, y0, x1, y1): the region whose columns and rows carry dark square wood."""
    px = img.load()
    w, h = img.size
    cols = [
        x for x in range(w)
        if sum(1 for y in range(h) if near(px[x, y], DARK_RGB)) > 40
    ]
    rows = [
        y for y in range(h)
        if sum(1 for x in range(w) if near(px[x, y], DARK_RGB)) > 40
    ]
    # The dark wood also lines the lip edges; the square field is the long central block,
    # so take the widest contiguous run of each.
    def widest(values):
        groups, start, prev = [], values[0], values[0]
        for v in values[1:]:
            if v != prev + 1:
                groups.append((start, prev))
                start = v
            prev = v
        groups.append((start, prev))
        return max(groups, key=lambda g: g[1] - g[0])

    x0, x1 = widest(cols)
    y0, y1 = widest(rows)
    return x0, y0, x1, y1


def main(with_labels: str, without_labels: str) -> int:
    a = Image.open(with_labels).convert("RGB")
    b = Image.open(without_labels).convert("RGB")
    pa, pb = a.load(), b.load()
    w, h = a.size
    sx0, sy0, sx1, sy1 = square_field(b)
    print(f"frame {w}x{h}; square field x {sx0}..{sx1}, y {sy0}..{sy1}")
    left_cols = range(0, sx0)
    bottom_rows = range(sy1 + 1, h)
    rank_px = [(x, y) for y in range(h) for x in left_cols if pa[x, y] != pb[x, y]]
    file_px = [(x, y) for y in bottom_rows for x in range(w) if pa[x, y] != pb[x, y]]
    on_light = sum(1 for (x, y) in rank_px + file_px if near(pb[x, y], BAND_RGB))
    print(f"label ink in the left margin: {len(rank_px)} px; in the bottom margin: {len(file_px)} px")
    print(f"of those, {on_light} px sit on the light inlay wood in the labels-off frame "
          f"({100.0 * on_light / max(1, len(rank_px) + len(file_px)):.1f}%)")
    ok = True

    def report(kind, label, pts, axis):
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        darkest = min(lum(pa[x, y]) for (x, y) in pts)
        woods = [lum(pb[x, y]) for (x, y) in pts if near(pb[x, y], BAND_RGB)]
        band_luma = sorted(woods)[len(woods) // 2] if woods else 0.0
        ratio = contrast(band_luma, darkest) if band_luma else 0.0
        good = ratio >= 4.5
        print(f"{'ok  ' if good else 'FAIL'} {kind} {label:8}: {len(pts):4} px x {min(xs)}..{max(xs)} "
              f"y {min(ys)}..{max(ys)}; painted on band wood {len(woods)}/{len(pts)} px; "
              f"darkest ink {darkest:.3f} → contrast {ratio:.2f}:1")
        return good

    def group(values):
        groups, start, prev = [], values[0], values[0]
        for v in values[1:]:
            if v != prev + 1:
                groups.append((start, prev))
                start = v
            prev = v
        groups.append((start, prev))
        return groups

    groups = group(sorted({y for (x, y) in rank_px}))
    print(f"left margin: {len(groups)} rank glyph rows")
    for index, (y0, y1) in enumerate(groups):
        pts = [(x, y) for (x, y) in rank_px if y0 <= y <= y1]
        ok = report("rank", str(len(groups) - index), pts, 1) and ok
    groups = group(sorted({x for (x, y) in file_px}))
    print(f"bottom margin: {len(groups)} file glyph columns")
    for index, (x0, x1) in enumerate(groups):
        pts = [(x, y) for (x, y) in file_px if x0 <= x <= x1]
        ok = report("file", chr(97 + index), pts, 0) and ok
    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
