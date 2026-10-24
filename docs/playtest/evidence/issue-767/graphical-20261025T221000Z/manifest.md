# Manifest — #767 acceptance run (graphical)

| Field | Value |
|-------|-------|
| Issue | #767 — Promote shared-game keep list into main code (`type:task`, parent #34, Wave 1) |
| Environment | `ENV.2` graphical — native macOS window, Metal, `720 × 1280` (9:16, `CAM-board Web`), Godot `4.7.2.stable.official.ed1daf0bf`, playtest build |
| Build / session id | `origin/main` @ **`41f36e4`** — the same build as the [headless run](../headless-20261025T221000Z/manifest.md); clean detached worktree at `/private/var/folders/nj/j957smtj3jz0fn193bb2g_2c0000gn/T/accept767`; `TEL.3` session `sess-1792876239636-27084-playtest-470553` |
| Frame | `SIT.6`/`#708` applied: `seams.set_viewport(720,1280,1.0)` reported `applied=true frame_h=1280`, viewport `(720,1280)`, window `(720,1280)` |
| Coverage mode | `full` (intersected with the issue's scope) |
| Protocols | `PTU-shared-play` (`UI-shared-play.US2.7` via step S4) |
| Drive | [`drive_graphical.gd`](drive_graphical.gd) — [`run_graphical.sh`](run_graphical.sh) |

## Scope

Same scope as the headless run: the `PER.R6` check cue, judged through `PTU-shared-play` S4 → `UI-shared-play.US2.7`. Screenshots are the reason this run exists.

## Results

| Story row | Judging protocol | Outcome |
|-----------|------------------|---------|
| `UI-shared-play.US2.7` | `PTU-shared-play` S4 | **pass** |
| Protocol `PTU-shared-play` | — | **pass** (scope: the S4 read of the check cue) |

With the headless run, every required environment for the selected protocol is present.

## Steps (rendered observations)

| Step | Graphical observation | Screenshot | Result |
|------|-----------------------|------------|--------|
| S1 start | `White to move`, no `Check` chip, no mark on the board | [`01-ready-not-in-check.png`](screenshots/01-ready-not-in-check.png) | pass |
| S1/S2 to `3.Qxf7+` | `Black to move`; `Check` chip keylined in rose under it; **one** rose L-frame on the black King at `e8`; the white pawn from `f7` sits on the capturing square | [`02-white-gives-check.png`](screenshots/02-white-gives-check.png) | pass |
| `4.Kxf7` | chip gone, mark gone, `White to move` | [`03-check-answered.png`](screenshots/03-check-answered.png) | pass |

Rendered readings behind the `pass` (in [`logs/drive.log`](logs/drive.log)):

| Reading | Value |
|---|---|
| Chip rect | `(294,102)` `131 × 52` px, inside the frame |
| Word | `Check`, localized key, `lines=1`, label `91 × 48` px |
| Chip fits the word | `131 ≥ 51` (label minimum width) |
| Word on chip | `bg=#f7f1e8`, `ratio=6.39` |
| Chip keyline | `border=#c28a86` (= `PAL.C8`) |
| Board mark | `CheckMarks.marked_square='e8'`, `strokes=2`, `PAL.C8` |
| One mark only | `Overlays=[Selection,LegalMarks,CheckMarks,RejectFlash,PromoteChoice,AdviceMarks]` |
| `TEL.*` | `shared.check` → `TEL.4=UI-shared-play.US2`, `TEL.5=shown`, verdict `pass` |

The drive's own run ended `FAILURES ["VS2.4b indicator >= 1/12 frame height (82.0 >= 106.7)"]`. That check is a **view** reading (`PER.R6` / `VS2.4b`), out of playtest scope; it did not make the judged protocol fail. Recorded, not suppressed — see [`notes.md`](notes.md).

## Screenshot method

`/usr/sbin/screencapture` cannot capture this host's display (Screen Recording is not granted to the automation process). The screenshots are the **Godot process's own rendered framebuffer** (`root.get_texture().get_image()` → PNG, 720×1280) from a rendered, non-headless session of this build — the #617/#753 method.

The playtest debug panel (`PlaytestSeams/PlaytestDebug/DebugPanel`) was hidden before the judged window so the frames show the screen a player sees; the `DBG.4` story overlay was off.

## Paths

- [`logs/drive.log`](logs/drive.log) — full `STEP` window, `SHOTS`, `FAILURES`, `DONE failures=1`
- [`screenshots/01-ready-not-in-check.png`](screenshots/01-ready-not-in-check.png), [`02-white-gives-check.png`](screenshots/02-white-gives-check.png), [`03-check-answered.png`](screenshots/03-check-answered.png)
- [`notes.md`](notes.md) — judgement, limits, and the recorded view reading

## Defects

None filed. The one non-`ok` reading is a view-spec size floor (`VS2.4b`), which is outside playtest scope and was already surfaced to the tracker by the verification comment on #767; it is not a game or interface defect and does not block `US2.7`.
