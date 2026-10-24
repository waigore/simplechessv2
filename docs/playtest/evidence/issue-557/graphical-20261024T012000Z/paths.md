# Paths — #557 graphical run `20261024T012000Z`

Where each artifact in this run sits, relative to this folder.

## Records

- `manifest.md` — the `evidence-manifest.md` fields, results table, and `Defects` line
- `notes.md` — judgement text, blockers, and what was deliberately not done
- `readings.md` — per-leg committed-vs-observed document and screen reads
- `build-observations.md` — deployed commit, boot console, code path, reproduction
- `setup.md` — driver commands, flags, and known limitation
- `run.json` — machine-written run record: per-leg before/after reads, fault counters, screenshot md5 set
- `driver.mjs` — the driver that produced every artifact above from the published URL

## Screenshots (`screenshots/`)

All seven are byte-identical (`md5 7ba3b2c7a110a2219608ad9ab65c5165`, `Loading…`):

- `leg1-before-close.png`, `leg1-after-reopen.png`
- `leg2-before-crash.png`, `leg2-after-reopen.png`
- `leg3-before-fault.png`, `leg3-after-fault.png`, `leg3-after-reopen.png`

## Logs (`logs/`)

- `leg-1.console.log` — leg 1 open + reopen console, failed requests
- `leg-2.console.log` — leg 2 open (through CDP `Page.crash`) + reopen
- `leg-3.console.log` — leg 3 wrapper install, write count, save-failure observation, open + reopen
