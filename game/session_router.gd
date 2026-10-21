class_name SessionRouter
extends Node
## CMP-session-router cold open through the mode-pick-ready hook.

signal screen_requested(screen_id: String, state: Dictionary)
signal replay_pointer(record: Dictionary)

const STAGE_LOADING := "loading"
const STAGE_READY := "mode-pick-ready"

var locale := "en"
var stage := STAGE_LOADING

var _resolver: AssetResolver
var _seams: PlaytestSeams
var _board_playable := false


func _ready() -> void:
	_resolver = get_node("../AssetResolver") as AssetResolver
	_seams = get_node("../PlaytestSeams") as PlaytestSeams
	_seams.register_stages(_known_stages())
	_seams.bind_state(play_snapshot)
	_seams.jump_requested.connect(_on_jump_requested)
	_seams.seed_changed.connect(_on_seed_changed)
	_seams.input_replayed.connect(_on_input_replayed)
	_resolver.boot_ready.connect(_on_boot_ready)
	_resolver.must_overlay.connect(_on_unresolved_overlay)


func start() -> void:
	stage = STAGE_LOADING
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func enter_shared_play() -> void:
	if _resolver.group_loaded("play"):
		return
	_resolver.preload_play()


func note_board_playable() -> void:
	_board_playable = true


func start_music() -> void:
	if not _board_playable or _resolver.group_loaded("ambient"):
		return
	_resolver.preload_ambient()


func _on_unresolved_overlay(asset_id: String) -> void:
	_seams.set_overlay(true, PackedStringArray([asset_id]))


func play_snapshot() -> Dictionary:
	return {
		"position": null,
		"castling_ep": null,
		"clocks": null,
		"advice_best_move": null,
		"advice_eval": null,
		"game_ended": {"ended": false, "reason": ""},
		"mode": "",
		"stage": stage,
		"seed": _seams.seed_value,
	}


func note_pointer(record: Dictionary) -> void:
	_seams.note_pointer(record)


func session_is_paused() -> bool:
	return _seams.is_paused()


func _known_stages() -> PackedStringArray:
	return PackedStringArray([STAGE_LOADING, STAGE_READY])


func _on_boot_ready() -> void:
	stage = STAGE_READY
	screen_requested.emit(STAGE_READY, {})


func _on_jump_requested(stage_id: String) -> void:
	stage = stage_id
	screen_requested.emit(stage_id, {})


func _on_seed_changed(_value: int) -> void:
	stage = STAGE_LOADING
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func _on_input_replayed(record: Dictionary) -> void:
	replay_pointer.emit(record)
