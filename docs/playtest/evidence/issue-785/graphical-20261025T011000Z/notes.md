# Notes — #785 acceptance run

## What was asked

#785 asks for one observable on the shipped surface: `Preload ambient` leaves **0** unresolved IDs, no `Unresolved asset ID` warning is emitted for either music ID, and `SND.M1`'s cafe ambience is heard at mode pick — on both the published URL and a `Web Release` export of the same commit.

The published half cannot be read yet: the published tree serves `main`, and #799 is still open (`BEHIND`, checks green). The accepted evidence therefore rests on the `Web Release` export, which the issue itself names as the control.

## How it was measured

Three independent readings on the #799 export, not one:

1. **The observable.** A 25 s cold open recorded 22 console/network events and **zero** `ERROR` lines: no `Can't open file`, no `Unresolved asset ID`, no `Preload ambient left N`. The mode pick renders. The pre-patch logs in `issue-630/published-20261024T130500Z/logs/` and the pre-patch export both show the same window with six `ERROR` lines and `Preload ambient left 2 approved IDs unresolved`, so the comparison is like-for-like.
2. **The route.** A temporary probe autoload (removed from the branch afterwards) called the resolver's own functions: `FileAccess.open` on `res://audio_runtime/<id>.ogg` fails with err 7, `ResourceLoader.load` returns a decoded `AudioStreamOggVorbis`, and `resolve(<id>)` returns the same stream. That is the fix's mechanism, confirmed on the built artifact rather than inferred from the diff.
3. **The end of the chain.** `PresentationAudio` had `bound=2`, `music_started=true`, `MusicPlayer.playing=true` with the runtime stream, and its playback position advanced 8.94 s → 12.96 s across two samples 4 s apart. "Binds and plays" is the most this run can prove; audibility stays with #627.

## The thing that only showed up on a second build

A first export of this PR already had the fix and resolved the group; the pre-patch export did not reproduce the shipped defect at all. Why is in [`finding-812.md`](finding-812.md). It is not a reason to withhold acceptance, and it is the reason defect #812 is filed.

## Not judged

- **Published URL** — not rebuilt until #799 merges.
- **Audibility / mix / autoplay** — #627.
- **Any playtest story row** — none is selected; see [`scope.md`](scope.md).

## Unrelated findings, for their owners (not graded)

- The Shared game button label is very low contrast in every 390×844 capture of this build (the same reading #630's manifest recorded for #640/#641). Not part of #785.
- The first headless capture of a build prints a `DRIVER probe` line stamped `500.000s` where the rest are milliseconds; a cosmetic bug in the capture script's wait loop, harmless to the readings above.
