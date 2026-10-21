#!/usr/bin/env python3
"""Shared S5–S9 piece-sprite steps (piece-sprites kind spec).

Rasterize with one Chrome/Chromium headless binary, edge flood-fill
near-white, crop the 2×6 sheet, and fit_contain. Used by the starting-
position rebuild and by derive_piece_sprites.py. Do not mix in rsvg or
qlmanage (docs/asset-tools-recraft.md).
"""
from __future__ import annotations

import os
import shutil
import subprocess
import sys
from collections import deque
from pathlib import Path

from PIL import Image

NAMES = ["K", "Q", "R", "B", "N", "P"]
# Handle stems: kind Naming `piece-sprites/<type>-<white|black>`.
SHIP_STEM = {
    "w-K": "k-white",
    "w-Q": "q-white",
    "w-R": "r-white",
    "w-B": "b-white",
    "w-N": "n-white",
    "w-P": "p-white",
    "b-K": "k-black",
    "b-Q": "q-black",
    "b-R": "r-black",
    "b-B": "b-black",
    "b-N": "n-black",
    "b-P": "p-black",
}


def find_chrome() -> Path:
    """One pipeline rasterizer: Chrome or Chromium, never a second engine."""
    env = os.environ.get("CHROME", "").strip()
    if env:
        path = Path(env)
        if path.is_file():
            return path
        sys.exit(f"CHROME is not a file: {env}")
    candidates = [
        Path("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"),
        Path("/usr/bin/google-chrome-stable"),
        Path("/usr/bin/google-chrome"),
        Path("/usr/bin/chromium"),
        Path("/usr/bin/chromium-browser"),
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    for name in ("google-chrome-stable", "google-chrome", "chromium", "chromium-browser", "chrome"):
        found = shutil.which(name)
        if found:
            return Path(found)
    sys.exit("Chrome/Chromium not found; set CHROME to the binary (piece-sprites S5)")


def chrome_rasterize(svg: Path, out_png: Path, work: Path, size: int = 2048) -> None:
    chrome = find_chrome()
    work.mkdir(parents=True, exist_ok=True)
    html = work / f"_tmp_{svg.stem}.html"
    html.write_text(
        "<!DOCTYPE html><html><head><style>"
        f"html,body{{margin:0;padding:0;overflow:hidden;background:#fff;width:{size}px;height:{size}px}}"
        "img{display:block;border:0}"
        "</style></head><body>"
        f"<img src='{svg.resolve().as_uri()}' width='{size}' height='{size}'/>"
        "</body></html>",
        encoding="utf-8",
    )
    subprocess.run(
        [
            str(chrome),
            "--headless",
            "--disable-gpu",
            "--no-sandbox",
            "--disable-dev-shm-usage",
            "--hide-scrollbars",
            "--force-device-scale-factor=1",
            f"--screenshot={out_png}",
            f"--window-size={size},{size}",
            html.resolve().as_uri(),
        ],
        check=True,
        capture_output=True,
    )
    html.unlink(missing_ok=True)


def flood_clear_background(im: Image.Image, thresh: int = 250) -> Image.Image:
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
    bg = [[False] * w for _ in range(h)]
    q: deque[tuple[int, int]] = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or bg[y][x]:
            continue
        r, g, b, _a = px[x, y]
        if not (r >= thresh and g >= thresh and b >= thresh):
            continue
        bg[y][x] = True
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    for y in range(h):
        for x in range(w):
            if bg[y][x]:
                px[x, y] = (255, 255, 255, 0)
    return im


def detect_bboxes(sheet: Image.Image) -> dict[str, tuple[int, int, int, int]]:
    w, h = sheet.size
    px = sheet.load()
    mask = [[px[x, y][3] > 10 for x in range(w)] for y in range(h)]
    row_count = [sum(1 for x in range(w) if mask[y][x]) for y in range(h)]
    gap_start = next(y for y in range(h // 2 - 200, h // 2 + 200) if row_count[y] < 30)
    gap_end = gap_start
    while gap_end < h and row_count[gap_end] < 30:
        gap_end += 1
    y_top0 = next(y for y in range(h) if row_count[y] > 80)
    y_top1 = gap_start
    y_bot0 = gap_end
    y_bot1 = next(y for y in range(h - 1, -1, -1) if row_count[y] > 80) + 1

    def col_segs(y0: int, y1: int):
        col_count = [sum(1 for y in range(y0, y1) if mask[y][x]) for x in range(w)]
        thr = max(40, max(col_count) // 15)
        on = [c > thr for c in col_count]
        segs: list[tuple[int, int]] = []
        i = 0
        while i < w:
            if on[i]:
                j = i
                while j < w and on[j]:
                    j += 1
                if j - i >= 50:
                    segs.append((i, j))
                i = j
            else:
                i += 1
        return segs, col_count

    def split_to_6(segs, col_count):
        segs = list(segs)
        while len(segs) < 6:
            i = max(range(len(segs)), key=lambda k: segs[k][1] - segs[k][0])
            x0, x1 = segs[i]
            if x1 - x0 < 120:
                break
            mid0 = x0 + (x1 - x0) // 3
            mid1 = x0 + 2 * (x1 - x0) // 3
            cut = min(range(mid0, mid1), key=lambda x: col_count[x])
            segs = segs[:i] + [(x0, cut), (cut + 1, x1)] + segs[i + 1 :]
        while len(segs) > 6:
            gaps = [(segs[i + 1][0] - segs[i][1], i) for i in range(len(segs) - 1)]
            _, i = min(gaps)
            segs[i] = (segs[i][0], segs[i + 1][1])
            del segs[i + 1]
        return segs

    def refine(x0, x1, y0, y1, pad=8):
        minx, miny, maxx, maxy = w, h, 0, 0
        for y in range(y0, y1):
            for x in range(x0, x1):
                if mask[y][x]:
                    minx = min(minx, x)
                    miny = min(miny, y)
                    maxx = max(maxx, x)
                    maxy = max(maxy, y)
        return (
            max(0, minx - pad),
            max(y0, miny - pad),
            min(w, maxx + 1 + pad),
            min(y1, maxy + 1 + pad),
        )

    def boxes(y0, y1):
        segs, cc = col_segs(y0, y1)
        segs = split_to_6(segs, cc)
        return [refine(a, b, y0, y1) for a, b in segs]

    ivory = boxes(y_top0, y_top1)
    char = boxes(y_bot0, y_bot1)
    if len(ivory) != 6 or len(char) != 6:
        raise RuntimeError(f"expected 6+6 bboxes, got {len(ivory)}+{len(char)}")
    out: dict[str, tuple[int, int, int, int]] = {}
    for i, n in enumerate(NAMES):
        out[f"w-{n}"] = ivory[i]
        out[f"b-{n}"] = char[i]
    return out


def fit_contain(src: Image.Image, box_size: int) -> Image.Image:
    bw, bh = src.size
    scale = min(box_size / bw, box_size / bh)
    nw = max(1, int(round(bw * scale)))
    nh = max(1, int(round(bh * scale)))
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (box_size, box_size), (0, 0, 0, 0))
    canvas.alpha_composite(resized, ((box_size - nw) // 2, (box_size - nh) // 2))
    return canvas
