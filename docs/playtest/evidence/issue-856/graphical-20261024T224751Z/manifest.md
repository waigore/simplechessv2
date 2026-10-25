# Manifest — #856 cold-open layers

| Field | Content |
|-------|---------|
| Issue | #856 |
| Environment | `ENV.2` (Graphical) |
| Build / session id | Release export from `main@3cd0e2e` (`python3 .github/scripts/web_export.py --preset "Web Release"`), served from `build/web/` at `http://127.0.0.1:8081`; the published comparison arm is `https://waigore.github.io/simplechessv2/` (same commit). No `TEL.3` session id: this run reads load timing, not a session. |
| Timing (`SIT.4` runs) | Headless Chrome (repo-owned binary), 390×844 CSS / DPR 2, touch emulation, cache disabled; 1–3 runs per arm, arms run back to back. Host: 10 cores, load 25–28 (shared with ten parallel agent worktrees). |
| Coverage mode | `critical-only` |
| Results | `SIT.4` (load time): `not-judged` — this run locates the cold open's cost; it does not judge the story. Protocol verdict: `not-judged`. |
| Paths | [`readings-cold-open-layers.md`](readings-cold-open-layers.md) (phases), [`trials.md`](trials.md) (page-change arms), [`notes.md`](notes.md), `logs/local-1.json` + `logs/local-1-console.log`, `logs/published-1.json` + `logs/published-1-console.log`, `logs/series-20261025T014500Z/` (arms). Screenshots: none — a load-timing reading, not a judged graphical state. |
| Defects | none filed by this run (#856 itself is the defect) |

## Runners

| Script | What it is |
|--------|------------|
| [`scripts/cold_open_layers.mjs`](../scripts/cold_open_layers.mjs) | One cold open in the #403 runner (`--use-angle=swiftshader`): per-frame `gl.readPixels` paint probe, GL-context stamps, Resource Timing, engine banner, app console with page-clock stamps. |
| [`scripts/cold_open_aligned.mjs`](../scripts/cold_open_aligned.mjs) | Same reading in the aligned runner (`scripts/cdp_aligned.mjs`), needed for any `rel=preload` arm: with the swiftshader flag the browser's own fetch of a preload is invisible to the page's Resource Timing. |
| [`scripts/cold_open_arms.mjs`](../scripts/cold_open_arms.mjs) | The A/B harness: one run per arm per page, aligned runner, writes every arm's summary and console to `logs/`. |
| [`scripts/make_arms.mjs`](../scripts/make_arms.mjs) | Writes the arm pages from the export's own `index.html` (probe after `startGame()`, preload links, preload links + worklets). |
| [`scripts/cdp_aligned.mjs`](../scripts/cdp_aligned.mjs) | `issue-403/.../scripts/cdp.mjs` minus `--use-angle=swiftshader`; nothing else differs. |

## Arms (`logs/series-20261025T014500Z/`)

| Arm | Page | Runs |
|-----|------|------|
| shipped | `index.html` | `shipped-1..3` |
| probe after `startGame()` | `index_probe_later.html` | `probe-later-1..3` |
| preload js+wasm+pck | `index_preload.html` | `preload-1..3` |
| preload + audio worklets | `index_preload_worklet.html` | `preload-worklets-1..3` |
