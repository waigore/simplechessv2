"""
Score a #403 capture's screenshots and screencast frames: which screen each image shows,
how bright it is, and when the first painted screen arrived.

Written for #403 because two things the rows need cannot be read from a frame timeline
alone: *when* the published build first painted a screen (the ADR-0001 and ADR-0003
cold-open rows), and *whether* a move actually landed (the header reads
`White to move` / `Black to move`, plus a per-file occupancy grid).

Usage:
    python3 analyse.py <runDir> [<label> ...]

Reads `<label>-NN-*.png` and `move-cast/<label>-cast-NNN.jpg` (or `<label>-cast-NNN.jpg`)
for every label given (default: every label with a `-timeline.json` or `-session.json`),
and writes `<runDir>/analysis/<label>.json` plus a one-line summary per label on stdout.
"""

import glob
import json
import os
import sys

from PIL import Image

# A painted screen has a table-coloured board area or a cream panel; the loading screen is
# near-black with a small pale label. These two means separate them by a wide margin on
# every capture taken for #403 (loading ~1-38, painted ~160-243).
PAINTED_MEAN = 100.0

# Board square centres at 390×844 CSS px, on the published build's shared-play screen.
FILE_A_X = 59.5
RANK_8_Y = 399.5
SQUARE_STEP = 38.75

# A square's own colour is E8D5B5 (light, luma ~216) or 8B5A3C (dark, luma ~93). A piece on
# it is ink at the core and a shape with a pale or ink outline; the two facts that separate a
# piece from an empty square are *how many* pixels inside the square fall well below its own
# colour (ink coverage) and *how much* the square's spread grows (a sprite is not a flat fill).
EMPTY_SPREAD_MAX = 6.0
PIECE_INK_MIN = 0.10


# CSS px are the unit of the tap coordinates; the captures are DPR 2, so every read scales
# the square by `image.size[0] / 390` before cropping.
CSS_WIDTH = 390


def square_contents(image, centre):
    """`-` for an empty square, `p` for one carrying a piece sprite, at `centre` (CSS px)."""
    scale = image.size[0] / CSS_WIDTH
    box = tuple(round(value * scale) for value in (
        centre[0] - 12, centre[1] - 12, centre[0] + 12, centre[1] + 12,
    ))
    crop = image.crop(box).convert('L')
    values = list(crop.get_flattened_data())
    mean = sum(values) / len(values)
    spread = (sum((value - mean) ** 2 for value in values) / len(values)) ** 0.5
    if spread <= EMPTY_SPREAD_MAX:
        return '-'
    ink = sum(1 for value in values if value < mean - 40) / len(values)
    return 'p' if ink >= PIECE_INK_MIN else '-'


def square_occupancy(image):
    """For every square, `p` if a piece sprite covers it, `-` if empty; rank 8 first."""
    return [
        ''.join(
            square_contents(image, (round(FILE_A_X + file_index * SQUARE_STEP),
                                    round(RANK_8_Y + (8 - rank) * SQUARE_STEP)))
            for file_index in range(8)
        )
        for rank in range(8, 0, -1)
    ]


def mean_luma(image):
    small = image.convert('L').resize((97, 211))
    data = list(small.get_flattened_data())
    return round(sum(data) / len(data), 1)


def analyse_label(run_dir, label):
    out_dir = os.path.join(run_dir, 'analysis')
    os.makedirs(out_dir, exist_ok=True)
    shots = sorted(glob.glob(os.path.join(run_dir, f'{label}-[0-9][0-9]-*.png')))
    cast = sorted(glob.glob(os.path.join(run_dir, 'move-cast', f'{label}-cast-*.jpg')))
    if not cast:
        cast = sorted(glob.glob(os.path.join(run_dir, f'{label}-cast-*.jpg')))
    timeline_path = os.path.join(run_dir, f'{label}-timeline.json')
    timeline = None
    if os.path.exists(timeline_path):
        with open(timeline_path, encoding='utf-8') as handle:
            timeline = json.load(handle)

    readings = []
    for path in shots:
        with Image.open(path) as image:
            image = image.convert('RGB')
            readings.append({
                'file': os.path.relpath(path, run_dir),
                'mean': mean_luma(image),
                'occupancy': square_occupancy(image),
                'size': list(image.size),
            })

    cast_readings = []
    for path in cast:
        with Image.open(path) as image:
            image = image.convert('RGB')
            # Screencast frames are 390×844; the PNGs are 780×1688 (DPR 2).
            scale = image.size[0] / 390.0
            scaled = image.resize((390, 844)) if scale != 1 else image
            cast_readings.append({
                'file': os.path.relpath(path, run_dir),
                'mean': mean_luma(scaled),
                'occupancy': square_occupancy(scaled),
            })

    result = {
        'label': label,
        'shots': readings,
        'cast': {
            'count': len(cast_readings),
            'first_painted_index': next(
                (index + 1 for index, entry in enumerate(cast_readings) if entry['mean'] >= PAINTED_MEAN),
                None,
            ),
            'last_loading_index': next(
                (len(cast_readings) - index for index, entry in enumerate(reversed(cast_readings))
                 if entry['mean'] < PAINTED_MEAN),
                None,
            ),
        },
        'timeline': {
            'moveAtMs': timeline.get('moveAtMs'),
            'windows': timeline.get('windows'),
            'overall': timeline.get('overall'),
        } if timeline else None,
    }
    with open(os.path.join(out_dir, f'{label}.json'), 'w', encoding='utf-8') as handle:
        json.dump(result, handle, indent=2)
        handle.write('\n')

    shot_summary = ' | '.join(
        f"{os.path.basename(entry['file'])} mean={entry['mean']}" for entry in readings
    )
    header = ''
    if readings:
        final = readings[-1]['occupancy']
        header = f" final-occupancy={' | '.join(final)}"
    print(f"{label}: shots={len(readings)}{header}")
    print(f"  {shot_summary}")
    if cast_readings:
        print(
            f"  cast frames={result['cast']['count']} "
            f"first-painted={result['cast']['first_painted_index']} "
            f"last-loading={result['cast']['last_loading_index']}"
        )
    return result


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    run_dir = sys.argv[1]
    labels = sys.argv[2:]
    if not labels:
        labels = sorted({
            os.path.basename(path)[: -len('-timeline.json')]
            for path in glob.glob(os.path.join(run_dir, '*-timeline.json'))
        } | {
            os.path.basename(path)[: -len('-session.json')]
            for path in glob.glob(os.path.join(run_dir, '*-session.json'))
        })
    for label in labels:
        analyse_label(run_dir, label)
    return 0


if __name__ == '__main__':
    sys.exit(main())
