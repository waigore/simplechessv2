# Corrections — issue #616 graphical evidence, against defect #742

Index: [`manifest.md`](manifest.md) · Evidence: [`run.md`](run.md), [`checks.md`](checks.md).

#742 failed #616's acceptance on its graphical folder. This run measures each of #742's claims against
a fresh rendering of the same build on this host, and records which held.

## 1. "The folder is a headless session labelled graphical" — not reproduced

The claim rests on screenshots that "decode to near-blank images" (149–324 distinct colours) and on a
`Metal` line that a headless session cannot print.

- **Colours.** The committed files carry **552–4003** distinct colours, not 149–324. The lowest is
  `w1280-01-mode-pick.png` at 552, which is a sparse cream-on-cream screen; the dialogs carry 1133–4003.
- **Content.** They draw legible copy — "Local", "Untimed", "Puzzles", the seat controls, the confirm
  prompts — and their card borders sit exactly where the recorded geometry puts them.
- **Agreement with a real render.** Re-rendering the same drive on this host reproduces the **same ink
  bounding box in all 19 files**, with grayscale correlation 0.908–0.992 and only 0.9%–2.5% of pixels
  differing by more than 16/255 ([`checks.md`](checks.md) *Comparisons*). A headless session's grabs —
  the ones #742 says it produced itself — do not do that.
- **`Metal`.** The `macOS` / `Metal` lines describe the host the superseded run ran on, which this host
  cannot re-run. They are unverifiable from here rather than disproved. This run records its own
  `X11` / llvmpipe environment from the engine instead.

## 2. "Two screenshots are byte-identical" — true, and not what it was taken to mean

`phone-01-mode-pick.png` and `caps-frame-3239.png` are identical in both folders. That is how the drive
is built: `_capture_caps` runs straight after the phone pass, whose final step leaves mode-pick on
screen, so the liveness capture is a capture of mode-pick. **This run produces the identical pair too**,
from a rendered session. It is not evidence of a fabricated run.

## 3. "The geometry reproduces headless" — true, and expected

`drive_graphical.gd` is a `SceneTree` script that drives `SessionRouter` and measures
`get_global_rect()`. Geometry is layout, and layout is the same with or without a renderer. This run's
18 rows match the superseded folder's 18 rows exactly. Geometry identity was never a signal of a
headless session; the screenshots were, and they hold up (§1).

## 4. "`ENV.2` requires the host's `DisplayServer` to be named" — not a spec requirement

`specs/playtest/tools.md` defines `ENV.2` as "a full rendered session; capture screenshots per
`evidence.md`", and `evidence-manifest.md` asks the Environment field for `headless` or `graphical`.
Neither asks the manifest to name the host or its graphics API. This run names both anyway, from the
engine, so the claim is checkable.

## What this run still changes

The superseded folder's hard-coded output path let a drive write into another run's `screenshots/`,
which is how the environment claim became unfalsifiable in practice. The drive now writes only to its
own folder and fails outright when it runs headless ([`checks.md`](checks.md) *Drive*). The superseded
folder stays in place as history; this folder is the one acceptance cites.
