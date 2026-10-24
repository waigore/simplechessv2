# Notes — #785 acceptance run

## What was asked

#785 asks for one observable on the shipped surface: `Preload ambient` leaves **0** unresolved IDs, no `Unresolved asset ID` warning is emitted for either music ID, and `SND.M1`'s cafe ambience is heard at mode pick — on both the published URL and a `Web Release` export of the same commit.

The published half cannot be read yet: the published tree serves `main`, and #799 is still open (`BEHIND`, checks green). The accepted evidence therefore rests on the `Web Release` export, which the issue itself names as the control.

## How it was measured

Three independent readings on the #799 export, not one:

1. **The observable.** A 25 s cold open recorded 22 console/network events and **zero** `ERROR` lines: no `Can't open file`, no `Unresolved asset ID`, no `Preload ambient left N`. The mode pick renders. The pre-patch logs in `issue-630/published-20261024T130500Z/logs/` and the pre-patch export both show the same window with six `ERROR` lines and `Preload ambient left 2 approved IDs unresolved`, so the comparison is like-for-like.
2. **The route.** A temporary probe autoload (removed from the branch afterwards) called the resolver's own functions: `FileAccess.open` on `res://audio_runtime/<id>.ogg` fails with err 7, `ResourceLoader.load` returns a decoded `AudioStreamOggVorbis`, and `resolve(<id>)` returns the same stream. That is the fix's mechanism, confirmed on the built artifact rather than inferred from the diff.
3. **The end of the chain.** `PresentationAudio` had `bound=2`, `music_started=true`, `MusicPlayer.playing=true` with the runtime stream, and its playback position advanced 8.94 s → 12.96 s across two samples 4 s apart. "Binds and plays" is the most this run can prove; audibility stays with #627.

## The thing that only showed up on a second build (filed)

The first export of this PR already had the fix and already resolved the group. The pre-patch export did **not** reproduce the shipped defect at all: it resolved the `ambient` group too. Repeating both from clean trees showed why — the runtime copy is present in the built pack only when `audio_runtime/*.ogg` has been imported into the (git-ignored) `.godot` cache, and the export imports whatever is on disk when it runs. A tree that has imported once loads its `ambient` group **with or without** the fix; a tree that has never imported it does not have the route at all (`FileAccess.get_file_as_bytes` → 0 B, `load_from_buffer` decodes nothing).

That is not a reason to withhold acceptance: on the artifact #799 ships, the group resolves through the route the spec names, and the code change is the one that reads that route. It is a reason to file a defect, because the release path still has no reading that tells a good bundle from a broken one, and the resolver's success now depends on what a developer's machine happened to import. That defect is #812.

## Not judged

- **Published URL** — not rebuilt until #799 merges.
- **Audibility / mix / autoplay** — #627.
- **Any playtest story row** — no design or UX protocol in `specs/playtest/` cites `SND.M1`/`SND.M2`; the `FS.*` filmed seating judges no story and `SIT.7` is `TBD`. Recorded as a spec gap, not a run result.

## Unrelated findings, for their owners (not graded)

- The Shared game button label is very low contrast in every 390×844 capture of this build (the same reading #630's manifest recorded for #640/#641). Not part of #785.
- The first headless capture of a build prints a `DRIVER probe` line stamped `500.000s` where the rest are milliseconds; a cosmetic bug in the capture script's wait loop, harmless to the readings above.
