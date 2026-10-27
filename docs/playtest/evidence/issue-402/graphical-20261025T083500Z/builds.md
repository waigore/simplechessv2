# Builds under test

One build, read from one source: the published URL. No export fallback is used anywhere
in this run, so every byte reading below is a published reading.

## Published — `ad9c04d`

| Field | Value | How it was read |
|---|---|---|
| URL | `https://waigore.github.io/simplechessv2/` | `GET`, `200` |
| Commit | `ad9c04d8f09e6b9abff88ac1abded2f5ad34721a` | newest `completed/success` `Web release` run on `main` |
| Attributing run | **`40176551606`**, `Release export` + `Deploy to Pages` green, 2026-10-25T08:25:24Z | runs API, `branch=main&status=success` |
| Pages deployment | `7310604017` (08:25:55Z) | deployments API |
| #647 repair present | `bccdb1c` is an ancestor | `git merge-base --is-ancestor` |
| `index.pck` | 9 364 800 B served = 9 364 800 B configured | `GET` + `GODOT_CONFIG.fileSizes` |
| `index.pck` sha256 | `2954319b397a3fdb3d6cdcc98ef714bbef091467cad7ee428698ba3293754a8f` | download |
| `index.wasm` | 39 514 754 B | `GET` + `GODOT_CONFIG` |
| Threads / canvas | `GODOT_THREADS_ENABLED = false`, `canvasResizePolicy 2` | `index.html` |

The served size and the configured size agree, so the URL serves the `ad9c04d` export
and not a stale one. The superseded run read `c5b8189` ([superseded.md](superseded.md)).

## Export file list, recovered from the served pack

Every `res://` string in `index.pck` whose four preceding bytes carry its own length is
a path-table row. The walk finds **80** unique paths:

| Group | Count |
|---|---|
| `res://game_assets/…` (backgrounds, 7 fonts, icons, piece sprites) | **35** |
| `game/*.gd` scripts | 37 |
| `res://audio_runtime/*.ogg` | 7 |
| `.godot/imported/` remaps | 0 |

So the asset-root repair is in the build the URL serves. This is a byte-level reading:
it says the assets ship, not that a piece is drawn.

## Transports on the served build

| Check | Code in `ad9c04d` | Consequence |
|---|---|---|
| Advice | `advice_endpoint` / `advice_api_key` default `""`; `_advice_available()` needs both | Advice never fetches on the release (ADR-0015, #505) |
| Puzzle deal | `_puzzle_sim_factory()` returns `null` without seams; `is_available()` needs `T9` + `T10` | No deal is read on the release (earlier instance #655) |

## Environment

- Linux x86_64 container, Intel Xeon Skylake, 4 vCPU, 7.9 GiB RAM, no GPU device.
- Capture browser: Puppeteer Chrome for Testing `156.0.8078.47` — **segfaults at
  `execve`**, so no rendered reading was possible ([logs/browser-probe.md](logs/browser-probe.md)).
- Viewport was configured (390×844 CSS, DPR 2, touch) but never rendered.
