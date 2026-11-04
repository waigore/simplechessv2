# Superseded readings

The verify fail of 2026-10-25T07:33Z named six points. This page records, per superseded
reading, why it no longer stands and what replaces it.

| Superseded reading (`graphical-20261025T031500Z`) | Why it no longer stands | Replacement |
|---|---|---|
| Build `c5b8189`, run `40118381611` | The URL served `69a03d4` from 00:26Z and `ad9c04d` from 08:25Z; `c5b8189` predates #793's `advice_off` paint and carries #845/#856 | `ad9c04d`, run `40176551606` ([builds.md](builds.md)) |
| Load time **fail** — board not playable by touch (#845) | #845 is `accepted`; its fix `aa16e09` is **not** an ancestor of `c5b8189` and **is** one of `ad9c04d`. Carrying the `fail` would accuse a defect already fixed in the shipped build | **not-judged**, seat #625 |
| Performance `not-judged` — SwiftShader idle as slow as the move | True of that host, but the row's seat is a GPU desktop or a real device | **not-judged**, seat #625 — stated as a seat, never as a row verdict |
| Localization `not-judged` — pointer never switched locale (#833) | #833 is `superseded` by #793 and is not in `ad9c04d`; the switcher is a plain `Button` (`C4`) | **not-judged** for a still-true reason: no browser on this seat |
| Reliability soak `not-judged` — not run | #558 has since run it, on the export of `c4202bb` | **not-judged** on `ad9c04d`; #558's `pass` is cited and labelled as another build's |
| Accessibility `not-judged` — "verified outside playtest" | #640 and #641 posted published-build readings after the record was written | **fail** (`PAL.K2` #883, last move #888), seven signals passing |

## The #845 `fail` — dropped, not silently fixed

The earlier record read "Load time — board playable" as **fail** because a tap selected
one rank above the finger. That was measured on `c5b8189`. #845 was then accepted with a
fix committed as `aa16e09` ("Prove and pin the #845 board tap→square mapping"), which
`git merge-base --is-ancestor` places in `ad9c04d` and not in `c5b8189`.

Nothing is fixed or re-verified by this gate: per epic #37 Notes a gate never fixes a
row. The row becomes `not-judged` with #625 named, and the code/history evidence sits in
[builds.md](builds.md).

## A newer deployment moved the build mid-record

The fail's point 1 asked for the served build to be named at the time of reading. It was:
`ad9c04d`, run `40176551606`, pack 9 364 800 B. Should Pages deploy again before the
rendered rows are taken, the rendered run names its own build and the two are not
compared as one.
