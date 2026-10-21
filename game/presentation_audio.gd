class_name PresentationAudio
extends Node
## CMP-presentation R3 / CTR-presentation.O3 — Shared cues and cafe beds (#60).

## Playlist beds (Ambient). Same UUIDs as SharedAudioCues; L1 owns rotation only.
const BED_M1 := "01a15200-69b2-7d13-a30d-696fa4ff390b"
const BED_M2 := "01a15200-69b2-7964-a602-ad5b19583125"

## Files are mastered to SND.L1 / L2; unity gain keeps that authored mix.
const SFX_VOLUME_DB := 0.0
const MUSIC_VOLUME_DB := 0.0
const SFX_POOL := 3

var last_cue_id := ""
var cue_play_count := 0
var music_started := false
var music_bed_index := 0

var _streams: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _beds: PackedStringArray = PackedStringArray([BED_M1, BED_M2])


func _ready() -> void:
	for index in SFX_POOL:
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%d" % index
		player.volume_db = SFX_VOLUME_DB
		add_child(player)
		_sfx_players.append(player)
	_music = AudioStreamPlayer.new()
	_music.name = "MusicPlayer"
	_music.volume_db = MUSIC_VOLUME_DB
	_music.finished.connect(_on_music_finished)
	add_child(_music)


func bind_assets(resources_by_id: Dictionary) -> void:
	for asset_id in resources_by_id.keys():
		var resource: Variant = resources_by_id[asset_id]
		if resource is AudioStream:
			_streams[str(asset_id)] = resource


func has_stream(asset_id: String) -> bool:
	return _streams.has(asset_id)


func play_cue(cue_id: String) -> void:
	## CTR-presentation.O3 — SFX or ambient start; finishes on-device (G1).
	## Unbound IDs stay silent (sound-off). Bed IDs start the M1→M2 playlist.
	if cue_id.is_empty():
		return
	if cue_id == BED_M1 or cue_id == BED_M2:
		_start_ambient()
		return
	if not _streams.has(cue_id):
		return
	var stream: AudioStream = _streams[cue_id] as AudioStream
	if stream == null:
		return
	var player := _next_sfx_player()
	if player == null:
		return
	last_cue_id = cue_id
	cue_play_count += 1
	player.stream = stream
	player.play()


func _start_ambient() -> void:
	## M1 → M2 → M1 with a clean join (no crossfade). Idempotent once started.
	if music_started:
		return
	if not _streams.has(BED_M1) and not _streams.has(BED_M2):
		return
	music_started = true
	music_bed_index = 0
	_play_current_bed()


func is_music_playing() -> bool:
	return _music != null and _music.playing


func _next_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	if _sfx_players.is_empty():
		return null
	return _sfx_players[0]


func _play_current_bed() -> void:
	var bed_id := str(_beds[music_bed_index % _beds.size()])
	if not _streams.has(bed_id):
		music_bed_index = (music_bed_index + 1) % _beds.size()
		bed_id = str(_beds[music_bed_index])
		if not _streams.has(bed_id):
			return
	_music.stream = _streams[bed_id] as AudioStream
	_music.play()


func _on_music_finished() -> void:
	if not music_started:
		return
	music_bed_index = (music_bed_index + 1) % _beds.size()
	_play_current_bed()
