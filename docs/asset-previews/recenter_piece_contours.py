#!/usr/bin/env python3
"""Re-tone the piece contour to SRF.O1 (#883).

The SS1 sheet draws a white piece's line art in C3-light and a black
piece's line art one shade darker than C4, so PAL.K2's contour carrier is
not the O1 hex on the shipped board. This step sends every contour tone to
the O1 hex (white pieces C4, black pieces C3) and the body fill to the side's
fill hex (white C3, black C4), which is what K7 asks for. S3's three fill
regions stay three: fill, contour, page.

Running it on the S8-fitted PNG keeps the board render exactly as S5-S9
draw it: no second rasterize, no second crop, no reshape. One file holding
only near-flat tones (>= 98% of its body) keeps its dark/light tones at
their own coverage so S1's light direction survives; every other file has
streak shading drawn by a sheet gradient, where shading and antialias alias
in pixel space, so its ink takes one tone -- which is what O1 asks for.

Usage (after derive_piece_sprites.py, from repo root):
  python3 docs/asset-previews/recenter_piece_contours.py
"""
from __future__ import annotations

import sys
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "game_assets/piece-sprites"

# O1 contour and body fill per side (surface.md O1, palette.md K7).
CONTOUR = {"white": (44, 42, 40), "black": (245, 240, 230)}
FILL = {"white": (245, 240, 230), "black": (44, 42, 40)}
# Body core: below this alpha a pixel is the S8 fringe.
CORE_ALPHA = 250
# A file is near-flat at this share of its body in one tone.
FLAT_SHARE = 0.98
# Fringe below this coverage carries no visible ink.
MIN_SHARE = 0.02
STEMS = [f"{t}-{side}" for side in ("white", "black") for t in "kqrbnp"]


def _dist(a, b) -> float:
    return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2 + (a[2] - b[2]) ** 2) ** 0.5


def _body(im: Image.Image) -> Counter:
    return Counter(px[:3] for px in im.getdata() if px[3] >= 160)


def _is_flat(im: Image.Image) -> bool:
    body = _body(im)
    total = sum(body.values())
    return bool(body) and body.most_common(1)[0][1] / total >= FLAT_SHARE


def _flat_recenter(im: Image.Image, side: str) -> Image.Image:
    """Two body tones: the main one is the fill (-> fill hex), the other contour."""
    out = im.copy()
    px = out.load()
    w, h = out.size
    tones = [tone for tone, _ in _body(im).most_common()]
    main = tones[0]
    other = tones[1] if len(tones) > 1 else tones[0]
    fill = FILL[side]
    o1 = CONTOUR[side]

    def target(rgb):
        """The hex a drawn tone becomes (fill, or contour at the same step)."""
        if _dist(rgb, other) < _dist(rgb, main):
            return o1
        return fill

    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a >= CORE_ALPHA:
                px[x, y] = (*target((r, g, b)), a)
    return out


def _solid_recenter(im: Image.Image, side: str) -> Image.Image:
    """Fill -> fill hex, every other ink -> O1 hex; alpha untouched."""
    out = im.convert("RGBA").copy()
    px = out.load()
    w, h = out.size
    fill = FILL[side]
    o1 = CONTOUR[side]
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if a >= CORE_ALPHA:
                px[x, y] = (*(fill if _dist((r, g, b), fill) <= _dist((r, g, b), o1) else o1), a)
                continue
            if a / 255.0 <= MIN_SHARE:
                px[x, y] = (0, 0, 0, 0)
                continue
            # The S8 fringe stores its tone premultiplied by alpha: divide the
            # coverage back out to choose its side, then keep the coverage.
            tone = tuple(min(255, round(v / (a / 255.0))) for v in (r, g, b))
            shade = fill if _dist(tone, fill) <= _dist(tone, o1) else o1
            px[x, y] = (*shade, a)
    return out


def main() -> None:
    for stem in STEMS:
        path = OUT_DIR / f"{stem}.png"
        if not path.is_file():
            sys.exit(f"missing ship sprite: {path}")
        side = "black" if stem.endswith("-black") else "white"
        im = Image.open(path).convert("RGBA")
        flat = _is_flat(im)
        out = _flat_recenter(im, side) if flat else _solid_recenter(im, side)
        out.save(path, optimize=True)
        mode = "per-tone" if flat else "solid"
        print(f"{stem}\t{path.stat().st_size}\t{mode}")


if __name__ == "__main__":
    main()
