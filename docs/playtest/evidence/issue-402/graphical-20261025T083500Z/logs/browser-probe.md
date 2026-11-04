# Browser probe — can this host run the published build?

Run before any `quality.md` row was read, so a row that could not be read names the
host, not the product.

- **Command**: `node probe-browser.mjs .` in this folder (`graphical-20261025T083500Z`),
  Node `v26.12.0`, Linux x86_64 (Intel Xeon Skylake, 4 vCPU, 7.9 GiB RAM, no `/dev/dri`
  GPU), Ubuntu 24.04.4, kernel 6.8.0.
- **Browser under probe**: the tree's own capture browser — Puppeteer's Chrome for
  Testing `156.0.8078.47` at
  `~/.cache/puppeteer/chrome/linux-156.0.8078.47/chrome-linux64/chrome` (the path
  `drive.mjs` discovers automatically).
- **Result**: **the browser binary cannot start on this host.** Chrome dies with
  `SIGSEGV` before it prints `--version`, reported by `strace` as
  `execve(...) = -1 EFAULT (Bad address)` — the process is killed while the kernel
  reads the executable image, so nothing but a platform mismatch can be blamed on the
  page, the build, or the driver. Three flag sets (bare, `--no-sandbox`,
  `--headless=new --no-sandbox --disable-gpu`), `xvfb-run`, and repeated runs all
  return the same signal. No other browser is installed on the host (`chromium`,
  `google-chrome`, `firefox`, Playwright, and `puppeteer-core` are all absent;
  `godot` is not installed either).
- **Consequence**: no cold open, no move, no screenshot, and no timing can be taken on
  this host. The run folder carries **no screenshot of the build**: Chrome never
  produced one, and an image that is not the build would be a proxy pass.

What the probe therefore establishes is negative and load-bearing: #402's re-record is
a **`ENV.2` graphical reading in a real browser**, and this dispatch (agent-orc parallel
id 2, `.orc/worktrees/issue-workflow-implement-agent-2-…`) has no working browser.
That is a property of the seat, not of `ad9c04d`.

## What was read on the served build without a browser

The published build's bytes are available to `curl` and are what a browser would load,
so the parts of a row that are properties of the served artifact — not of rendering —
can still be read and are recorded in [builds.md](../builds.md) and
[readings.md](../readings.md):

| Reading | Method | Value |
|---|---|---|
| Served commit | `GET /repos/…/actions/workflows/393446617/runs?branch=main&status=success` + Pages deployment | `ad9c04d`, `Web release` run `40176551606` |
| Export identity | `GET index.html` → `GODOT_CONFIG` | `fileSizes.index.pck` `9364800`, `index.wasm` `39514754` |
| `index.pck` served | `GET index.pck` → size + `sha256` | `9 364 800` B, `2954319b…4a8f` |
| Asset root in the pack | GDPC v4 header walk over the served `index.pck` | `game_assets/*` entries: **0** |
| Advice transport on release | `game/main_release.tscn` has no seam node → `T9`/`T10` empty | unconfigured → Advice never fetches |
| Puzzle transport on release | same (`_puzzle_sim_factory()` returns `null` without seams; `T9`/`T10` empty) | no deal is ever read |

The pack walk and the transport facts say `ad9c04d` serves an export whose asset group,
advice peer, and puzzle deal source are all absent or unconfigured — the same posture
the 2026-10-25T031500Z record found on `c5b8189`, now read as bytes on the current
served commit rather than inferred from a screen.
