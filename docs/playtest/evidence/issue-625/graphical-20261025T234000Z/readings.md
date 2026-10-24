# Readings — #625 probe of the `Web Release` export of `491554e`

Raw: [logs/probe-result.json](logs/probe-result.json), [logs/probe-console.log](logs/probe-console.log),
[logs/probe-network.log](logs/probe-network.log). Driver: [scripts/probe.mjs](scripts/probe.mjs).

## Device the probe ran on — not the device #625 wants

| Fact | Value |
|---|---|
| Machine | macOS arm64 dev machine (the machine #625 excludes) |
| Browser | Headless Chrome, `--use-gl=swiftshader` (software rasteriser) |
| Emulated metrics | 390×844 CSS, DPR 2, touch on |
| Network | loopback `127.0.0.1` — no café Wi-Fi, no mobile hotspot |
| Phone / low-end laptop | none |

Everything below is a **build identity reading**, not a row verdict. `SIT.4` frame times, load
time and the frame-rate evidence #625 asks for need the same measurement on the phone, and
SwiftShader's own numbers are not frame-rate evidence for any device.

## Page state at six samples

| Sample | t (ms) | `#status` class | `#status-progress-status` | canvas |
|---|---|---|---|---|
| 1 | 16 119 | null (loader cleared) | null | yes |
| 2 | 17 737 | null | null | yes |
| 3 | 19 354 | null | null | yes |
| 4 | 20 986 | null | null | yes |
| 5 | 22 622 | null | null | yes |
| 6 | 24 241 | null | null | yes |

All six frames are identical (`screenshots/probe-frame-01` … `-06`): mode pick,
*Choose how to play*, `Shared game · Last` (Last-mode affordance), `Puzzle stream`, `Quit`,
`English` — labels painted, no white screen, no stall on the loading screen. The first sample
is late by design (the probe waits 16 s before its first frame); this is **not** a load-time
measurement and is not read as one — #856 holds the desktop-measured 3.0–4.4 s cold open.

## Console and network

- **`TEL.*` lines**: 0 (`TEL.1`–`TEL.5`). Expected: release strips the seam (ADR-0004 `G2`,
  #729). No session id recorded, none invented.
- **Errors**: 0. Warnings: 2 × `GPU stall due to ReadPixels` / `CONTEXT_LOST_WEBGL` (SwiftShader
  and screenshot capture, desktop-only artefact), 1 × `AudioContext was not allowed to start`
  (expected before a user gesture).
- **Responses**: 200 for `/`, `index.png`, `index.js`, `index.wasm`, `index.pck`,
  `index.icon.png`; no 4xx/5xx.
- **`localStorage`**: `{}` at the end — nothing committed, because no game and no puzzle attempt
  ran on this pass. So "last committed Player Elo / Last mode" had no value to carry, and the
  background/return and quit/reopen legs were not exercised.

## Rows this run could not read

| Row | Why not |
|---|---|
| Performance — 60 fps, no hitch > 1 frame during a move | needs a move on a phone; no phone, and SwiftShader is not frame-rate evidence |
| Load time — board playable ≤ 3 s | needs a cold open on a phone over a named café-grade network; loopback + 16 s probe delay give no usable number |
| Reliability — background/return | needs a move and a puzzle attempt first, then a background on a mobile browser |
| Save durability — quit/reopen | needs a committed puzzle result first (no deal/attempt ran; the release also deals nothing — #655) |
