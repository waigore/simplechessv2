"""Read the mode-pick button boxes off a 390x844 DPR-3 frame.

Prints, in CSS px, every full-width painted border row and the panel's left and
right edges, so two frames can be compared for a layout shift. Read-only.

    python3 scripts/boxes.py <png> [<png> ...]
"""
import sys
from PIL import Image

PANEL_X0, PANEL_X1 = 260, 910  # image px, inside the panel's own column
DARK = 235


def measure(path):
    im = Image.open(path).convert("L")
    width, height = im.size
    px = im.load()
    rows = []
    for y in range(height):
        dark = sum(1 for x in range(PANEL_X0, PANEL_X1, 2) if px[x, y] < DARK)
        if dark > (PANEL_X1 - PANEL_X0) / 2 * 0.85:  # a full-width painted line
            rows.append(round(y / 3, 2))
    # Collapse adjacent scan lines (a 1 px border spans 2-3 image rows).
    merged = []
    for row in rows:
        if merged and row - merged[-1][-1] <= 0.5:
            merged[-1].append(row)
        else:
            merged.append([row])
    return [round(sum(group) / len(group), 2) for group in merged]


for path in sys.argv[1:]:
    print(f"{path}: {measure(path)}")
