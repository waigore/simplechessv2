#!/usr/bin/env python3
"""Measure drawn piece bodies on the shared-game demo screenshots.

Checks the acceptance finding on #63 and SPC.E1 / FRM.P1 / FRM.P2: each body
must sit inside the 0.85 x 0.85 extent, the King must reach the full 0.85
height, and the height order must be King > Queen > Rook/Bishop/Knight > Pawn.

The demo draws pieces as near-white (white side) or near-black (black side)
silhouettes on flat board colors, so a square's body is the bounding box of its
near-white or near-ink pixels. Geometry from main.gd: board origin (72, 352),
unit 72 px.

Usage: python3 measure_pieces.py SCREENSHOT
"""
import sys
from PIL import Image

UNIT = 72
ORIGIN = (72, 352)
EXTENT = 0.85
# A body whose edge lands on a pixel boundary rasterizes up to one pixel wider
# than its exact extent; the demo's own fit reports the exact 0.85.
RASTER_TOLERANCE_PX = 1
# The exercise scenario's final position (main.gd EXERCISE).
EXERCISE_PIECES = {
    "e1": "wK", "d1": "wQ", "a1": "wR", "h1": "wR", "c1": "wB", "f3": "wN",
    "e4": "wP", "b2": "wP",
    "e8": "bK", "d8": "bQ", "a8": "bR", "g8": "bR", "g7": "bB", "c6": "bN",
    "e5": "bP",
}
HEIGHT_ORDER = ["K", "Q", "B", "N", "R", "P"]
# FRM.P2 opaque height per type, as a fraction of one square (+-0.01).
FRM_P2 = {"K": 0.85, "Q": 0.79, "B": 0.76, "N": 0.75, "R": 0.68, "P": 0.62}
FRM_P2_TOLERANCE = 0.01


def is_piece(px):
    r, g, b = px
    neutral = max(r, g, b) - min(r, g, b) <= 18
    return neutral and (min(r, g, b) >= 235 or max(r, g, b) <= 80)


def body_box(img, square):
    file_index = ord(square[0]) - ord("a")
    rank = int(square[1])
    left = ORIGIN[0] + file_index * UNIT
    top = ORIGIN[1] + (8 - rank) * UNIT
    xs, ys = [], []
    for y in range(top, top + UNIT):
        for x in range(left, left + UNIT):
            if is_piece(img.getpixel((x, y))[:3]):
                xs.append(x)
                ys.append(y)
    if not xs:
        return None
    return min(xs), min(ys), max(xs) + 1, max(ys) + 1


def report(path):
    img = Image.open(path).convert("RGB")
    print(f"# screenshot {path} ({img.size[0]}x{img.size[1]})")
    print(f"# board origin {ORIGIN}, {UNIT} px per board unit, SPC.E1 extent {EXTENT}")
    print(f"{'square':6} {'piece':5} {'w px':>5} {'h px':>5} {'w unit':>7} {'h unit':>7}  verdict")
    heights = {}
    problems = []
    for square, piece in sorted(EXERCISE_PIECES.items()):
        box = body_box(img, square)
        if box is None:
            problems.append(f"{square} ({piece}) shows no piece art")
            print(f"{square:6} {piece:5} {'-':>5} {'-':>5} {'-':>7} {'-':>7}  MISSING")
            continue
        w = (box[2] - box[0]) / UNIT
        h = (box[3] - box[1]) / UNIT
        heights.setdefault(piece[1], []).append(h)
        limit = EXTENT + RASTER_TOLERANCE_PX / UNIT
        verdict = "inside extent" if w <= limit and h <= limit else "OVER EXTENT"
        if verdict != "inside extent":
            problems.append(f"{square} {piece} body {w:.2f} x {h:.2f} exceeds {EXTENT}")
        if abs(box[2] - box[0]) >= UNIT or abs(box[3] - box[1]) >= UNIT:
            problems.append(f"{square} {piece} silhouette reaches the whole square")
        print(f"{square:6} {piece:5} {box[2] - box[0]:>5} {box[3] - box[1]:>5} "
              f"{w:>7.2f} {h:>7.2f}  {verdict}")
    print("# height per type (board units):")
    means = {}
    for kind in HEIGHT_ORDER:
        values = heights.get(kind, [])
        if values:
            means[kind] = sum(values) / len(values)
            print(f"#   {kind}: {', '.join(f'{v:.2f}' for v in values)}")
    if len(means) == len(HEIGHT_ORDER):
        print("# FRM.P2 check (measured vs spec, +-0.01 plus one raster pixel):")
        for kind in HEIGHT_ORDER:
            expected = FRM_P2[kind]
            delta = means[kind] - expected
            limit = FRM_P2_TOLERANCE + RASTER_TOLERANCE_PX / UNIT
            verdict = "ok" if abs(delta) <= limit else "OFF"
            print(f"#   {kind}: {means[kind]:.2f} vs {expected:.2f}  {verdict}")
            if abs(delta) > limit:
                problems.append(
                    f"{kind} height {means[kind]:.2f} is not the FRM.P2 {expected:.2f}")
        if means["K"] != max(means.values()) or means["P"] != min(means.values()):
            problems.append(f"FRM.P2 order broken: {means}")
    if problems:
        print("# FAIL")
        for problem in problems:
            print(f"#   {problem}")
        return 1
    print("# PASS: every body inside SPC.E1, King at full height, each at its FRM.P2 height")
    return 0


if __name__ == "__main__":
    sys.exit(report(sys.argv[1]))
