#!/usr/bin/env python3
"""Derive interface surfaces and icons from the SS1 style-anchor sheets.

Local only: split structured SVG rects, or group icon paths left to right.
No Recraft or other generative call. Sources:
  game_assets/interface-art/style-anchor-sheet.svg
  game_assets/icons/style-anchor-sheet.svg

Writes:
  game_assets/interface-art/panel-surface.svg  (UIS.F1, surface role UIS.C1)
  game_assets/interface-art/chip-surface.svg   (UIS.F2, surface role UIS.C1)
  game_assets/icons/<subject>.svg              (24×24 grid, PAL.C9 ink)

Usage (from repo root):
  python3 docs/asset-previews/derive_ui_surfaces.py
"""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

NS = "http://www.w3.org/2000/svg"
INK = "#2C2A28"  # PAL.C9
GRID = 24
PAD = 2.0  # art units; glyph sits inside the 24 grid (UIS.I1)
ICON_BUDGET = 20 * 1024
SURFACE_BUDGET = 100 * 1024

# Sheet prompt order, left to right. V5 is the single Advice glyph.
ICONS = (
    "mode-shared",
    "mode-puzzle",
    "quit",
    "back",
    "advice",
)

ROOT = Path(__file__).resolve().parents[2]
IFACE_SHEET = ROOT / "game_assets/interface-art/style-anchor-sheet.svg"
ICON_SHEET = ROOT / "game_assets/icons/style-anchor-sheet.svg"

NUM = r"[-+]?(?:\d+\.\d+|\d+)(?:[eE][-+]?\d+)?"
TOKEN = re.compile(rf"[MmLlHhVvCcSsQqTtAaZz]|{NUM}")


def _tag(el: ET.Element) -> str:
    return el.tag.rsplit("}", 1)[-1]


def _path_bbox(d: str) -> tuple[float, float, float, float]:
    """Axis-aligned bounds of absolute or relative path commands in the sheet."""
    toks = TOKEN.findall(d)
    xs: list[float] = []
    ys: list[float] = []
    i = 0
    cx = cy = sx = sy = 0.0
    cmd: str | None = None

    def read(n: int) -> list[float]:
        nonlocal i
        vals = [float(toks[i + k]) for k in range(n)]
        i += n
        return vals

    while i < len(toks):
        tok = toks[i]
        if tok.isalpha():
            cmd = tok
            i += 1
            if cmd in "Zz":
                cx, cy = sx, sy
            continue
        if cmd is None:
            sys.exit("path data has coordinates before a command")
        rel = cmd.islower()
        kind = cmd.upper()
        if kind == "M":
            x, y = read(2)
            if rel:
                x, y = cx + x, cy + y
            cx, cy = sx, sy = x, y
            xs.append(x)
            ys.append(y)
            cmd = "l" if rel else "L"
        elif kind == "L":
            x, y = read(2)
            if rel:
                x, y = cx + x, cy + y
            cx, cy = x, y
            xs.append(x)
            ys.append(y)
        elif kind == "H":
            x = read(1)[0]
            if rel:
                x = cx + x
            cx = x
            xs.append(x)
            ys.append(cy)
        elif kind == "V":
            y = read(1)[0]
            if rel:
                y = cy + y
            cy = y
            xs.append(cx)
            ys.append(y)
        elif kind == "C":
            x1, y1, x2, y2, x, y = read(6)
            if rel:
                x1, y1 = cx + x1, cy + y1
                x2, y2 = cx + x2, cy + y2
                x, y = cx + x, cy + y
            xs.extend((x1, x2, x))
            ys.extend((y1, y2, y))
            cx, cy = x, y
        elif kind == "Z":
            cx, cy = sx, sy
        else:
            sys.exit(f"icon sheet uses an unsupported path command {cmd}")
    if not xs:
        sys.exit("empty path")
    return min(xs), min(ys), max(xs), max(ys)


def _fmt(n: float) -> str:
    return f"{n:.4f}".rstrip("0").rstrip(".")


def _is_white(fill: str | None) -> bool:
    if not fill:
        return False
    norm = fill.replace(" ", "").lower()
    return norm in {"#fff", "#ffffff", "white", "rgb(255,255,255)"}


def _is_canvas(box: tuple[float, float, float, float]) -> bool:
    x0, y0, x1, y1 = box
    return (x1 - x0) > 1800 and (y1 - y0) > 1800


