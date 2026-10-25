# The served build under test

- **Published URL**: `https://waigore.github.io/simplechessv2/` — HTTP `200` at 00:47Z, 00:56Z (before
  the captures) and 01:00Z (after them).
- **Served commit**: `69a03d4` (`69a03d48edf6304e265cf2078112c42e4d022afd`).
- **Publishing run**: `Web release` 40146630737, head `69a03d4`, created 2026-10-25T00:25:25Z —
  `Release export` success 00:25:27Z, `Deploy to Pages` success 00:26:03Z. The next newest successful
  `Web release` run is 40118381611 (`c5b8189`), so `69a03d4` is what Pages was serving.
- **Build identifier**: the release export carries no `TEL.3` session id (ADR-0004 `G2`), so the
  served commit is the build identifier. The engine banner in `logs/console.log` reads
  `Godot Engine v4.7.2.stable.official.ed1daf0bf`.
- **Served artifacts** (sha256, read at 00:47Z and unchanged at 01:00Z):

| File | Bytes | sha256 |
|---|---|---|
| `index.html` | 5444 | `83ba82899c09a8fcfe2ac370a56ff0f044c643e250526c8a32c933ba5d810167` |
| `index.js` | 279815 | `33c94cb3175f3333b82e2a3be5e8e86f77986f0aa2042b1631f6367a4e5bb6ba` |
| `index.wasm` | 39514754 | `fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0` |
| `index.pck` | 9572540 | `75abdd591c15e08ac7f0406169908190e18588a3a885ee4a202dfa30d31ad5ea` |

Raw readings and the run list: [`logs/served-build.txt`](logs/served-build.txt).

**A local export is not the build under test.** None was used: every frame in `screenshots/` is a
screenshot of that URL, driven over CDP. `main` had moved past `69a03d4` when this run started, but no
newer `Web release` run had published, so those commits are not what this run read.

**What the build did and did not reach.** Mode pick, shared setup, shared play, and the puzzle screen
all rendered; the puzzle screen never dealt a position (see [`gaps.md`](gaps.md)). Page console:
[`logs/console.log`](logs/console.log) — the Godot banner, one `puzzle stream: deal read failed
(status)` warning, and SwiftShader `GL Driver Message` performance warnings; no script error.
