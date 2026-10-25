# Preconditions — #626 phone reading

Every precondition below is a property of hardware the dispatch host does not hold; the run stopped at the first one.

| Precondition (issue *Reproduction steps*, ACs) | State at dispatch |
|---|---|
| iOS Safari **and** one Chromium mobile browser on a physical phone | **Not met** — the dispatch host is the project's macOS development machine (Apple Silicon); no phone is attached, and iOS Safari does not exist off an iOS device |
| A host the phone can reach for the fallback export (LAN or tunnel) | **Moot** — the published URL already serves the repaired commit, so the fallback is not used |
| A 15–40 minute wall-clock sitting with real background/foreground interruption | **Not met** — an agent run cannot sit at a café table; a scripted suspension in a desktop browser is not what a mobile OS does to a backgrounded tab |
| `localStorage` read "with the method the mobile browser allows (not a desktop devtools path)" | **Not met** — any reading taken here is necessarily the desktop devtools path the AC excludes |

## What a completing run needs

A person, once, with:

- a **physical phone** — iOS Safari and, if available, a Chromium mobile browser;
- a **named network** — café Wi‑Fi or a hotspot;
- the **published URL** (already resolved in [build-resolution.md](build-resolution.md); no export to build or serve);
- ~15–40 minutes at the table, following #626's *Reproduction steps* 2–4, #558's Advice-Off leg, and #557's quit/reopen and faulted-session legs inside it.

Extend this folder (`graphical-20261024T225112Z/`): replace each `not-judged` row's basis with the measurement, add the interruption log, `screenshots/` and `logs/`, and keep the manifest's *Build / session id* line unless the published URL has moved by then.
