# Source validation — #640 review run

The task's rule: **the source is validated before any pixel is measured** — the manifest
names the commit, the source, and the observation that a board rendered on it. This is
that record. Run: [`../manifest.md`](../manifest.md).

## The source

| Field | Value |
|---|---|
| Source | the **published release URL** `https://waigore.github.io/simplechessv2/` |
| Commit served | `main` `69a03d4` (`69a03d48edf6304e265cf2078112c42e4d022afd`, 2026-10-25 00:25:21 +0000) |
| `Web release` run | [40146630737](https://github.com/waigore/simplechessv2/actions/runs/40146630737) — success, deploying `69a03d48` |
| Served `index.pck` | `200`, `last-modified` 2026-10-25 00:26:08 UTC, 9 572 540 B — the **asset-carrying** size, not 252 144 B |
| Served asset | `game_assets/piece-sprites/k-white.png` → `200`, same `last-modified` |

The served `last-modified` is 43 s after the run started and matches its deploy step. The
site is read from the deployed `index.pck`, never assumed from the newest run.

## The board-rendered observation

Headless Chrome 144 (`--headless=new`, SwiftShader WebGL 2.0) at 390 × 844 CSS px, DPR 2,
780 × 1688 captured, reaching a **fully drawn board**:

| Step | Artefact |
|---|---|
| cold open → mode pick (`Choose how to play`) | `screenshots/board-01-mode-pick.png` |
| `Shared game` | `screenshots/board-02-after-shared.png` |
| setup → `Start` | `screenshots/board-03-after-start.png` |
| the settled board — the un-simulated **control** | `screenshots/board-control.png` |
| the same board 1.2 s later | `screenshots/board-control-b.png` |

What the control shows, and why it validates the pixels:

- **Both squares are painted in the spec hexes**: `#E8D5B5` (C1) and `#8B5A3C` (C2)
  (`readings.json` `swatchMatch`).
- **Thirty-two pieces are drawn**, one per square of the opening position; per-square ink
  histograms show the shipped piece tones either side of each colour
  (`readings.json` `k2.pairs[].tones`), so the piece-art root resolved, not just the
  backdrop.
- **The board frame is measured from its own paint**: 78 capture px square edge (39 CSS
  px), board side 624 (312 CSS), `left` 78, `top` 753, `bottom` 1377.
- **The console carries no asset failure**: `capture-console.log` holds the Godot banner
  and one SwiftShader performance warning; there is **no** `Preload <group> left <n>`
  `approved IDs unresolved` line, no `Error opening file 'game_assets/…'`, and no script
  error.

That last point is decisive: an unresolved preload fails open on **both** profiles
(`game/asset_resolver.gd:134–160` `_preload` → `failed.emit`, no `failed` handler in the
callers at `:41–52`, `_reject` at `:284–300` only warning off the playtest seam). A source
proves itself by drawing a board, and this one does, with its art.

## Verdict

**Validated.** The `K1` and `K2` legs are measured on this source, not `not-judged`. No
`Web Release` export fallback was used, so every pixel verdict is a verdict on the
**published** build, not on an export that "never stands in for" one
(`specs/playtest/procedures.md:19`).

## What this does not cover

- **`TEL.3`**: no `TEL.*` lines exist (#729), so `manifest.md` records `no TEL.3`; a pixel
  measurement takes no session id.
- **Timing**: no cold-open timing is claimed; the ~14 s wait is settle time on a headless
  software-WebGL runner, not a `SIT.4` measurement.
