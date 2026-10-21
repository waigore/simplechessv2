#!/usr/bin/env python3
"""Derive twelve ship piece sprites from the SS1 style-anchor sheet.

Local only: Chrome rasterize (S5) → edge flood-fill (S6) → 2×6 crop (S7)
→ one shared LANCZOS scale, centered, no stretch (S8) so the tallest body
is about 85% of the square (S1) and FRM.P2 height order survives.
No Recraft or other generative call. Source SVG:
game_assets/piece-sprites/style-anchor-sheet.svg.

Writes game_assets/piece-sprites/<type>-<white|black>.png using fit_size_px
from starting-position.layout.json (same square the preview fits into).

Usage (from repo root):
  python3 docs/asset-previews/derive_piece_sprites.py
"""
from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

from PIL import Image

from piece_sprite_pipeline import (
    SHIP_STEM,
    chrome_rasterize,
    detect_bboxes,
    flood_clear_background,
)

# S1 / SPC.E1: body about 85% of the square, centered. S8 fit_contain does not
# stretch; this only scales the fitted square down uniformly when the opaque
# body would exceed that fraction.
BODY_FRAC = 0.85

def _components(im: Image.Image) -> list[tuple[int, list[tuple[int, int]]]]:
    w, h = im.size
    px = im.load()
    seen = [[False] * w for _ in range(h)]
    comps: list[tuple[int, list[tuple[int, int]]]] = []
    for y in range(h):
        for x in range(w):
            if seen[y][x] or px[x, y][3] <= 10:
                continue
            stack = [(x, y)]
            seen[y][x] = True
            cells: list[tuple[int, int]] = []
            while stack:
                cx, cy = stack.pop()
                cells.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < w and 0 <= ny < h and not seen[ny][nx] and px[nx, ny][3] > 10:
                        seen[ny][nx] = True
                        stack.append((nx, ny))
            comps.append((len(cells), cells))
    return comps


def keep_piece(crop: Image.Image) -> Image.Image:
    """Drop column-edge slivers. The piece is the largest connected component."""
    comps = _components(crop)
    if len(comps) <= 1:
        return crop
    largest = max(area for area, _ in comps)
    drop = {xy for area, cells in comps if area < largest * 0.02 for xy in cells}
    if not drop:
        return crop
    out = crop.copy()
    px = out.load()
    for x, y in drop:
        px[x, y] = (0, 0, 0, 0)
    return out


def place_shared(crop: Image.Image, box_size: int, scale: float) -> Image.Image:
    """Uniform scale (shared across the set) and center. No stretch (S8)."""
    w, h = crop.size
    nw = max(1, int(round(w * scale)))
    nh = max(1, int(round(h * scale)))
    resized = crop.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (box_size, box_size), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((box_size - nw) // 2, (box_size - nh) // 2))
    return canvas


def shared_scale(crops: list[Image.Image], box_size: int) -> float:
    """Scale so the tallest opaque body is about 85% of the square (S1, FRM.P2)."""
    tallest = 1
    widest = 1
    for crop in crops:
        w, h = crop.size
        px = crop.load()
        minx, miny, maxx, maxy = w, h, 0, 0
        for y in range(h):
            for x in range(w):
                if px[x, y][3] > 10:
                    minx, miny = min(minx, x), min(miny, y)
                    maxx, maxy = max(maxx, x), max(maxy, y)
        tallest = max(tallest, maxy - miny + 1)
        widest = max(widest, maxx - minx + 1)
    target = BODY_FRAC * box_size
    return min(target / tallest, target / widest)


ROOT = Path(__file__).resolve().parents[2]
PREV = Path(__file__).resolve().parent
LAYOUT_PATH = PREV / "starting-position.layout.json"
SHEET = ROOT / "game_assets/piece-sprites/style-anchor-sheet.svg"
OUT_DIR = ROOT / "game_assets/piece-sprites"


def main() -> None:
    if not SHEET.is_file():
        sys.exit(f"missing style-anchor sheet: {SHEET}")
    if not LAYOUT_PATH.is_file():
        sys.exit(f"missing layout: {LAYOUT_PATH}")
    layout = json.loads(LAYOUT_PATH.read_text())
    fit_size = int(layout["fit_size_px"])
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="piece-derive-") as tmp:
        work = Path(tmp)
        sheet_png = work / "style-anchor-sheet-chrome.png"
        chrome_rasterize(SHEET, sheet_png, work)
        sheet = flood_clear_background(Image.open(sheet_png))
        bboxes = detect_bboxes(sheet)
        crops = {key: keep_piece(sheet.crop(bb)) for key, bb in bboxes.items()}
        scale = shared_scale(list(crops.values()), fit_size)
        for key, crop in crops.items():
            stem = SHIP_STEM[key]
            fitted = place_shared(crop, fit_size, scale)
            dest = OUT_DIR / f"{stem}.png"
            fitted.save(dest, optimize=True)
            print(f"{stem}\t{dest.stat().st_size}\t{fitted.size}\tscale {scale:.4f}")


if __name__ == "__main__":
    main()
