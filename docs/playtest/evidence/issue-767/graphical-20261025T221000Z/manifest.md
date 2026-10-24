# Manifest — #767 acceptance run (graphical)

| Field | Value |
|-------|-------|
| Issue | #767 — Promote shared-game keep list into main code (`type:task`, parent #34, Wave 1) |
| Environment | `ENV.2` graphical — native macOS window, Metal, `720 × 1280` (9:16, `CAM-board Web`), Godot `4.7.2.stable.official.ed1daf0bf` |
| Build / session id | `origin/main` @ **`41f36e4`** — the same build as the [headless run](../headless-20261025T221000Z/manifest.md); `TEL.3` `sess-1792876239636-27084-playtest-470553` |
| Frame | `set_viewport(720,1280,1.0)` → `applied=true frame_h=1280` |
| Coverage mode | `full` (intersected with the issue's scope) |
| Protocol | `PTU-shared-play` (`UI-shared-play.US2.7`, step S4) |
| Drive | [`drive_graphical.gd`](drive_graphical.gd), [`run_graphical.sh`](run_graphical.sh) |

## Scope

Same as the headless run. Screenshots are why this run exists.

## Results

| Story row | Judging protocol | Outcome |
|-----------|------------------|---------|
| `UI-shared-play.US2.7` | `PTU-shared-play` S4 | **pass** |
| Protocol `PTU-shared-play` | — | **pass** (S4 read of the check cue) |

With the headless run, every required environment is present.

## Steps (rendered observations)

| Step | Observation | Screenshot | Result |
|------|-------------|------------|--------|
| S1 start | `White to move`, no chip, no mark | [`01-ready-not-in-check.png`](screenshots/01-ready-not-in-check.png) | pass |
| S1/S2 to `3.Qxf7+` | `Black to move`; `Check` chip keylined in rose; one rose L-frame on the black King at `e8` | [`02-white-gives-check.png`](screenshots/02-white-gives-check.png) | pass |
| `4.Kxf7` | chip and mark gone, `White to move` | [`03-check-answered.png`](screenshots/03-check-answered.png) | pass |

Readings (in [`logs/drive.log`](logs/drive.log)):

| Reading | Value |
|---|---|
| Chip | `131 × 52` px, inside the frame |
| Word | `Check`, `lines=1`, label `91 × 48` px |
| Chip fits the word | `131 ≥ 51` |
| Word on chip | `bg=#f7f1e8`, 6.39:1 |
| Keyline | `#c28a86` = `PAL.C8` |
| Board mark | `marked_square='e8'`, `strokes=2` |
| One mark only | `Overlays` holds `CheckMarks`, no `CheckMark` |
| `TEL.*` | `shared.check` → `UI-shared-play.US2`, verdict `pass` |

The drive's own run ended `FAILURES ["VS2.4b indicator >= 1/12 frame height (82.0 >= 106.7)"]`. That is a **view** reading, out of playtest scope; it did not fail the judged protocol. Recorded, not suppressed — see [`notes.md`](notes.md).

## Screenshot method

`screencapture` cannot capture this host's display (Screen Recording not granted to the automation process). The images are the Godot process's own rendered framebuffer (`root.get_texture().get_image()` → PNG) from a rendered, non-headless session — the #617/#753 method. The debug panel was hidden before the judged window.

## Paths

- [`notes.md`](notes.md) — judgement, limits, recorded view reading
- [`logs/drive.log`](logs/drive.log) — full `STEP` window, `SHOTS`, `FAILURES`, `DONE failures=1`
- [`screenshots/01-ready-not-in-check.png`](screenshots/01-ready-not-in-check.png)
- [`screenshots/02-white-gives-check.png`](screenshots/02-white-gives-check.png)
- [`screenshots/03-check-answered.png`](screenshots/03-check-answered.png)

## Defects

None filed. The one non-`ok` reading is a view-spec size floor, outside playtest scope and already with the tracker on #792; not a game or interface defect.
