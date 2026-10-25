"""Machine readings behind the #641 verdicts.

For every row frame this reports, inside the painted board:
  * which PAL accents are on the board and how many pixels carry each,
  * the WCAG contrast of each accent against the light (C1) and dark (C2)
    square, as drawn and under each colour-blind simulation,
  * whether the accent still differs from the squares at all after simulation.

A square-level reading is reported for the squares the run names (e2, e3, e4,
e5, f5), so "no mark on this square" is a measurement, not an impression.

Usage: python3 readings.py [screenshots dir] > readings.json
"""
from pathlib import Path
import json
import sys

import numpy as np
from PIL import Image

C1 = (0xE8, 0xD5, 0xB5)  # light square
C2 = (0x8B, 0x5A, 0x3C)  # dark square
C5 = (0x5C, 0x3A, 0x2A)  # table wood
BASE = {"C1": C1, "C2": C2, "C3": (0xF5, 0xF0, 0xE6), "C4": (0x2C, 0x2A, 0x28),
        "C5": C5, "C9": (0x2C, 0x2A, 0x28), "C10": (0xF7, 0xF1, 0xE8)}
ACCENTS = {"C6": (0xB8, 0x94, 0x0C), "C7": (0x53, 0xA2, 0xBE),
           "C8": (0xC2, 0x8A, 0x86), "C11": (0x6E, 0xA7, 0x46)}

# Board as painted at 390×844 CSS / DPR 2 (screenshots are 780×1688).
BOARD = (78, 752, 702, 1376)
SQUARE = 78
FILES = "abcdefgh"

MATRICES = {
    "protanopia": np.array([
        [0.152286, 1.052583, -0.204868],
        [0.114503, 0.786281, 0.099216],
        [-0.003882, -0.048116, 1.051998],
    ]),
    "deuteranopia": np.array([
        [0.367322, 0.860646, -0.227968],
        [0.280085, 0.672501, 0.047413],
        [-0.011820, 0.042940, 0.968881],
    ]),
}

FRAMES = [
    "shared-turn-a", "shared-turn-b", "shared-selection", "shared-refused-00",
    "shared-refused-settled", "shared-destinations-empty", "shared-destinations-capture",
    "shared-check", "shared-last-move", "shared-advice", "puzzle-side",
    "puzzle-side-steady",
]
NAMED_SQUARES = ["e2", "e3", "e4", "e5", "f5", "g1", "f3", "h3", "e8"]


def srgb_to_linear(rgb):
    rgb = np.asarray(rgb, dtype=np.float64) / 255.0
    return np.where(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055) ** 2.4)


def luminance(rgb):
    lin = srgb_to_linear(rgb)
    return float(0.2126 * lin[..., 0] + 0.7152 * lin[..., 1] + 0.0722 * lin[..., 2])


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return round((hi + 0.05) / (lo + 0.05), 2)


def simulate(rgb, matrix):
    lin = srgb_to_linear(rgb)
    out = np.clip(lin @ matrix.T, 0.0, 1.0)
    return np.where(out <= 0.0031308, out * 12.92, 1.055 * out ** (1 / 2.4) - 0.055) * 255.0


def square_box(name):
    col = FILES.index(name[0])
    row = 8 - int(name[1])
    x0 = BOARD[0] + SQUARE * col
    y0 = BOARD[1] + SQUARE * row
    return (x0, y0, x0 + SQUARE, y0 + SQUARE)


