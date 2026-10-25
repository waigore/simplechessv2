# Manifest — #856 Ambient load off the mode-pick frame

| Field | Content |
|-------|---------|
| Issue | #856 |
| Environment | `ENV.2` (Graphical) |
| Build / session id | Two local `Web Release` exports (`python3 .github/scripts/web_export.py --preset "Web Release"`, Godot 4.7.2), served from their `build/web/` by `python3 -m http.server` at `http://127.0.0.1:8092` (base) and `http://127.0.0.1:8093` (branch): base = `origin/main` `ceb2919`, after = branch `defect/856-cold-open-ambient-after-paint` on `ceb2919`. Both carry the two-`print()` measurement patch ([`logs/measurement-print.patch`](logs/measurement-print.patch)) so the arms differ only in the `start_music()` ordering. Neither arm is the published page. No `TEL.3` session id: this run reads load timing, not a session. |
| Timing (`SIT.4` runs) | Headless Chrome (`/Applications/Google Chrome.app`), 390×844 CSS / DPR 2, touch emulation, cache disabled. Three runs per arm per runner, arms taken back to back; `cold_open_aligned.mjs` = hardware GL, `cold_open_layers.mjs` = the #403 runner (`--use-angle=swiftshader`). Host: 10 cores, load average 44–67. |
| Coverage mode | `critical-only` |
| Results | `SIT.4` (load time): `not-judged` — this run measures one cold-open layer, it does not judge the row. Protocol verdict: `not-judged`. |
| Paths | [`readings-ambient-off-paint.md`](readings-ambient-off-paint.md) (measurement and verdict), [`arms.md`](arms.md) and [`arms-swiftshader.md`](arms-swiftshader.md) (tables), [`notes.md`](notes.md), `logs/ab-final-base.json` + `logs/ab-final-after.json` (branch A/B, aligned runner), `logs/ab-base2-1.json` + `logs/ab-after2-1.json` (two-frame arm), `logs/ab-base-1.json` + `logs/ab-after-1.json` (one-frame arm, rejected), `logs/sw-base-1..3` and `logs/sw-after-1..3` (`.json` + `-console.log`, #403 runner), `logs/measurement-print.patch`. Screenshots: none — a load-timing reading, not a judged graphical state. |
| Defects | none filed by this run (#856 itself is the defect) |

## Runners

| Script | What it is |
|--------|------------|
| [`../scripts/cold_open_aligned.mjs`](../scripts/cold_open_aligned.mjs) + [`../scripts/cdp_aligned.mjs`](../scripts/cdp_aligned.mjs) | The mode-pick paint readback with the browser and engine on one page clock, `runs` per invocation, no software-rasteriser flag. Resolves the 0.42 s signal. |
| [`../scripts/cold_open_layers.mjs`](../scripts/cold_open_layers.mjs) | The #403 runner: per-frame `gl.readPixels`, `--use-angle=swiftshader`, one browser per run. Resolves ordering only on this host. |

## Arms

| Arm | Source | Runs |
|-----|--------|------|
| base | `origin/main` `ceb2919` + measurement print | `ab-final-base`, `ab-base2-1`, `ab-base-1`, `sw-base-1..3` |
| after (shipped, two frames) | branch + measurement print | `ab-final-after`, `ab-after2-1`, `sw-after-1..3` |
| after (one frame, rejected) | branch rejected arm + measurement print | `ab-after-1` (paired with `ab-base-1`) |
