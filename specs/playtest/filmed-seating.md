# Filmed seating

Authoring rules: [`.agents/specs/rules/playtest/evidence.md`](../../.agents/specs/rules/playtest/evidence.md).

- **Serves**: Cafe calm and Instant play (vision); the aesthetics families `SRF.*` ([surface](../aesthetics/surface.md)), `SND.*` ([sound](../aesthetics/sound.md)), and `MOT.*` ([motion](../aesthetics/motion.md)).

A filmed seating is a recorded sitting of the shipped build that a reviewer watches and listens to end to end. It is an artifact of a Graphical run (`ENV.2`, [tools.md](tools.md)) on the release build: no seams, no debug UI, no overlay. Headless is excluded; it shows no surface or motion and carries no audio.

## Segments

One continuous recording, in order, on the build the citing gate names:

| ID | Segment | Reaches |
|----|---------|---------|
| `FS.1` | Mode pick with music playing, then a locale switch and back | `mode-pick` |
| `FS.2` | Mode pick → Shared game → setup → Start → a select, several moves, a capture, an end → result | `shared-setup`, `shared-play`, `shared-result` |
| `FS.3` | Result → mode pick → Puzzle stream → one puzzle attempt to its result | `puzzle-play` |
| `FS.4` | Leave the stream → confirm → mode pick → Quit → confirm | `mode-pick`, `NAV.T3` |

Leave and Quit follow [navigation](../ux/navigation.md) `T9` and `T3`.

## Shot list

A table shipped beside the recording, one row per judged moment: `mm:ss` timestamp, `FS.<n>` segment, the [UX](../ux/navigation.md) screen and control reached, and the elements shown. Elements are the `SRF.*`, `SND.*`, and `MOT.*` IDs, or `cafe calm` where the reading is the absence of motion and noise ([MOT.T4](../aesthetics/motion.md)). Each row cites at least one of them; every ID must exist in `specs/aesthetics/`.

## Review verdict

| ID | Outcome | Evidence cited |
|----|---------|----------------|
| `FV.1` | `pass` — matches its aesthetics row | Timestamp and the aesthetics ID |
| `FV.2` | `fail` — does not | Timestamp and the ID, then a `type:defect` against the owning wave epic ([quality-regression-owners.md](../definition/quality-regression-owners.md)) |
| `FV.3` | `not-judged` — cannot be shown or played | Timestamp, the ID, and why; never counts as `pass` |

The verdict is `pass` only when every named element is `FV.1`. One `FV.2` fails it; an `FV.3` leaves it open until a later recording judges that ID.

## Relationship to evidence

A recording is an artifact a run's `manifest.md` cites by path, never a replacement for the manifest, its results, or its logs ([evidence.md](evidence.md)). A filmed seating judges no design or UX story; protocols keep their own verdicts.

## TBDs

- **Quality row**: `quality.md` has no surface, sound, motion, or cafe-calm row. TBD — does a filmed seating become the check for a new row there, and with which target?
- **Publication and retention**: recordings are large media. TBD — in-repo under the evidence folder, or an external store the manifest links with a retention period?
- **Mix levels**: a filmed seating's `SND.L1` verdict is **relative and runtime-only**: bed RMS within ± 1 dB under an `SND.X2` cue, on the recording's own track. Integrated loudness stays `AK-music` `K2`'s claim and is not re-measured; `SND.L2`'s true-peak half is not measured from a recording.
