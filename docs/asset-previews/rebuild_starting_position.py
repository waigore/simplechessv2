#!/usr/bin/env python3
"""Rebuild starting-position preview from cataloged board + piece sheet.

Definitive rules: specs/assets/kinds/piece-sprites.md S5–S9,
specs/assets/kinds/board-backgrounds.md S5–S7. Human summary: README.md
in this folder.

Inputs (kept in repo):
  - catalog SVGs (paths in starting-position.layout.json)
  - starting-position.layout.json (square centers, fill, fit size)
  - this script

Outputs (regenerable; not kept):
  - _work/ rasters, pieces/, pieces-fitted/, starting-position.svg,
    starting-position.preview.png

Usage (from repo root):
  python3 docs/asset-previews/rebuild_starting_position.py
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
PREV = Path(__file__).resolve().parent
LAYOUT_PATH = PREV / "starting-position.layout.json"
WORK = PREV / "_work"
PIECES = WORK / "pieces"
FITTED = WORK / "pieces-fitted"
CHROME = Path("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome")
NAMES = ["K", "Q", "R", "B", "N", "P"]


def chrome_rasterize(svg: Path, out_png: Path, size: int = 2048) -> None:
    if not CHROME.is_file():
        sys.exit(f"Chrome not found at {CHROME}")
    html = WORK / f"_tmp_{svg.stem}.html"
    html.write_text(
        "<!DOCTYPE html><html><body style='margin:0;background:#fff'>"
        f"<img src='{svg.resolve().as_uri()}' width='{size}' height='{size}'/>"
        "</body></html>",
        encoding="utf-8",
    )
    subprocess.run(
        [
            str(CHROME),
            "--headless",
            "--disable-gpu",
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


def load_layout() -> dict:
    if not LAYOUT_PATH.is_file():
        sys.exit(f"missing layout (board S7): {LAYOUT_PATH}")
    return json.loads(LAYOUT_PATH.read_text())


def main() -> None:
    layout = load_layout()
    xs = layout["square_centers_x"]
    ys = layout["square_centers_y"]
    sq = float(layout["square_size"])
    fill = float(layout["piece_fill"])
    box = int(sq * fill)
    fit_size = int(layout["fit_size_px"])
    back = list(layout["back_rank_order"])
    board_svg = ROOT / layout["sources"]["board_svg"]
    sheet_svg = ROOT / layout["sources"]["piece_sheet_svg"]
    if not board_svg.is_file() or not sheet_svg.is_file():
        sys.exit(f"missing catalog SVG: {board_svg} or {sheet_svg}")

    if WORK.exists():
        shutil.rmtree(WORK)
    PIECES.mkdir(parents=True)
    FITTED.mkdir(parents=True)

    sheet_png = WORK / "style-anchor-sheet-chrome.png"
    board_png = WORK / "board-chrome.png"
    chrome_rasterize(sheet_svg, sheet_png)
    chrome_rasterize(board_svg, board_png)

    sheet = flood_clear_background(Image.open(sheet_png))
    sheet.save(WORK / "style-anchor-sheet-transparent.png")
    bboxes = detect_bboxes(sheet)

    for key, bb in bboxes.items():
        crop = sheet.crop(bb)
        crop.save(PIECES / f"{key}.png")
        fit_contain(crop, fit_size).save(FITTED / f"{key}.png")

    board = Image.open(board_png).convert("RGBA")
    out = board.copy()

    def paste(f: int, rt: int, key: str) -> None:
        piece = Image.open(FITTED / f"{key}.png").convert("RGBA").resize(
            (box, box), Image.Resampling.LANCZOS
        )
        cx, cy = xs[f], ys[rt]
        out.alpha_composite(piece, (int(cx - box / 2), int(cy - box / 2)))

    for f, name in enumerate(back):
        paste(f, 0, f"b-{name}")
    for f in range(8):
        paste(f, 1, "b-P")
    for f in range(8):
        paste(f, 6, "w-P")
    for f, name in enumerate(back):
        paste(f, 7, f"w-{name}")

    preview = PREV / "starting-position.preview.png"
    out.save(preview)

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 2048 2048" width="2048" height="2048">',
        "  <title>Preview: starting position — white bottom, black top</title>",
        f'  <image href="../board-backgrounds/{board_svg.name}" x="0" y="0" width="2048" height="2048"/>',
    ]
    for f, name in enumerate(back):
        key = f"b-{name}"
        x, y = xs[f] - box / 2, ys[0] - box / 2
        lines.append(
            f'  <image href="_work/pieces-fitted/{key}.png" x="{x:.2f}" y="{y:.2f}" width="{box}" height="{box}"/>'
        )
    for f in range(8):
        x, y = xs[f] - box / 2, ys[1] - box / 2
        lines.append(
            f'  <image href="_work/pieces-fitted/b-P.png" x="{x:.2f}" y="{y:.2f}" width="{box}" height="{box}"/>'
        )
    for f in range(8):
        x, y = xs[f] - box / 2, ys[6] - box / 2
        lines.append(
            f'  <image href="_work/pieces-fitted/w-P.png" x="{x:.2f}" y="{y:.2f}" width="{box}" height="{box}"/>'
        )
    for f, name in enumerate(back):
        key = f"w-{name}"
        x, y = xs[f] - box / 2, ys[7] - box / 2
        lines.append(
            f'  <image href="_work/pieces-fitted/{key}.png" x="{x:.2f}" y="{y:.2f}" width="{box}" height="{box}"/>'
        )
    lines.append("</svg>")
    (WORK / "starting-position.svg").write_text("\n".join(lines) + "\n")

    # Preserve authoritative layout fields; record last-run derived metadata locally only.
    derived = {
        "piece_box": box,
        "sheet_bboxes": {k: list(v) for k, v in bboxes.items()},
        "last_preview": "docs/asset-previews/starting-position.preview.png",
        "work_dir": "docs/asset-previews/_work/",
    }
    (WORK / "last-run.json").write_text(json.dumps(derived, indent=2) + "\n")
    print("rebuilt", preview)
    print("work artifacts", WORK)


if __name__ == "__main__":
    main()
