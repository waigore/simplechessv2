# Manifest — #627 phone listening run (cafe ambience and cues on device speakers)

- **Issue**: #627 — what a person hears on the shipped build: cafe ambience and every shipped cue on device speakers
- **Environment**: `ENV.2` Graphical — headless Chrome 156 (`--headless=new`, CDP), 390×844 CSS px, DPR 3, WebGL 2.0 (SwiftShader); `ENV.1` unused (no design protocol cites audio).
- **Device / OS / browser**: *not a physical phone* — a Chrome **phone-viewport** emulation of a phone browser. Device, OS, and speaker are **`not-judged`** for AC 1, and every cue row is `not-judged` against its `SND.X` element — see [`outcome.md`](outcome.md) → *What this run cannot claim*.
- **Output route / listening volume**: none — the capture reads the page's own Web Audio graph; no speaker, headphone, or microphone was used and no listening volume exists. Both `not-judged` under AC 1.
- **Build under test**: the **published release URL**, `https://waigore.github.io/simplechessv2/` (note [B1](https://github.com/waigore/simplechessv2/issues/627#b1); HTTP 200; pack 9 572 540 B), deployed commit **`69a03d4`** (deployment 2026-10-25T00:26:00Z), an ancestor of `origin/main` that carries #647's repair (`bccdb1c`) and the pick-up cue's landing commit **`943d5f0`** (#570 / PR #684).
  - **No fallback applies**, so the `Web Release` export was used **as a control only**; it is an export of `c5b8189`, the sha published when the run started (the release was republished mid-run). Provenance and pack routes: [`build-provenance.md`](build-provenance.md).
- **`TEL.3` session / build id**: `627/graphical-20261024T235414Z` on `69a03d4` (published). The release build carries no playtest seam (ADR-0004), so there are no `TEL.*` events; the id is the run folder plus the deployed sha.
- **Coverage mode**: `critical-only` — audio has no story row in `specs/playtest/` (grep for `SND.M1` returns nothing), so no protocol is selected ([`scope.md`](scope.md)).
- **Repeat count**: one cold open per build per configuration (published and control export, each autoplay-locked and unlocked), plus 6 press arms on the mode pick and a second published open on `c5b8189`.

## Results

- **AC 2 — ambience and the autoplay gate (measured):** [`ambience.md`](ambience.md).
- **AC 3 / AC 4 — cues and bed switching (not reached / not graded):** [`cues.md`](cues.md).
- **Per-AC verdicts and what remains:** [`outcome.md`](outcome.md).

## Paths

Every log, screenshot, probe, and companion document used by this run is in this folder: `build-provenance.md` (builds, commands, pack routes), `scope.md` (why no protocol is selected), `readings.md` (per-element `SND.X*` / `SND.M*` / `SND.L*` one-liners), the three Results files, `logs/` (raw probe JSON, incl. the AC 2 timeline, that open's console, pack routes and live 200s, the unlocked control timeline, the delivered-but-ignored press), `scripts/` (the five CDP probes), and `screenshots/` (cited frames; `screenshots/provenance/` holds attempts that did not become readings — kept and labelled, never cited).

## Defects

- **#879** — published Web build: presses inside the mode-pick buttons are delivered but do not activate the control (blocks every cue reading of this run). Detail: [`cues.md`](cues.md).
- The `c5b8189` snapshot's audio-route failure (`res://audio_runtime/…` unopenable on the served pack) is **not** filed separately: on `69a03d4` those routes are in the pack and served, and the route is #785's surface.


