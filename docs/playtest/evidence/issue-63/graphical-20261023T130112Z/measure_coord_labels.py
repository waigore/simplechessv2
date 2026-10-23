#!/usr/bin/env python3
"""Acceptance measurement for #63: where the board coordinates are painted.

PER.R7 (specs/view/perception.md): file letters and rank numbers sit on the outer
1-unit margin only, at >= 4.5:1 against the background, never inside squares.

Method: render the same autodrive frame twice, once as shipped and once with
`_build_coords()` disabled, and diff the two images. Every differing pixel is
coordinate-label ink, so its position, its square membership, and the background
it sits on are exact rather than inferred.

Geometry (PRJ.P1, 720 x 1280 frame): board origin (72, 352), 72 px per board unit,
8x8 spans x 72..648 and y 352..928; the 1-unit margin is everything outside it.

Usage: python3 measure_coord_labels.py SCREENSHOT_WITH_LABELS SCREENSHOT_WITHOUT_LABELS
"""
import sys
from collections import Counter

from PIL import Image

UNIT = 72
ORIGIN = (72, 352)
BOARD = (ORIGIN[0], ORIGIN[1], ORIGIN[0] + 8 * UNIT, ORIGIN[1] + 8 * UNIT)
CREAM = (247, 241, 232)  # PAL.C10, the label ink
MIN_CONTRAST = 4.5


def luminance(color):
    def channel(value):
        value /= 255
        return value / 12.92 if value <= 0.03928 else ((value + 0.055) / 1.055) ** 2.4
    r, g, b = (channel(c) for c in color[:3])
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    hi, lo = sorted((luminance(a), luminance(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def square_of(x, y):
    if not (BOARD[0] <= x < BOARD[2] and BOARD[1] <= y < BOARD[3]):
        return None
    return f"{chr(97 + (x - BOARD[0]) // UNIT)}{8 - (y - BOARD[1]) // UNIT}"


def clusters(values, gap=4):
    out, current = [], [values[0]]
    for value in values[1:]:
        if value - current[-1] <= gap:
            current.append(value)
        else:
            out.append((current[0], current[-1]))
            current = [value]
    out.append((current[0], current[-1]))
    return out


def main(with_labels, without_labels):
    a = Image.open(with_labels).convert("RGB")
    b = Image.open(without_labels).convert("RGB")
    if a.size != b.size:
        print(f"FAIL: frames differ in size {a.size} vs {b.size}")
        return 1
    print(f"# with labels {with_labels} ({a.size[0]}x{a.size[1]})")
    print(f"# labels off  {without_labels}")
    print(f"# board 8x8 x {BOARD[0]}..{BOARD[2]}, y {BOARD[1]}..{BOARD[3]}; {UNIT} px per unit")

    ink = [(x, y, a.getpixel((x, y)), b.getpixel((x, y)))
           for y in range(a.size[1]) for x in range(a.size[0])
           if a.getpixel((x, y)) != b.getpixel((x, y))]
    if not ink:
        print("FAIL: no label ink found")
        return 1
    print(f"# label ink pixels: {len(ink)}")

    xs = sorted({x for x, _, _, _ in ink})
    ys = sorted({y for _, y, _, _ in ink})
    print("# ink row bands (y): " + ", ".join(f"{lo}-{hi}" for lo, hi in clusters(ys)))
    print("# ink column bands (x): " + ", ".join(f"{lo}-{hi}" for lo, hi in clusters(xs, 10)))

    inside = [(x, y) for x, y, _, _ in ink if square_of(x, y)]
    print(f"# ink inside the 8x8: {len(inside)} of {len(ink)} pixels "
          f"({100 * len(inside) / len(ink):.0f}%)")
    squares = Counter(square_of(x, y) for x, y in inside)
    print("#   squares painted: " + ", ".join(f"{s} {n}px" for s, n in squares.most_common()))

    solid = [(fg, bg) for _, _, fg, bg in ink if min(fg) >= 200]
    backgrounds = Counter(bg for _, bg in solid)
    print("# background under label ink (solid pixels) and its contrast with PAL.C10:")
    failing = 0
    for background, count in backgrounds.most_common(4):
        ratio = contrast(CREAM, background)
        verdict = "ok" if ratio >= MIN_CONTRAST else "UNDER 4.5:1"
        if ratio < MIN_CONTRAST:
            failing += count
        print(f"#   {background} {count:5}px {ratio:5.2f}:1 {verdict}")
    share = 100 * failing / len(solid) if solid else 0
    print(f"# ink under the PER.R7 contrast floor: {failing} of {len(solid)} solid pixels ({share:.0f}%)")

    problems = []
    if inside:
        problems.append(f"{len(inside)} label pixels are painted inside the 8x8")
    if failing:
        problems.append(f"{failing} label pixels sit under {MIN_CONTRAST}:1")
    if problems:
        print("FAIL (PER.R7): " + "; ".join(problems))
        return 1
    print("PASS (PER.R7): labels on the outer margin only, at >= 4.5:1")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