def derive_icons() -> None:
    root = ET.parse(ICON_SHEET).getroot()
    glyphs: list[dict] = []
    for el in root:
        if _tag(el) != "path":
            sys.exit(f"icon sheet has unexpected <{_tag(el)}>")
        box = _path_bbox(el.get("d") or "")
        if _is_canvas(box):
            continue
        x0, y0, x1, y1 = box
        glyphs.append(
            {
                "d": el.get("d") or "",
                "white": _is_white(el.get("fill")),
                "box": box,
                "cx": (x0 + x1) / 2,
                "order": len(glyphs),
            }
        )
    glyphs.sort(key=lambda g: g["cx"])
    if len(glyphs) < len(ICONS):
        sys.exit(f"expected at least {len(ICONS)} icon paths, found {len(glyphs)}")
    gaps = [(glyphs[i + 1]["cx"] - glyphs[i]["cx"], i) for i in range(len(glyphs) - 1)]
    splits = sorted(idx for _, idx in sorted(gaps, reverse=True)[: len(ICONS) - 1])
    groups: list[list[dict]] = []
    start = 0
    for idx in splits:
        groups.append(glyphs[start : idx + 1])
        start = idx + 1
    groups.append(glyphs[start:])
    if len(groups) != len(ICONS) or any(not group for group in groups):
        sys.exit("icon paths did not form five left-to-right glyphs")

    out_dir = ROOT / "game_assets/icons"
    for name, group in zip(ICONS, groups, strict=True):
        x0 = min(g["box"][0] for g in group)
        y0 = min(g["box"][1] for g in group)
        x1 = max(g["box"][2] for g in group)
        y1 = max(g["box"][3] for g in group)
        bw, bh = x1 - x0, y1 - y0
        span = max(bw, bh)
        if span <= 0:
            sys.exit(f"{name} has an empty bounds")
        scale = (GRID - 2 * PAD) / span
        tx = (GRID - bw * scale) / 2 - x0 * scale
        ty = (GRID - bh * scale) / 2 - y0 * scale
        holes = [g for g in group if g["white"]]
        solids = sorted((g for g in group if not g["white"]), key=lambda g: g["order"])
        # A white subpath inside its containing ink path is a knockout (even-odd),
        # so the ship file stays one PAL.C9 ink and can be tinted.
        used_holes: set[int] = set()
        parts: list[str] = []
        for solid in solids:
            sx0, sy0, sx1, sy1 = solid["box"]
            extra = []
            for hi, hole in enumerate(holes):
                if hi in used_holes:
                    continue
                hx0, hy0, hx1, hy1 = hole["box"]
                if hx0 >= sx0 and hy0 >= sy0 and hx1 <= sx1 and hy1 <= sy1:
                    extra.append(hole["d"])
                    used_holes.add(hi)
            rule = ' fill-rule="evenodd"' if extra else ""
            d = " ".join([solid["d"], *extra])
            parts.append(f'<path{rule} d="{d}"/>')
        if len(used_holes) != len(holes):
            sys.exit(f"{name} has a white path that is not a hole in an ink shape")
        body = "\n    ".join(parts)
        svg = (
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="{NS}" viewBox="0 0 {GRID} {GRID}" width="{GRID}" height="{GRID}">\n'
            f'  <g fill="{INK}" transform="translate({_fmt(tx)} {_fmt(ty)}) scale({_fmt(scale)})">\n'
            f"    {body}\n"
            "  </g>\n"
            "</svg>\n"
        )
        if "<text" in svg:
            sys.exit(f"{name} would bake glyphs")
        dest = out_dir / f"{name}.svg"
        dest.write_text(svg, encoding="utf-8")
        size = dest.stat().st_size
        if size > ICON_BUDGET:
            sys.exit(f"{name} is {size} bytes, over the {ICON_BUDGET} budget")
        print(f"icons/{name}.svg\t{size}")


def derive_surfaces() -> None:
    root = ET.parse(IFACE_SHEET).getroot()
    defs = next((el for el in root if _tag(el) == "defs"), None)
    if defs is None:
        sys.exit("interface sheet is missing defs")
    grads = {el.get("id"): el for el in defs if _tag(el) == "linearGradient" and el.get("id")}
    rects = [el for el in root if _tag(el) == "rect" and el.get("fill") != "#FFFFFF"]
    panel = [el for el in rects if el.get("width") == "960"]
    chip = [el for el in rects if el.get("width") == "640"]
    if len(panel) != 3 or len(chip) != 1:
        sys.exit(f"expected 3 panel rects and 1 chip rect, found {len(panel)} and {len(chip)}")

    def write(name: str, grad_ids: tuple[str, ...], shapes: list[ET.Element], budget_note: str) -> None:
        sw = max(float(el.get("stroke-width") or "0") for el in shapes) / 2
        x = min(float(el.get("x") or "0") for el in shapes) - sw
        y = min(float(el.get("y") or "0") for el in shapes) - sw
        right = max(float(el.get("x") or "0") + float(el.get("width") or "0") for el in shapes) + sw
        bottom = max(float(el.get("y") or "0") + float(el.get("height") or "0") for el in shapes) + sw
        grad_xml = []
        for gid in grad_ids:
            if gid not in grads:
                sys.exit(f"missing gradient {gid}")
            raw = ET.tostring(grads[gid], encoding="unicode")
            raw = raw.replace("ns0:", "").replace(":ns0", "")
            raw = raw.replace(f' xmlns="{NS}"', "")
            grad_xml.append(raw.strip())
        shape_xml = []
        for el in shapes:
            attrs = " ".join(f'{k}="{v}"' for k, v in el.attrib.items())
            shape_xml.append(f"<rect {attrs}/>")
        svg = (
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="{NS}" viewBox="{_fmt(x)} {_fmt(y)} {_fmt(right - x)} {_fmt(bottom - y)}">\n'
            "  <defs>\n"
            + "".join(f"    {line}\n" for line in grad_xml)
            + "  </defs>\n"
            + "".join(f"  {line}\n" for line in shape_xml)
            + "</svg>\n"
        )
        if "<text" in svg:
            sys.exit(f"{name} would bake copy")
        dest = ROOT / "game_assets/interface-art" / f"{name}.svg"
        dest.write_text(svg, encoding="utf-8")
        size = dest.stat().st_size
        if size > SURFACE_BUDGET:
            sys.exit(f"{name} is {size} bytes, over the {SURFACE_BUDGET} budget ({budget_note})")
        print(f"interface-art/{name}.svg\t{size}")

    write("panel-surface", ("panelFill", "panelSheen", "panelInner"), panel, "AK-interface-art.B1")
    write("chip-surface", ("chipFill",), chip, "AK-interface-art.B1")


def main() -> None:
    if not IFACE_SHEET.is_file() or not ICON_SHEET.is_file():
        sys.exit("missing style-anchor sheet")
    derive_surfaces()
    derive_icons()


if __name__ == "__main__":
    main()
