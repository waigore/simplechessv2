# Manifest — #625 off-device run of the release build (`Web Release` export of `491554e`)

- **Issue**: #625 — record a funded, off-device run of the published release build
- **Environment**: `graphical`
- **Build under test**: **local `Web Release` export of
  `491554efae23a2235d1ebf1c087331912c00d7ed`** — the fallback the body defines, because the
  published URL still serves `c5b8189` and does not carry #647's repair. How the build was
  resolved, exported, checked (`--check-boot` 14/14, `--check-assets` 35/35 + 15
  `audio_runtime/`), served and correlated: [builds.md](builds.md).
- **No `TEL.3` session id**: the release build strips the seam (ADR-0004 `G2`, #729); none is
  invented. The correlation key is the export path plus the commit sha.
- **Timing (`SIT.4` runs)**: **not measured on a device** — no physical phone or
  non-development low-end machine was attached, and the host's own LAN address is firewalled
  ([notes.md](notes.md) §*Why the run stopped*). No timing from this run may stand in for a
  device row.
- **Coverage mode**: `critical-only` — the four rows named in the body were attempted; all four
  are `not-judged` for lack of an off-device reading.

## Results

Threshold and device class are the rows' own; the verdict column is this run's.

| Row (quality claim read) | Device class required by #625 | Device class available | Verdict |
|---|---|---|---|
| Performance — 60 fps, no hitch > 1 frame during a move | phone (governs) / low-end laptop | none — dev machine, headless SwiftShader | `not-judged` |
| Load time — board playable within 3 s of opening | phone (governs) / low-end laptop | none — dev machine, loopback | `not-judged` |
| Reliability — background/return (reopen clause) | phone (governs) / low-end laptop | none | `not-judged` |
| Save durability — quit/reopen | phone (governs) / low-end laptop | none | `not-judged` |

**Totals: 0 `pass`, 0 `fail`, 4 `not-judged`.** Per the acceptance criteria, a row read only on
the laptop is `not-judged`; here no laptop reading was even taken, so the same rule applies
with no secondary observation to record.

The mode-pick render, seam check and console reading taken on this build are **build identity,
not row verdicts** — see [readings.md](readings.md) §*Page state* and §*Console and network*.

## Paths

- [notes.md](notes.md) — why the run stopped, what could not be reached, the environment facts
- [build-identity.md](build-identity.md) — build identity re-measured independently: #647's
  repair is an ancestor of `c5b8189`, so a published-URL reading was available,
  and an appendix re-measuring the build identity independently (deployment record vs. what is
  served; #647's repair is an ancestor of `c5b8189`, so a published-URL reading was available)
- [builds.md](builds.md) — build resolution, Pages state, export commands and their output
- [readings.md](readings.md) — the probe's samples, console and network numbers, per-row gaps
- `screenshots/` — `probe-frame-01` … `probe-frame-06`, mode pick at 390×844 DPR 2
- `logs/` — `probe-console.log`, `probe-network.log`, `probe-result.json`
- Driver: `scripts/probe.mjs`

## Defects

**None filed.** No row failed — nothing was measured on the device class the acceptance
criteria require (reasoning in [notes.md](notes.md) §*Defects*).
