# Headless notes

Acceptance playtest for #60 (Shared-game sound cues and cafe Ambient bed) on build `0a14c88` (merged #356 + #359).

## Prep

- `godot --headless --path game --import --quit` — exit 0
- `python3 .github/scripts/gdscript_tests.py test` — 14 passed (includes `presentation_audio_test.gd`)
- `python3 .github/scripts/gdscript_tests.py coverage` — 88.3% (2541/2878), threshold 80
- `godot --headless --path game -s res://presentation_audio_test.gd` — exit 0
- `godot --headless --path game -s res://shared_play_test.gd` — exit 0
- `godot --headless --path game` — smoke exit 0

## Scope

#60 wires `CMP-presentation` R3 / `CTR-presentation` O3 for `SND.X1`–`X4`, Ambient M1→M2→M1 after the board is playable (`ACC.G3` via #51 O4), mix `SND.L1`/`L2`, and a sound-off path with no mute control. Draws play no end cue; `SND.X5` stays Wave 2.

## Judgement

- **X1–X4**: select / move settle / check / loss endings play approved IDs; integration spine asserts select→X1, place→X2, resign→X4.
- **X5 / draws**: unbound X5 stays silent; `_is_loss_end` excludes `END.D1`–`D5`.
- **Ambient**: not loaded on cold open or mode-pick before playable; loads and starts M1 on Shared-play entry; M1→M2→M1 rotation; stays after return to mode-pick.
- **X2 budget**: catalog `01a151f8-b7d8-710a-b767-92c9137bfd63` v2 is 0.130 s; code plays unmodified.
- **Performance / G1**: `AudioStreamPlayer.play()` only; no awaits on the move path.
- **IDs only**: `SharedAudioCues` holds approved UUIDs; L2 reaches L1 only via O3.

Display server was headless (`ENV.1`). Graphical twin under `../graphical-20261021T213200Z/`.
