# Reproducing the #641 review run

## Commands

```sh
node capture.mjs https://waigore.github.io/simplechessv2/ .   # frames from the served build
python3 simulate.py screenshots                              # protanopia + deuteranopia pairs
python3 readings.py screenshots > readings.json              # every number cited in the folder
```

`capture.mjs` launches headless Chrome with a debugging port, sets a 390 × 844 CSS px / DPR 2 frame
with touch emulation over CDP, walks mode pick → shared setup (`Clock · Blitz`, `Advice` left On) →
shared play → puzzle play, and saves one PNG per surface × signal plus the two bursts it needs:
the refused-place flash (8 captures from the pointer-up) and the moments after a move lands (8
captures). `cdp.mjs` is the dependency-free driver under it; the board is read at x 39–351,
y 376–688 CSS px, one square 39 CSS px, White at the bottom.

`simulate.py` writes `<frame>-protanopia.png` and `<frame>-deuteranopia.png` beside the frame it came
from, using the Machado (2009) full-severity matrices in linear RGB. `readings.py` reports the accent
census per frame, the accent pixels on named squares, the refused-place delta against the already
selected board, the last-move window, and the contrast table.

## Tool versions

Node 22+ (`node --version` was 25.8.0 here), Google Chrome 156 (`CHROME_BIN` overrides the macOS
default path), Python 3 with Pillow and NumPy. No npm or pip package is installed by the run.

## What a rerun must re-establish

- The served commit and its publishing `Web release` run at run time: the served build changes on
  every release push, and the verdicts belong to the build in `manifest.md`, not to `main` generally.
- That the served artifacts did not change under the run — `logs/served-build.txt` holds the digests
  taken before and after.

## What this run does not prove

- One browser (headless Chrome 156, SwiftShader WebGL 2.0), one frame size (390 × 844 CSS, DPR 2), one
  game and one puzzle attempt per surface. Nothing here is a device sweep, and a phone's own display
  in daylight was not read.
- The simulations are a model of severe protanopia and deuteranopia — not a person's reading, and
  not anomalous trichromacy.
- Advice and the puzzle side are unjudged; both need a build that ships an advice endpoint and a
  dealing catalog before those two rows can be read at all.
- The last-move finding is about one move in one game, though nine captures across the first 1.2 s
  make a missed transient mark unlikely.
