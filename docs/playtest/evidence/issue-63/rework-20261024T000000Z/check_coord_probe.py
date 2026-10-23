"""PER.R7 check of a headless `DEMO_COORD_PROBE=1` dump for demo #63.

The demo writes, in frame pixels (720x1280, PRJ.P1 at 72 px per board unit):
  frame W H             the frame
  square x0 y0 x1 y1    the 8x8
  ink <label> <band> x0 y0 x1 y1    the glyph ink box of one coordinate label
  band <name> x0 y0 x1 y1           the drawn coordinate band

`ink` boxes are the extent the renderer positions the glyph in (halved glyph
width, ascent + descent about the label centre), so they are conservative
against the band by construction; the graphical autodrive checks real pixels.

Rules (specs/view/perception.md PER.R7):
  - every label's ink box lies inside the band it names,
  - neither band intersects the 8x8,
  - so no label ink can land inside a square or on the 1.28:1 light margin.

A label is reported as inside the 8x8 when its box intersects the square rect.

Usage: python3 check_coord_probe.py <probe.txt>
Exits 1 on any failure.
"""
import sys

SQ_NAMES = {"left": "BevelLipLeftInk", "bottom": "BevelLipBottomInk"}


def rect(parts):
    x0, y0, x1, y1 = (float(v) for v in parts)
    return (x0, y0, x1, y1)


def inside(outer, inner):
    return (outer[0] <= inner[0] and outer[1] <= inner[1]
            and inner[2] <= outer[2] and inner[3] <= outer[3])


def intersects(a, b):
    return not (a[2] <= b[0] or b[2] <= a[0] or a[3] <= b[1] or b[3] <= a[1])


def main(path):
    frame = square = None
    bands, labels = {}, []
    with open(path) as handle:
        for line in handle:
            key, *rest = line.split()
            if key == "frame":
                frame = (0.0, 0.0, float(rest[0]), float(rest[1]))
            elif key == "square":
                square = rect(rest)
            elif key == "band":
                bands[rest[0]] = rect(rest[1:])
            elif key == "ink":
                # Dump line: `ink <label> <band> x0 y0 x1 y1` — the box is the
                # box of THAT label, whose glyph centre is not the box centre.
                labels.append((rest[0], rest[1], rect(rest[2:])))
    problems = []
    if frame is None or square is None:
        problems.append("dump has no frame/square line")
        return problems
    for name in SQ_NAMES.values():
        if name not in bands:
            problems.append("no band %s drawn" % name)
    for name, band in bands.items():
        if square and intersects(band, square):
            problems.append("%s intersects the 8x8 %s: %s" % (name, square, band))
        if not inside(frame, band):
            problems.append("%s leaves the frame %s: %s" % (name, frame, band))
    files = [lab for lab in labels if lab[0] in "abcdefgh"]
    ranks = [lab for lab in labels if lab[0].isdigit()]
    print("frame %s, 8x8 %s, %d labels (%d files, %d ranks)"
          % (frame, square, len(labels), len(files), len(ranks)))
    for text, band_name, box in labels:
        band = bands.get(band_name)
        ok = band is not None and inside(band, box)
        hit = square is not None and intersects(box, square)
        print("  %-2s %-18s box x %.1f y %.1f -> x %.1f y %.1f  %s%s"
              % (text, band_name, box[0], box[1], box[2], box[3],
                 "in band" if ok else "LEAVES BAND",
                 "  INSIDE 8x8" if hit else ""))
        if not ok:
            problems.append("%s label box %s leaves band %s" % (text, box, band))
        if hit:
            problems.append("%s label box %s is inside the 8x8" % (text, box))
    return problems


if __name__ == "__main__":
    found = main(sys.argv[1])
    for problem in found:
        print("FAIL: %s" % problem)
    print("PASS: every label inside its band, no band inside the 8x8"
          if not found else "%d problem(s)" % len(found))
    sys.exit(1 if found else 0)
