"""Acceptance measurement for #63: rendered piece body extent read from the
graphical screenshot (72 px per board unit, PRJ.P1; SPC.E1 extent 0.85 x 0.85).

Method: only squares that are vertically isolated (the square directly above and
below are empty) are measured, so a measured ink run is one piece silhouette and
not two stacked pieces. On such a square, the contiguous ink run through the
square centre gives the silhouette height; the run through the centre row gives
its width. Every piece body is centred on its square (SPC.P1), so a run on the
centre lines is the body's extent.

A body drawn within SPC.E1 / FRM.P1 is at most 0.85 units in either direction
and never crosses its own square edge.

Usage: python3 probe_pixels.py <screenshot.png>
"""
from PIL import Image
import sys

LIGHT, DARK = (232, 213, 181), (139, 90, 60)  # PAL.C1 / PAL.C2
SQ = 72                                        # PRJ.P1: px per board unit
X0, Y0 = 72, 344                               # board origin in the frame

im = Image.open(sys.argv[1]).convert("RGB")
px = im.load()


def ink(x, y):
    return px[x, y] not in (LIGHT, DARK)


def centre(f, rank):
    return X0 + f * SQ + SQ // 2, Y0 + (8 - rank) * SQ + SQ // 2


print("board origin (%d,%d), %d px per unit; SPC.E1 / FRM.P1 extent = 0.85 x 0.85"
      % (X0, Y0, SQ))

for f in range(8):
    for rank in range(8, 0, -1):
        cx, cy = centre(f, rank)
        if not ink(cx, cy):
            continue
        if rank < 8 and ink(*centre(f, rank + 1)):
            continue  # not isolated: the piece above would merge into the run
        if rank > 1 and ink(*centre(f, rank - 1)):
            continue
        up = down = 0
        y = cy
        while y >= Y0 - SQ and ink(cx, y):
            up += 1
            y -= 1
        y = cy + 1
        while y < Y0 + 8 * SQ + SQ and ink(cx, y):
            down += 1
            y += 1
        left = right = 0
        x = cx
        while x >= X0 - SQ and ink(x, cy):
            left += 1
            x -= 1
        x = cx + 1
        while x < X0 + 8 * SQ + SQ and ink(x, cy):
            right += 1
            x += 1
        h = (up + down) / SQ
        w = (left + right) / SQ
        verdict = "fits SPC.E1" if w <= 0.86 and h <= 0.86 else "OVER extent"
        print("  %s%d: %.2f wide x %.2f tall  (%s)"
              % (chr(97 + f), rank, w, h, verdict))
