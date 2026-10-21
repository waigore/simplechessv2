#!/usr/bin/env python3
"""Rebuild starting-position preview from cataloged board + piece sheet.

Definitive rules: specs/assets/kinds/piece-sprites.md S5–S9,
specs/assets/kinds/board-backgrounds.md S5–S7. Human summary: README.md
in this folder. Shared piece steps live in piece_sprite_pipeline.py.

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
import sys
from pathlib import Path

from PIL import Image

from piece_sprite_pipeline import chrome_rasterize, detect_bboxes, fit_contain, flood_clear_background

ROOT = Path(__file__).resolve().parents[2]
PREV = Path(__file__).resolve().parent
LAYOUT_PATH = PREV / "starting-position.layout.json"
WORK = PREV / "_work"
PIECES = WORK / "pieces"
FITTED = WORK / "pieces-fitted"


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
    chrome_rasterize(sheet_svg, sheet_png, WORK)
    chrome_rasterize(board_svg, board_png, WORK)

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
