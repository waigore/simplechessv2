"""Protanopia and deuteranopia copies of the #641 captures.

Every simulated image is derived from one un-simulated capture in
`screenshots/`, so a reviewer can pair the three one-to-one. The reader is the
full-severity Machado, Oliveira & Fernandes (2009) simulation matrix applied in
linear RGB; nothing else is changed (no sharpening, no palette snapping).

Usage: python3 simulate.py [screenshots dir]
"""
from pathlib import Path
import sys

import numpy as np
from PIL import Image

# Machado et al. 2009, severity 1.0, applied to linear-light RGB.
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

# Row frames plus the two turn frames; context screens stay un-simulated.
ROW_FRAMES = [
    "shared-turn-a",
    "shared-turn-b",
    "shared-selection",
    "shared-refused-00",
    "shared-destinations-empty",
    "shared-destinations-capture",
    "shared-check",
    "shared-last-move",
    "shared-advice",
    "puzzle-side",
    "puzzle-side-steady",
]


def srgb_to_linear(rgb):
    rgb = rgb / 255.0
    return np.where(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055) ** 2.4)


def linear_to_srgb(lin):
    lin = np.clip(lin, 0.0, 1.0)
    return np.where(lin <= 0.0031308, lin * 12.92, 1.055 * lin ** (1 / 2.4) - 0.055)


def simulate(image, matrix):
    lin = srgb_to_linear(image.astype(np.float64))
    out = lin @ matrix.T
    return np.round(linear_to_srgb(out) * 255.0).astype(np.uint8)


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "screenshots")
    for name in ROW_FRAMES:
        source = root / f"{name}.png"
        image = np.asarray(Image.open(source).convert("RGB"))
        for label, matrix in MATRICES.items():
            Image.fromarray(simulate(image, matrix)).save(root / f"{name}-{label}.png")
        print(f"{name}: {source.name} -> {' '.join(f'{name}-{k}.png' for k in MATRICES)}")


if __name__ == "__main__":
    main()
