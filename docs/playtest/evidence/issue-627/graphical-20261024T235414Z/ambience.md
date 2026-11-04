# Ambience and the autoplay gate (AC 2) — #627 phone listening run

Part of [`manifest.md`](manifest.md). Measured on the published build `69a03d4` with the
browser's *own* autoplay policy (no `--autoplay-policy` flag).

| Observation | Build | Reading |
|---|---|---|
| `AudioContext` created | published `69a03d4` | 12.155 s after navigate, state **`suspended`** |
| Build starts bed M1 while the context is suspended | published `69a03d4` | `source.start` at 14.329 s, buffer 180.036 s, `ctxState: suspended` — **silent** |
| Browser gate reached | published `69a03d4` | console: *"The AudioContext was not allowed to start. It must be resumed (or created) after a user gesture"* |
| **First gesture → audible ambience** | published `69a03d4` | gesture 31.566 s → context `running` **32.358 s** ⇒ **0.79 s after the gesture**, 20.2 s after the bed's start request |
| Bed is the right stream | published `69a03d4` | one `source.start`, `bufferSec 180.036`, stereo (export control: same) |
| Same, with autoplay unlocked (control) | published, export | bed starts at 17.6–18.7 s and the context is `running` from creation — the 0.79 s is the gate, not a start-up defect |

## Timeline

```
12.155 s  AudioContext created, state suspended
14.329 s  build requests bed M1 (buffer 180.036 s) — context still suspended
31.566 s  the run's single plain tap reaches the page
32.358 s  AudioContext → running (0.79 s after the gesture)
          the same start request now plays; context clock advances 12.83 s at +12 s
```

The bin the bed waits in is the browser's, not a defect: with autoplay already
unlocked (control, published and export builds) the bed starts at 17.6–18.7 s with
the context `running` from creation, i.e. the 0.79 s is exactly the gate.

The bed the build plays is the right shape: one 180.036 s stereo
`AudioBufferSourceNode` start, which matches catalog `music/cafe-ambient-a` (M1,
~180 s). No second bed, no doubling.

Raw logs: `logs/published-69a03d4-autoplay.json`, `logs/published-69a03d4-console.json`,
`logs/export-c5b8189-autoplay.json`. Per-element readings: [`readings.md`](readings.md).
