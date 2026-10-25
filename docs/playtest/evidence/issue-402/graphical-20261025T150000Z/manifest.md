# Manifest — filmed seating, published release build

- **Issue**: #693, gate #402 — record the filmed seating of the release build on the
  published URL.
- **Environment**: `graphical` (`ENV.2`), seam-free `SIT.7` capture per
  [filmed-seating.md](../../../../../specs/playtest/filmed-seating.md) — `FS.1`–`FS.4`
  in one file.
- **Build / session id**: published `https://waigore.github.io/simplechessv2/`,
  `Web release` run **`40146630737`**, commit **`69a03d4`**; Pages deployment
  `github-pages` **`7306478742`** (2026-10-25T00:26:00Z), read from the Pages
  **deployment** API (`/pages/builds/latest` answers `404` here by design).
  `TEL.3 absent — the release export emits no telemetry, specified for a release build
  (`CTR-playtest-drive` G2, `CMP-playtest-seams` R3)`.
- **Timing (`SIT.4` runs)**: macOS arm64 (MacBook Pro), Chrome 156; headless CDP for the
  gate reads only. Cold-open repeat count: **2** — mode pick 12.271 s / 12.315 s, a mode
  entered 2/2 (readings in [logs/gate-readings.log](logs/gate-readings.log)).
- **Coverage mode**: `no hub coverage reading — a filmed seating is not a story-row run
  and judges no design or UX row (`specs/playtest/filmed-seating.md`, Relationship to
  evidence)`.

## Results

`not-judged — no seating; protocol could not be captured on this host (SIT.7 has no
compliant capture path; cited defect #903).` Gates (a), (b), (c) all passed; see
[notes.md](notes.md).

## Paths

- [notes.md](notes.md) — gates, capture blocker, the four answered decisions
- [logs/gate-readings.log](logs/gate-readings.log) — the three gate readings
- [logs/cold-open-1-events.log](logs/cold-open-1-events.log),
  [logs/cold-open-2-events.log](logs/cold-open-2-events.log) — console per cold open
- [logs/deep-1-audio.json](logs/deep-1-audio.json) — destination-level bed readings
- [logs/entry2-1-summary.json](logs/entry2-1-summary.json),
  [logs/entry2-2-summary.json](logs/entry2-2-summary.json) — mode entry, both cold opens
- `screenshots/`: `cold-open-{1,2}-mode-pick`, `cold-open-{1,2}-after-enter`,
  `entry2-{1,2}-*`, `deep-1-*`, and the mis-aimed first attempt `entry-*`
- Drivers: `gate_probe.cjs`, `audio_probe.cjs`, `entry_probe2.cjs`, `entry_probe.cjs`
- `seating/recording.<ext>`: `not applicable — SIT.7 has no compliant capture path on
  this host; cited defect #903` (not a pre-recording gate failure: all three gates passed)
- `seating/shot-list.md`, `seating/review.md`: `not applicable — no recording, so no
  judged moment exists; cited defect #903`

## Defects

- **#903** — no playtest seam exposes audio; `SIT.7`'s seam is TBD and no technical
  design or accepted ADR realizes a recording hook. Cited, not re-filed.
- **#402** — the gate whose folder this is; it waits for a seating it can read.
