# Playtest evidence — #882 graphical acceptance run

| Field | Content |
|-------|---------|
| Issue | #882 — `EX.loading` never leaves when Boot assets fail |
| Environment | `graphical` (Chromium headless shell, 390×844 CSS px, dpr 3) |
| Build / session id | `main` @ `79d5780`; `Web Release` export (`build/web`, started at `main_release.tscn`), served copy with every `game_assets/` and `audio_runtime/` file removed by `scripts/strip_served_assets.py`; `TEL.3` session id not read (release build carries no telemetry seam) |
| Timing (`SIT.4` runs) | Not timed — this run judges the failure surface, not load time |
| Coverage mode | `full` |
| Results | `EX.load-failure` copy rendered and legible (pass on copy/legibility); C5 Reload **does not re-load** (fail → **F1**); `EX.loading` gone from the rendered screen and `EX.load-failure` named by code and spec (pass) — detail in `notes.md` |
| Defects | #923 — C5 Reload on `EX.load-failure` skips Boot and lands on mode-pick |

## Paths

- `screenshots/cold-open-0.png`, `cold-open-1.png`, `cold-open-2.png` — cold open with the Boot group unresolvable; `-2` is the settled frame
- `screenshots/after-reload-press.png` — 3 s after the C5 Reload press
- `screenshots/after-reload-settled.png` — 9 s after the C5 Reload press
- `screenshots/probe-final.png` — the probe scene's failure surface (resolver outcome pinned to the same `boot_failed` the stripped tree produces)
- `notes.md` — judgement
- `logs/accept-console.log` — page console of the acceptance run
- `logs/readings.json` — frame digests, tap log, locale storage
- `logs/probe-page.log` — the probe scene's page console (`PROBE boot_outcome=…`, `Boot assets failed: 9 approved IDs unresolved`)
- `logs/probe-console.log` — CDP console of the probe run
- `scripts/accept.mjs`, `scripts/cdp.mjs`, `scripts/probe.mjs`, `scripts/strip_served_assets.py`, `scripts/build-probe.sh` — the run's drivers
