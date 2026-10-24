# Notes — #655 branch re-run under the *catalog enabled* answer

## Which answer this run was judged under

**Catalog enabled in the published release.** [Product-owner comment on #648, 2026-10-24T07:16:25Z](https://github.com/waigore/simplechessv2/issues/648#issuecomment-6381343549): *"The puzzle catalog route ships enabled in the published release. The published client carries a real `T9`/`T10` pair for the catalog route, the backend serves the snapshot, and Puzzle stream's ship criterion includes a real deal on the published URL."*

The `specs/` sentence that states the release status has **not** landed on `a5b35ae`: `configuration.md` `T9`/`T10` still read *"Set per deployment"* and `B5` still reads only *"T9 or T10 missing: every deal fails (FAIL.T14); Elo kept; log"*. `git grep -n "ships enabled\|release status" origin/main -- specs/` → none. That sentence is #648's AC2; this defect's AC8 forbids writing it here. **Criterion 1 is unmet**, recorded rather than papered over.

## What this run measured that earlier passes did not

Prior blocked passes measured only the headless probe leg, where the `""` initialisers are visible in source. This run measured the **published build itself** — the build the *enabled* answer makes the judge — on the first `Web release` to publish a `main` commit since the probe legs were written (`a5b35ae`, pck 13:00:58 GMT).

Reproduction steps re-run unmodified on `https://waigore.github.io/simplechessv2/`: boot settles to mode pick, tap **Puzzle stream**, the stream enters and the first deal is refused (`WARNING: puzzle stream: deal read failed (status)`).

The decisive observation is in `logs/published-deal-log.txt`: the only network traffic after the page load is the `index.*` bundle itself. **No request leaves the client for a catalog or advice route** — `index.png`, `index.js`, `index.wasm`, `index.pck`, `index.icon.png` and one blob, and nothing else, before the refusal. That is the shape of `B5`'s empty-value guard: `CatalogDealClient.is_available()` short-circuits before `request()`, so no transport is attempted.

So **criterion 2 is `fail` on the published build, for the cause the defect filed**: the published client does not carry the real `T9`/`T10` pair the answer states it does. `session_router.gd:33-34` still initialises both to `""`; no shipped-path assignment exists on `a5b35ae`. Criterion 3 follows: K1 needs a dealt puzzle and there is none, so it **fails** rather than becoming the absence outcome. Criterion 4 is the other branch and was not borrowed.

## Criterion 5 — `C5` on `S1`: pass, re-measured

`probe/x655_confirm_probe.gd` on a clean `origin/main` worktree at `a5b35ae`, byte-identical to the `review-20261024-probe3` log:

```
X655 ENTERED state=S1 has_puzzle=false pid=<> elo=1000.00 last_failure=<status>
X655 C5_ACTIVATED state=S2 confirm_kind=<leave_confirm> confirm_shown=true
X655 CANCEL state=S1 has_puzzle=false
X655 ROUTER booted=mode-pick entered=puzzle-play C5=S2 after_confirm=mode-pick flow_left=true
```

Observed by activating the control, not from a screenshot. The repair landed in #694; nothing further is owed.

**Graphical note.** The published build's leave controls in its bottom bar did not respond to CDP touch taps at 390×844, so that is a *driver* limitation, not a `C5` result — it is not claimed. The headless leg carries the row.

Details beyond this summary — ambient and play-group preloads, and the rows this run does not settle — are in [`observations.md`](observations.md).
