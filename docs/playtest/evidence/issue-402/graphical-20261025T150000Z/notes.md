# Notes — #693 filmed seating, published `69a03d4`

## Build

Published `https://waigore.github.io/simplechessv2/`, `Web release` run **`40146630737`**
(push, success, `69a03d4`), Pages deployment `github-pages` **`7306478742`**
(`2026-10-25T00:26:00Z`), read from `repos/waigore/simplechessv2/deployments` — the
`github-pages` entry. `index.pck` 9,572,540 B, `200`. Run commit == deployment sha ==
`main`. The #785 fix is in it (PR #799 squash-merged as `4f133e8`; ancestor of
`69a03d4`). Never `dd15479`; no local export used.

## The three pre-recording gates — all passed

Readings and console excerpts: [logs/gate-readings.log](logs/gate-readings.log).

1. **Reached mode pick and entered a mode, 2 cold opens.** Mode pick at 12.271 s /
   12.315 s. A 200 ms press at (195,163), inside the C1 box #879 measured on this sha,
   advanced both sessions to "Shared game setup".
2. **Audio plays at mode pick, 2 cold opens.** `AudioContext` `running`, 0
   `Unresolved asset ID` warnings, no `Preload ambient … unresolved` line, 0
   `.ogg` open errors. Tapping the destination gave RMS 0.07–0.20 / peak 0.15–0.49,
   so the bed is feeding real signal, not a suspended context.
3. **Build identity.** Green `Web release` run whose commit is the live deployment.

An earlier attempt pressed at y 320–405 and nothing moved. Those points are empty page
below the panel — the mis-aim #879 diagnosed — so it is recorded as a non-finding, not
a build failure. #879 is not re-opened.

## Why the seating is not recorded

Gates passed, so the stop rule does not fire; the blocker is the instrument. `SIT.7`
needs a seam-free screen-**and-audio** recording from outside the page. This host has
no system-audio loopback (`avfoundation` lists one microphone; one built-in output, no
virtual/aggregate device; no HAL driver), and `screencapture` is denied Screen
Recording. The only working capture is headless CDP, which `filmed-seating.md`
excludes. A microphone aimed at speakers is not the tab's audio and cannot judge
`SND.X1`–`X5`. **#903** owns this gap; it is cited, not re-filed.

## Four answered decisions (product owner, 2026-10-24)

- **No new `quality.md` row.** A seating is review evidence for look, sound, and motion.
- **In-repo retention** until #402's accept outcome, as for every run folder.
- **Mix levels not judged on the recording.** `SND.L1`/`SND.L2` are measured on source
  files only, so a seating records no `SND.L1`/`L2` verdict.
- **`SIT.7` seam-free** and audio-bearing.

## Device and levels

macOS arm64, Chrome 156, 390×844 CSS px, DPR 2, touch emulation; built-in speakers.
Bed read with the tab unmuted at an audible level; the gate-(b) by-ear half has no
instrument here (headless), which is why the folder carries no seating.