def accent_census(board):
    """Non-base colours, quantised, that carry at least 20 board pixels."""
    flat = board.reshape(-1, 3).astype(int)
    quant = (flat // 4) * 4
    colours, counts = np.unique(quant, axis=0, return_counts=True)
    out = {}
    for rgb, count in zip(colours, counts):
        if count < 20:
            continue
        near = {k: int(np.abs(np.asarray(rgb) - np.asarray(v)).max()) for k, v in BASE.items()}
        if min(near.values()) <= 24:
            continue
        label = "other"
        for key, value in ACCENTS.items():
            if np.abs(np.asarray(rgb) - np.asarray(value)).max() <= 16:
                label = key
        out[f"#{rgb[0]:02X}{rgb[1]:02X}{rgb[2]:02X}"] = {"count": int(count), "accent": label}
    return dict(sorted(out.items(), key=lambda kv: -kv[1]["count"])[:8])


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "screenshots")
    report = {"board_px": BOARD, "square_px": SQUARE, "frames": {}}
    for name in FRAMES:
        image = np.asarray(Image.open(root / f"{name}.png").convert("RGB")).astype(int)
        board = image[BOARD[1]:BOARD[3], BOARD[0]:BOARD[2]]
        entry = {"accents_on_board": accent_census(board), "named_squares": {}}
        for square in NAMED_SQUARES:
            x0, y0, x1, y1 = square_box(square)
            patch = image[y0:y1, x0:x1]
            colours, counts = np.unique(patch.reshape(-1, 3), axis=0, return_counts=True)
            accents = {}
            for key, value in ACCENTS.items():
                mask = np.abs(colours - np.asarray(value)).max(axis=1) <= 16
                total = int(counts[mask].sum())
                if total:
                    accents[key] = total
            entry["named_squares"][square] = accents
        report["frames"][name] = entry

    # Refused place: what the C8 flash adds over the already-selected board.
    selected = np.asarray(Image.open(root / "shared-selection.png").convert("RGB")).astype(int)
    refused = np.asarray(Image.open(root / "shared-refused-00.png").convert("RGB")).astype(int)
    inside = np.zeros(refused.shape[:2], dtype=bool)
    inside[BOARD[1]:BOARD[3], BOARD[0]:BOARD[2]] = True
    delta = (np.abs(refused - selected).max(axis=2) > 8) & inside
    ys, xs = np.where(delta)
    report["refused_delta"] = {
        "changed_px_vs_selected_board": int(delta.sum()),
        "box_px": [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())] if len(xs) else None,
        "square": "d7",
        "mean_rgb": [int(round(v)) for v in refused[delta].mean(axis=0)] if len(xs) else None,
        "d7_square_px": list(square_box("d7")),
    }

    # Last move: sample every capture from the moment the move lands.
    window = ["shared-last-move-00", "shared-last-move-01", "shared-last-move-02",
              "shared-last-move-03", "shared-last-move-04", "shared-last-move-05",
              "shared-last-move-06", "shared-last-move-07", "shared-last-move"]
    settled = np.asarray(Image.open(root / "shared-last-move.png").convert("RGB")).astype(int)
    samples = {}
    for name in window:
        image = np.asarray(Image.open(root / f"{name}.png").convert("RGB")).astype(int)
        board = image[BOARD[1]:BOARD[3], BOARD[0]:BOARD[2]]
        accents = {k: int((np.abs(board - np.asarray(v)).max(axis=2) <= 16).sum())
                   for k, v in ACCENTS.items()}
        samples[name] = {
            "accents_on_board": accents,
            "board_px_differing_from_settled": int(
                (np.abs(image[BOARD[1]:BOARD[3], BOARD[0]:BOARD[2]]
                        - settled[BOARD[1]:BOARD[3], BOARD[0]:BOARD[2]]).max(axis=2) > 8).sum()
            ),
        }
    report["last_move_window"] = samples

    report["contrast"] = {}
    for key, value in ACCENTS.items():
        row = {"as_drawn": {"on_C1": contrast(value, C1), "on_C2": contrast(value, C2)}}
        for label, matrix in MATRICES.items():
            mark = simulate(value, matrix)
            light = simulate(np.asarray(C1, dtype=float), matrix)
            dark = simulate(np.asarray(C2, dtype=float), matrix)
            row[label] = {
                "mark_rgb": [int(round(c)) for c in mark],
                "light_square_rgb": [int(round(c)) for c in light],
                "dark_square_rgb": [int(round(c)) for c in dark],
                "on_C1": contrast(mark, light),
                "on_C2": contrast(mark, dark),
            }
        report["contrast"][key] = row
    report["squares"] = {
        "C1_luminance": round(luminance(C1), 4),
        "C2_luminance": round(luminance(C2), 4),
        "C1_vs_C2": contrast(C1, C2),
    }
    json.dump(report, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
