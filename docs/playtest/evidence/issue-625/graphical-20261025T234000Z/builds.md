# Builds — how #625's build under test was resolved

## 1. Does the published URL serve #647's repair?

**No.** Checked at run time (2026-10-25):

| Fact | Value | Source |
|---|---|---|
| Pages is live | `https://waigore.github.io/simplechessv2/` answers 200, Godot 4.7.2 loader | `curl` on `index.html`, `index.wasm` |
| Newest deployment served | id **`7302318984`**, commit **`c5b8189`** | `gh api repos/waigore/simplechessv2/deployments` |
| Newest `Web release` run | **`40118381611`**, `success`, `c5b8189` | `gh run list --workflow "Web release"` |
| `main` head | **`491554e`** (#861, 2026-10-24T22:39Z) | `gh api repos/.../commits/main` |
| Distance | `c5b8189..491554e` = 26 commits | `git log --oneline c5b8189..origin/main` |

So Pages serves a commit 26 commits behind `main`. #647 (`bccdb1c`, *Implement the asset-root
route for the Web build*) is on `main` and not in the served commit. The **Build under test**
fallback is therefore the build to read, and the published URL is not.

## 2. The export

```
git worktree add <tmp>/wt625 origin/main --detach     # HEAD = 491554e
godot --headless --path game --import --quit          # editor import first
python3 .github/scripts/web_export.py --preset "Web Release"     # → build/web/ (ADR-0007)
python3 .github/scripts/web_export.py --preset "Web Release" --check-boot
   → 14 of 14 boot asset file(s) resolved from …/wt625/build/web
python3 .github/scripts/web_export.py --preset "Web Release" --check-assets
   → 35/35 cataloged game_assets/ file(s), 15 audio_runtime/ copy(ies) in …/wt625/build/web
```

Export contents read back: `index.html` 5 444 B, `index.js` 279 815 B, `index.wasm`
39 514 754 B, `index.pck` 9 570 588 B, plus `game_assets/` and `audio_runtime/` — the
asset root #647's route puts into the shipped export. Exported from `main`, it contains no
`PlaytestSeams` node (`game/main_release.tscn`), so `_emit_tel` is a no-op and no `TEL.*`
line can appear (ADR-0004 `G2`, #729).

## 3. Why the phone could not read it

The export was served on `0.0.0.0:8625` for a phone to open over the café-grade path the
body names. Two hard stops, both outside the run:

1. **No phone attached.** `system_profiler SPUSBDataType` lists no phone; no `idevice_id` or
   `adb`; Wi-Fi (`en0`, `192.168.0.119`) reports no peer. This is #625's *funded* hardware
   requirement and it was not met for this dispatch.
2. **The host does not accept LAN connections from itself.** Requesting
   `http://192.168.0.119:8625/` (its own LAN address) from the host times out while
   `http://127.0.0.1:8625/` answers 200 with the same server — macOS Application Firewall
   is enabled and does not prompt in an unattended run. Even with a phone, this host would
   have needed the firewall allowed for the trial, or a tunnel.

The run therefore read the build on loopback only, and labels those readings *dev machine,
desktop class* — never as a row verdict.

## 4. Repeats

The probe ran **once** (one page load, six samples). No `SIT.4` repeat count is claimed,
because no `SIT.4` timing was taken.
