# Trials — page changes against the cold open (#856)

Arms on one export ([`../scripts/make_arms.mjs`](../scripts/make_arms.mjs)), aligned runner
([`../scripts/cold_open_arms.mjs`](../scripts/cold_open_arms.mjs)), three runs each, back to
back: [`logs/series-20261025T014500Z/`](logs/series-20261025T014500Z/).

| Arm | First painted screen | Probe span | Pack requested |
|---|---|---|---|
| shipped | 1.78 / 1.64 / 1.71 s | 9–40 ms | 27–90 ms |
| probe after `startGame()` | 2.16 / 1.78 / 1.61 s | 4–38 ms | 13–76 ms |
| `<link rel=preload>` js+wasm+pck | 1.71 / 1.72 / 1.64 s | 3–4 ms | 6–21 ms (`link`) |
| + audio worklets preloaded | 1.66 / 1.68 / 1.54 s | 3–17 ms | 5–6 ms (`link`) |

**No arm clears the noise.** The probe and the pack download are already overlapped: the pack
fetch is issued 0–1 ms after the first GL context returns, and the pck request 1–30 ms after
that. Moving the probe after `startGame()` pulled the request forward by ≤ ~70 ms; preload links
by the same 20–80 ms. A diagnostic arm with the probe call removed still painted 7.5–7.9 s
under load, so the day's spread, not the shell, owns the absolute number.

**Under heavier load:** served by a Node server instead of `python3 -m http.server`, plain 11.4 s;
with `Content-Encoding: gzip` on the pck, 10.5 / 9.5 s with the decompress inside the pack
window (1.6 s plain, 2.0–2.6 s gzip) — a real saving paid back on the main thread.

**Rejected:** a custom shell that calls `startGame()` before the probe. It measured within
noise of the shipped page (9.84 s vs 9.94 s on a load-heavy pair) and costs a maintained shell
plus an export check, so `specs/technical/sequences/cold-open.md` is not changed by this run.

**Left open:** the probe's first context is the only seconds-scale phase and is engine template
code; a shell that skips it or defers it moves nothing when the GPU is warm. The 39.5 MB wasm +
9.6 MB pck is a network floor, and unpacking the ambient beds (~3.3 MB pck, no decompress step)
would need an ADR-0014 change first.
