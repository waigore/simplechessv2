# Manifest — #792 mark-form capture, 360 × 640

- **Issue**: #792 — render the landed `PAL.K8` and `PAL.K9` marks in `game/`
- **Environment**: `graphical` — local Godot 4.7.2 (`4.7.2.stable.official.ed1daf0bf`), OpenGL 4.1 Metal on macOS arm64 (Apple M5), window 360 × 640, `content_scale_mode` disabled so the canvas is the 36 px-square frame `PRJ.P1` names
- **Build**: the `issue/792-*` branch at the commit this folder lands with; `BoardPresentation` driven directly with the `play` asset group resolved from `asset_catalog/` (`AssetResolver.resolve_group("play")`), not a Web export
- **Coverage mode**: `mark-forms-only` — one frame, every mark the task changes, no interaction
- **Protocol**: **N/A** — no `SIT` row and no filmed-seating step in `specs/playtest/` or `docs/` specifies a mark-form capture. This frame is the deliverable's own evidence, not a protocol run.

## Results

| `PAL.K9` form (`rules.md` *Hue removed*) | Square in the frame | Verdict |
|---|---|---|
| Closed ring (selection) | e2 | pass — 0.06 stroke, 2.16 px |
| Solid disk (empty destination) | e3, e4 | pass — `C11`, πr² = 0.407 square |
| Four corner pairs (capture destination) | c6 | pass — 8 strokes, 0.06 × 0.56, 0.2688 square |
| Parallel fill (refused place) | d2 | pass — `C8` hatch inside the ring, on the square, no cream |
| Corner L (check) | e8 | pass — `C10` L-frame on the cream foreground, `C8` cue riding it |
| Edge-midpoint brackets (Advice) | d5, e4 | pass — `C7` on the square's cream foreground |
| Soft band (last move, from) | a1 | pass — `C7`, three translucent layers, open, no keyline |
| Cream ticks (last move, to) | b3 | pass — four `C10` corner Ls on the square's cream foreground |

No defect is filed from this frame: every form matches the landed row it draws.
The three spec conflicts the task body names are filed as `type:defect` issues against
[#888](https://github.com/waigore/simplechessv2/issues/888), the open owner of `rules-k9.md`
(spec chapters are defects per [`docs/issues/requirements.md`](../../../../issues/requirements.md)):
[#919](https://github.com/waigore/simplechessv2/issues/919) (check row keeps `X4`),
[#920](https://github.com/waigore/simplechessv2/issues/920) (`0.04` tick under the `UIS.I1` floor), and
[#918](https://github.com/waigore/simplechessv2/issues/918) (bracket bound with no size that meets it).

## Paths

- `screenshots/marks-360x640.png` — the frame as drawn
- `screenshots/marks-360x640-hue-removed.png` — the same frame with hue removed (`PAL.K9` *Hue removed*)
- `logs/capture.log` — the run's console output
