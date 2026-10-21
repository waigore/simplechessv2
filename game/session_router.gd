class_name SessionRouter
extends Node
## CMP-session-router: cold open, mode-pick, shared-setup, locale, quit.

signal screen_requested(screen_id: String, state: Dictionary)
signal replay_pointer(record: Dictionary)

const STAGE_LOADING := "loading"
const STAGE_MODE_PICK := "mode-pick"
const STAGE_SHARED_SETUP := "shared-setup"
const STAGE_SHARED_PLAY := "shared-play"
const STAGE_ENDED := "session-ended"
## Smoke alias kept for SEQ-playtest-headless-smoke / ENV.1 harness.
const STAGE_READY_ALIAS := "mode-pick-ready"

const MODE_SHARED := "shared"
const MODE_NONE := ""
const CLOCKS := ["untimed", "blitz", "rapid"]

var locale := "en"
var stage := STAGE_LOADING
var last_mode := MODE_NONE
var white_seat := "bottom"
var clock := "untimed"
var increment := 3
var advice_on := true
var options_locked := false
var session_ended := false

var _resolver: AssetResolver
var _seams: PlaytestSeams
var _board_playable := false


func _ready() -> void:
	_resolver = get_node("../AssetResolver") as AssetResolver
	_seams = get_node("../PlaytestSeams") as PlaytestSeams
	locale = StringTable.locale_from_os(OS.get_locale())
	_seams.register_stages(_known_stages())
	_seams.bind_state(play_snapshot)
	_seams.jump_requested.connect(_on_jump_requested)
	_seams.seed_changed.connect(_on_seed_changed)
	_seams.input_replayed.connect(_on_input_replayed)
	_resolver.boot_ready.connect(_on_boot_ready)
	_resolver.must_overlay.connect(_on_unresolved_overlay)


func start() -> void:
	stage = STAGE_LOADING
	session_ended = false
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


func handle_control(screen_id: String, control_id: String) -> void:
	if session_ended:
		return
	match screen_id:
		STAGE_MODE_PICK:
			_on_mode_pick_control(control_id)
		STAGE_SHARED_SETUP:
			_on_shared_setup_control(control_id)


func show_save_failure() -> void:
	## Driven by persist work (#61); panel state S4 exists on mode-pick.
	if stage != STAGE_MODE_PICK and stage != STAGE_READY_ALIAS:
		_go_mode_pick()
	screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S4"))


func play_snapshot() -> Dictionary:
	return {
		"position": null,
		"castling_ep": null,
		"clocks": null,
		"advice_best_move": null,
		"advice_eval": null,
		"game_ended": {"ended": session_ended, "reason": ""},
		"mode": last_mode if stage == STAGE_SHARED_PLAY else "",
		"stage": stage,
		"seed": _seams.seed_value,
		"locale": locale,
		"last_mode": last_mode,
		"white_seat": white_seat,
		"clock": clock,
		"increment": increment,
		"advice": advice_on,
		"options_locked": options_locked,
	}


func note_pointer(record: Dictionary) -> void:
	_seams.note_pointer(record)


func session_is_paused() -> bool:
	return _seams.is_paused()


func _known_stages() -> PackedStringArray:
	return PackedStringArray(
		[
			STAGE_LOADING,
			STAGE_MODE_PICK,
			STAGE_READY_ALIAS,
			STAGE_SHARED_SETUP,
			STAGE_SHARED_PLAY,
			STAGE_ENDED,
		]
	)


func _on_boot_ready() -> void:
	_go_mode_pick()


func _go_mode_pick(ui_state: String = "S1") -> void:
	stage = STAGE_MODE_PICK
	options_locked = false
	screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state(ui_state))


func _mode_pick_state(ui_state: String) -> Dictionary:
	return {
		"ui_state": ui_state,
		"locale": locale,
		"last_mode": last_mode,
	}


func _shared_setup_state() -> Dictionary:
	return {
		"locale": locale,
		"white_seat": white_seat,
		"clock": clock,
		"increment": increment,
		"advice": advice_on,
		"options_locked": options_locked,
	}


func _on_mode_pick_control(control_id: String) -> void:
	match control_id:
		"C1":
			last_mode = MODE_SHARED
			stage = STAGE_SHARED_SETUP
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C3":
			screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S3"))
		"C4":
			locale = StringTable.next_locale(locale)
			screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S1"))
		"confirm":
			_end_session()
		"cancel":
			_go_mode_pick("S1")
		"dismiss":
			_go_mode_pick("S1")


func _on_shared_setup_control(control_id: String) -> void:
	match control_id:
		"C1":
			if options_locked:
				return
			white_seat = "top" if white_seat == "bottom" else "bottom"
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C2":
			if options_locked:
				return
			clock = _next_in(CLOCKS, clock)
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C3":
			if options_locked or clock == "untimed":
				return
			increment = 5 if increment == 3 else 3
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C4":
			advice_on = not advice_on
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C5":
			options_locked = true
			last_mode = MODE_SHARED
			stage = STAGE_SHARED_PLAY
			enter_shared_play()
			screen_requested.emit(STAGE_SHARED_PLAY, _shared_setup_state())
		"C6":
			_go_mode_pick("S1")


func _next_in(values: Array, current: String) -> String:
	var index := values.find(current)
	if index < 0:
		return str(values[0])
	return str(values[(index + 1) % values.size()])


func _end_session() -> void:
	session_ended = true
	stage = STAGE_ENDED
	screen_requested.emit(STAGE_ENDED, {"locale": locale, "last_mode": last_mode})


func _on_unresolved_overlay(asset_id: String) -> void:
	_seams.set_overlay(true, PackedStringArray([asset_id]))


func _on_jump_requested(stage_id: String) -> void:
	if stage_id == STAGE_READY_ALIAS:
		stage_id = STAGE_MODE_PICK
	stage = stage_id
	session_ended = stage_id == STAGE_ENDED
	match stage_id:
		STAGE_LOADING:
			screen_requested.emit(STAGE_LOADING, {})
		STAGE_MODE_PICK:
			screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S1"))
		STAGE_SHARED_SETUP:
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		STAGE_SHARED_PLAY:
			screen_requested.emit(STAGE_SHARED_PLAY, _shared_setup_state())
		STAGE_ENDED:
			screen_requested.emit(STAGE_ENDED, {"locale": locale})
		_:
			screen_requested.emit(stage_id, {})


func _on_seed_changed(_value: int) -> void:
	stage = STAGE_LOADING
	session_ended = false
	options_locked = false
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func _on_input_replayed(record: Dictionary) -> void:
	replay_pointer.emit(record)
