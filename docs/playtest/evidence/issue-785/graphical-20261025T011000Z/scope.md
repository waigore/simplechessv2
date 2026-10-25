# Scope — #785 acceptance run

#785 changes game code (the Web audio read route), so playtesting is required per the gate in `playtest.md`, under the playtest procedures. The playable surface it changes is **the `ambient` music group and `SND.M1` starting at mode pick**.

No design or UX protocol judges audio:

- `specs/playtest` has no story row for `SND.M1`/`SND.M2` (a grep for `SND.M1` in `specs/playtest/` returns nothing).
- The `FS.*` filmed seating judges no story and needs `SIT.7`, whose seam is still `TBD`.
- View stories are out of playtest scope.

So no protocol row is selected. This run records the build behaviour #785 names instead — see `manifest.md` → Results.
