# Manifest — #627 phone listening run (cafe ambience and cues on device speakers)

- **Issue**: #627 — record what a person hears on the shipped build: cafe ambience and every shipped cue on device speakers
- **Environment**: `ENV.2` Graphical — headless Chrome 156 (`--headless=new`, CDP), 390×844 CSS px, DPR 3, WebGL 2.0 (SwiftShader), `ENV.1` not used (no design protocol cites audio).
- **Device / OS / browser**: *not a physical phone.* This run could not be taken on a phone; it is a Chrome **phone-viewport** emulation of a phone browser. The device, OS, and speaker are therefore **`not-judged`** for AC 1, and every cue row is `not-judged` against its `SND.X` element — see `notes.md` → *What this run cannot claim*.
- **Output route / listening volume**: none. The capture reads the page's own Web Audio graph; no speaker, headphone, or microphone was used, and no listening volume exists. Both are `not-judged` under AC 1.
- **Build under test**: the **published release URL**, `https://waigore.github.io/simplechessv2/` (note [B1](https://github.com/waigore/simplechessv2/issues/627#b1); HTTP 200; pack 9 572 540 B).
  - Deployed commit **`69a03d4`** (deployment 2026-10-25T00:26:00Z), an ancestor of `origin/main`; it carries #647's repair (`bccdb1c`) and the pick-up cue's landing commit **`943d5f0`** (#570 / PR #684).
  - **No fallback reason applies**: the published URL serves a commit that carries the repair, so the `Web Release` export was used **as a control only**. It is an export of `c5b8189`, the sha that was published when the run started (the release was republished mid-run).
  - Provenance, commands, and pack/route measurements: [`build-provenance.md`](build-provenance.md); the earlier build's console: `logs/published-c5b8189-console.log`.
- **`TEL.3` session / build id**: `627/graphical-20261024T235414Z` on `69a03d4` (published). The run has no `TEL.*` events because the release build carries no playtest seam (ADR-0004); the session id is therefore the run folder plus the deployed sha.
- **Coverage mode**: `critical-only` — audio has no story row in `specs/playtest/` (grep for `SND.M1` returns nothing), so no protocol is selected. Scope reasoning: [`scope.md`](scope.md).
- **Repeat count**: one cold open per build per configuration (4 opens total: published locked, published unlocked, control export locked, control export unlocked), plus 6 press arms on the mode pick and a second published open on `c5b8189`.

## Results

### Ambience and autoplay (AC 2) — measured on the published build

| Observation | Build | Reading |
|---|---|---|
| `AudioContext` created | published `69a03d4` | 12.155 s after navigate, state **`suspended`** |
| Build starts bed M1 while the context is suspended | published `69a03d4` | `source.start` at 14.329 s, buffer 180.036 s, `ctxState: suspended` — **silent** |
| Browser gate reached | published `69a03d4` | console: *"The AudioContext was not allowed to start. It must be resumed (or created) after a user gesture"* |
| **First gesture → audible ambience** | published `69a03d4` | gesture 31.566 s → context `running` **32.358 s** ⇒ **0.79 s after the gesture**, 20.2 s after the bed's start request |
| Bed is the right stream | published `69a03d4` | one `source.start`, `bufferSec 180.036`, stereo (export control: same) |
| Same, with autoplay unlocked (control) | published, export | bed starts at 17.6–18.7 s and the context is `running` from creation — the 0.79 s is the gate, not a start-up defect |

### Bed switching `M1 → M2 → M1` (AC 4) — **stop**, not graded

| Observation | Build | Reading |
|---|---|---|
| Second bed reachable within a sitting | published `69a03d4` | **no** — `_start_ambient()` plays one bed and only advances in `_on_music_finished`; the bed is 180.036 s, so a switch needs ≈3 min 0 s of *uninterrupted* play |
| Standing in this run | published `69a03d4` | no sitting of that length was taken; the switch is `not-judged` |

### Each shipped cue (AC 3) — **not-judged**, and why

| Cue | `SND.X` element | Reached in the run? | Graph reading | Judgement |
|---|---|---|---|---|
| pick-up | `SND.X1` touch/select | **no** — board never reached | no `source.start` shorter than the bed | `not-judged` |
| place / settle | `SND.X2` movement | **no** | — | `not-judged` |
| check | `SND.X3` impact | **no** | — | `not-judged` |
| end (checkmate/resign/clock loss) | `SND.X4` | **no** | — | `not-judged` |
| wrong puzzle move | `SND.X5` puzzle fail | **no** — puzzle entry not reached on `69a03d4` | — | `not-judged` |
| distinguishability between cues | AC 3 | — | — | `not-judged` |

**Why no cue was reached — a reachability stop, recorded once and not blamed on sound.**
On the published frame a press inside "Shared game" (inside the measured button box,
y 150–190) is delivered to the page — the gesture trace shows `pointerdown` at
(150,185) — but the mode pick does not advance, in **4 sessions on two different
published shas** (`c5b8189`, `69a03d4`). On the `c5b8189` **export control** the same
point *did* advance in 2 of 6 hold arms, and the frame that did advance shows
"Shared game setup". So the stop is **inside the Web build's control handling**, not
in audio, and not in this run's pointer injection.

This is **not** a mix failure against `SND.X` / `SND.M` / `SND.L`; it is a separate
build defect filed as **#879** and cited here. On the `c5b8189` published build, before
the `943d5f0` route fix reached Pages, the same presses *did* reach the puzzle screen
and the console showed every audio asset failing to open
(`Preload play left 5 approved IDs unresolved`); that snapshot is in
`logs/published-c5b8189-console.log` and is superseded on `69a03d4`.

### Mix relations (`SND.L1` / `SND.L2`) — not judged

No listening occurred, so "above ambient", "no ducking of moves", and the loudness
targets are `not-judged`. The mix is authored in the assets and nothing in this run
contradicts it; the run simply has no reading.

## Paths

- `build-provenance.md` — published and control builds, commands, pack routes
- `scope.md` — why no playtest protocol is selected
- `readings.md` — the per-element one-line readings (`SND.X*`, `SND.M*`, `SND.L*`)
- `notes.md` — judgement text, the reachability stop, and what remains for a phone run
- `logs/published-69a03d4-autoplay.json` — the AC 2 timeline (gesture → `running` → bed)
- `logs/published-69a03d4-console.json` — console for that open, incl. the autoplay gate
- `logs/published-69a03d4-pck-routes.txt` — the seven `res://audio_runtime/…` and five SFX routes the pack carries, and the live 200s
- `logs/export-c5b8189-autoplay.json` — unlocked control timeline
- `logs/boardtap-69a03d4-boardtap.json` + `screenshots/boardtap-69a03d4-0*.png` — the press that is delivered and ignored
- `screenshots/published-69a03d4-01-before-gesture.png`, `…-02-after-gesture.png` — mode pick, before and after the first gesture
- `logs/` — every probe's raw JSON; `scripts/` — the five dependency-free CDP probes used
- `screenshots/provenance/` — attempts that did not become readings (kept, labelled, not cited as evidence)

## Defects

- **#879** — published Web build: presses inside the mode-pick buttons are delivered but do not activate the control (blocks every cue reading of this run).
- The `c5b8189` snapshot's audio-route failure (`res://audio_runtime/…` unopenable on the served pack) is **not** filed separately: on `69a03d4` the pack carries those seven routes and the host serves them (`logs/published-69a03d4-pck-routes.txt`), and the route is #785's surface.
