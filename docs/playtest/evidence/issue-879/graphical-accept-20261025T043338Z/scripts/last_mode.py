"""Measure the mode-pick screen's painted bands below C2 (the Last mode line).

Usage: python3 scripts/last_mode.py <png> [<png> ...]

The mode-pick frame is 1170x2532 (390x844 CSS at DPR 3). C1 is the control at
CSS y 144.83-181.67 and C2 at y 185.83-223.00, as `boxes.py` reads them. The Last
mode affordance sits between C2's bottom and the panel's bottom edge. This prints,
per frame, the rows in that band that carry ink and a digest of the band, so the
line can be located rather than assumed. Read-only.
"""
import hashlib
import sys

from PIL import Image

PANEL_Y0 = 223
PANEL_Y1 = 271
PANEL_X0, PANEL_X1 = 90, 300  # CSS px inside the panel
DARK = 200


def band(image):
    px = image.load()
    rows = []
    for css_y in range(PANEL_Y0, PANEL_Y1):
        y = int(css_y * 3)
        dark = sum(1 for css_x in range(PANEL_X0, PANEL_X1) if px[int(css_x * 3), y] < DARK)
        if dark > 0:
            rows.append((css_y, dark))
    return rows


for path in sys.argv[1:]:
    image = Image.open(path).convert("L")
    rows = band(image)
    print(f"{path}: ink rows {rows} count={len(rows)}")
    if rows:
        y0 = min(row for row, _ in rows)
        y1 = min(max(row for row, _ in rows) + 2, PANEL_Y1)
        crop = image.crop((PANEL_X0 * 3, y0 * 3, PANEL_X1 * 3, y1 * 3))
        print(f"  band CSS y {y0}-{y1}: digest {hashlib.sha256(crop.tobytes()).hexdigest()[:16]}")
