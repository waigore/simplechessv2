# Notes — #626 phone-browser reading

## What was done

1. **Resolved the target issue** per `docs/issues/workflow-dispatch.md`: assigned `#626`, `status:pending-implementation`, `type:task`, milestone *Wave 4 — Shippable cafe-table release*. Confirmed the label.
2. **Resolved the Build under test** — the one precondition an agent can answer. The published URL serves `c5b8189` (run `40118381611`, `Deploy to Pages` green), which carries #647's repair; therefore no `Web Release` export fallback is used. Recorded in [build-resolution.md](build-resolution.md).
3. **Attempted the rows and stopped at the device precondition.** No row is judged.

## What was not done, and why

This issue is a **device reading**. Its subject is not "the build behaves" — #402 and #557 already read that on a desktop — but "the build behaves *on a phone, where the sitting actually happens*": the tab backgrounded under memory pressure, the mobile OS suspending the page, and `localStorage` eviction.

An unattended agent on the project's development machine cannot produce any of that:

- **No phone.** The dispatch host is a macOS development machine. No phone is attached and none can be. iOS Safari is not available anywhere off an iOS device.
- **No real backgrounding.** A scripted `Page.setWebLifecycleState`-style suspension in a desktop browser is not what a mobile OS does to a backgrounded tab; recording it as the mobile behaviour would be the desktop extrapolation the issue exists to end.
- **No sitting.** AC 2 asks for a continuous 15–40 minute sitting with wall-clock start/end and every interruption recorded. An agent run is not a person at a table, and a timer that sleeps for 15 minutes produces a number, not a sitting.
- **The reading method is excluded by the ACs anyway.** AC 4 requires the committed Player Elo and Last mode be read "with the method the mobile browser allows (not a desktop devtools path)". Anything the agent can do here is the desktop devtools path.

So the honest artifact is a run folder that **names the build and records `not-judged` for every row**, exactly as #625's parallel run did. Driving the published build in headless Chrome was deliberately avoided: it would add a desktop reading under a phone-run heading, which is worse than nothing.

## What a completing run needs

A person, once, with:

- a **physical phone** — iOS Safari and, if available, a Chromium mobile browser;
- a **named network** — café Wi‑Fi or a hotspot;
- the **published URL** `https://waigore.github.io/simplechessv2/` (already resolved; no export to build or serve);
- ~15–40 minutes at the table, following #626's *Reproduction steps* 2–4 and #558's Advice-Off leg and #557's quit/reopen and faulted-session legs inside it.

The folder to extend is this one (`graphical-20261024T225112Z/`): replace each `not-judged` row's basis with the measurement, add the interruption log, `screenshots/` and `logs/`, and keep the manifest's *Build / session id* line as it is unless the published URL has moved by then.

## Why no defect

`specs/playtest/evidence.md` and #626's own *Deliverables* file a `type:defect` for every **failing** row. No row was read, so none failed. The blocker — no phone, no café network, no seated person — is an execution-capability gap with no `quality-regression-owners.md` row behind it; filing it as a game defect would put a phantom entry on a wave epic.

## What this run deliberately did not change

- **#402's record.** It holds `status:pending-verification` and carries read rows. No row was re-read here, so nothing is superseded, #402's re-acceptance is not owed a re-read comment, and nothing was posted there — #625's parallel run took the same line.
- **#557 and #558.** Their bodies ask for a cross-reference naming *the mobile reading*; this folder has no mobile reading, so no cross-reference comment was posted. The tracked state of both is unchanged by this run.
- **`specs/`, `game/`, `asset_catalog/`, `game_assets/`.** Untouched, per AC 7.

## Outcome

`not-judged` throughout, with the build named. The issue's own ACs are **not** met: this folder does not show a sitting, an interruption, or a durability read on a phone. It shows that the build to measure is resolved and that the remaining work needs hardware and a person.
