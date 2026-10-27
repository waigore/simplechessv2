# Scope — #627 phone listening run

#627 changes no game code; it records what a person hears. Playtesting is required
only when acceptance deliverables change playable behavior, so the gate in
`playtest.md` does not add a protocol here — but the issue itself asks for a listening
run, and that is what this folder records.

No design or UX protocol judges audio:

- `specs/playtest/` has no story row for `SND.M1`/`SND.M2`/`SND.X*` (a grep for
  `SND.M1` under `specs/playtest/` returns nothing).
- The `FS.*` filmed seating judges no story and needs `SIT.7`, whose seam is still
  `TBD`.
- View stories are out of playtest scope, and `specs/view/audio.md` is N/A by design.

So no protocol row is selected and no protocol verdict is claimed. The run records
the build's behavior against the `SND.*` elements the issue names, in
`readings.md`.
