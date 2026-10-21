class_name SessionRouter
extends Node
## CMP-session-router: cold open through shared-play / shared-result (#58).

signal screen_requested(screen_id: String, state: Dictionary)
signal replay_pointer(record: Dictionary)
signal play_rendered(state: Dictionary)

const STAGE_LOADING := "loading"
const STAGE_MODE_PICK := "mode-pick"
const STAGE_SHARED_SETUP := "shared-setup"
const STAGE_SHARED_PLAY := "shared-play"
const STAGE_SHARED_RESULT := "shared-result"
const STAGE_ENDED := "session-ended"
## Smoke alias kept for SEQ-playtest-headless-smoke / ENV.1 harness.
const STAGE_READY_ALIAS := "mode-pick-ready"

const MODE_SHARED := "shared"
const MODE_NONE := "none"
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
var selected_piece := ""
var play_ui_state := "S1"

var shared_session: SharedGameSession

var _resolver: AssetResolver
var _seams: PlaytestSeams
var _persist: PersistStore
var _board_playable := false
var _last_reject := ""
var _clock_accum_ms := 0.0


func _ready() -> void:
	_resolver = get_node("../AssetResolver") as AssetResolver
	_seams = get_node("../PlaytestSeams") as PlaytestSeams
	_persist = get_node_or_null("../PersistStore") as PersistStore
	locale = StringTable.locale_from_os(OS.get_locale())
	_seams.register_stages(_known_stages())
	_seams.bind_state(play_snapshot)
	_seams.jump_requested.connect(_on_jump_requested)
	_seams.seed_changed.connect(_on_seed_changed)
	_seams.input_replayed.connect(_on_input_replayed)
	_resolver.boot_ready.connect(_on_boot_ready)
	_resolver.must_overlay.connect(_on_unresolved_overlay)
	var host := get_parent()
	if host != null and host.has_signal("asset_needed"):
		host.asset_needed.connect(_on_asset_needed)
	if _persist != null:
		_persist.write_failed.connect(show_save_failure)


func _process(delta: float) -> void:
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return
	if play_ui_state != "S1":
		return
	if shared_session.white_clock_ms == null:
		return
	_clock_accum_ms += delta * 1000.0
	var whole := int(_clock_accum_ms)
	if whole <= 0:
		return
	_clock_accum_ms -= float(whole)
	shared_session.tick(whole)
	_emit_play_screen()
	if bool(shared_session.rules.game_ended_field().get("ended", false)):
		_go_shared_result()


func start() -> void:
	stage = STAGE_LOADING
	session_ended = false
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func enter_shared_play() -> void:
	if not _resolver.group_loaded("play"):
		_resolver.preload_play()
	_provide_assets(_resolver.resolve_group("play"))


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
		STAGE_SHARED_PLAY:
			_on_shared_play_control(control_id)
		STAGE_SHARED_RESULT:
			_on_shared_result_control(control_id)


## CTR-presentation.E1 — select (to empty) or place (from/to).
func handle_input_commit(from_square: String, to_square: String) -> void:
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return
	if play_ui_state != "S1":
		return
	if bool(shared_session.rules.game_ended_field().get("ended", false)):
		return
	if to_square.is_empty():
		_try_select(from_square)
		return
	_try_place(from_square, to_square)


func show_save_failure() -> void:
	## EX.save-failure (UI-mode-pick.S4); prior committed Last mode stays.
	if stage != STAGE_MODE_PICK and stage != STAGE_READY_ALIAS:
		stage = STAGE_MODE_PICK
	screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S4"))


func play_snapshot() -> Dictionary:
	var base := {
		"position": null,
		"castling_ep": null,
		"clocks": null,
		"advice_best_move": null,
		"advice_eval": null,
		"game_ended": {"ended": session_ended, "reason": ""},
		"mode": last_mode if stage == STAGE_SHARED_PLAY or stage == STAGE_SHARED_RESULT else "",
		"stage": stage,
		"seed": _seams.seed_value,
		"locale": locale,
		"last_mode": last_mode,
		"white_seat": white_seat,
		"clock": clock,
		"increment": increment,
		"advice": advice_on,
		"options_locked": options_locked,
		"selected_piece": selected_piece,
		"play_ui_state": play_ui_state,
	}
	if shared_session == null:
		return base
	var live := shared_session.play_state()
	base["position"] = live.get("position", null)
	base["castling_ep"] = live.get("castling_ep", null)
	base["clocks"] = live.get("clocks", null)
	base["game_ended"] = live.get("game_ended", base["game_ended"])
	base["mode"] = "shared"
	base["result_copy"] = live.get("result_copy", "")
	return base


func note_pointer(record: Dictionary) -> void:
	_seams.note_pointer(record)


func session_is_paused() -> bool:
	return _seams.is_paused()


func legal_targets_for(square: String) -> PackedStringArray:
	if shared_session == null:
		return PackedStringArray()
	return shared_session.rules.legal_targets(square)


func occupancy_at(square: String) -> Dictionary:
	if shared_session == null:
		return {}
	var occ: Dictionary = shared_session.rules.position_field().get("occupancy", {})
	return occ.get(square, {}) as Dictionary


func side_to_move() -> String:
	if shared_session == null:
		return ChessRules.SIDE_WHITE
	return str(shared_session.rules.position_field().get("side_to_move", ChessRules.SIDE_WHITE))


func play_gestures_available() -> bool:
	return (
		stage == STAGE_SHARED_PLAY
		and play_ui_state == "S1"
		and shared_session != null
		and not bool(shared_session.rules.game_ended_field().get("ended", false))
	)


func _known_stages() -> PackedStringArray:
	return PackedStringArray(
		[
			STAGE_LOADING,
			STAGE_MODE_PICK,
			STAGE_READY_ALIAS,
			STAGE_SHARED_SETUP,
			STAGE_SHARED_PLAY,
			STAGE_SHARED_RESULT,
			STAGE_ENDED,
		]
	)


func _on_boot_ready() -> void:
	_provide_assets(_resolver.resolve_group("boot"))
	_load_persist()
	_go_mode_pick()


func _on_asset_needed(asset_ids: PackedStringArray) -> void:
	## CTR-presentation.E3 → CTR-asset-resolve → CTR-presentation.O5.
	_provide_assets(_resolver.resolve_ids(asset_ids))


func _provide_assets(resources_by_id: Dictionary) -> void:
	if resources_by_id.is_empty():
		return
	var host := get_parent()
	if host != null and host.has_method("provide_assets"):
		host.call("provide_assets", resources_by_id)


func _load_persist() -> void:
	if _persist == null:
		return
	var doc := _persist.load_document()
	last_mode = str(doc.get("last_mode", MODE_NONE))


func _go_mode_pick(ui_state: String = "S1") -> void:
	stage = STAGE_MODE_PICK
	options_locked = false
	shared_session = null
	selected_piece = ""
	play_ui_state = "S1"
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


func _shared_play_state() -> Dictionary:
	var pos := {}
	var ended := false
	var reason := ""
	var in_check := false
	var white_ms: Variant = null
	var black_ms: Variant = null
	if shared_session != null:
		var field := shared_session.rules.position_field()
		pos = field
		var ended_field: Dictionary = shared_session.rules.game_ended_field()
		ended = bool(ended_field.get("ended", false))
		reason = str(ended_field.get("reason", ""))
		in_check = shared_session.rules.in_check(str(field.get("side_to_move", "white")))
		white_ms = shared_session.white_clock_ms
		black_ms = shared_session.black_clock_ms
	var legal := PackedStringArray()
	if not selected_piece.is_empty():
		legal = legal_targets_for(selected_piece)
	return {
		"locale": locale,
		"white_seat": white_seat,
		"clock": clock,
		"increment": increment,
		"advice": advice_on,
		"options_locked": options_locked,
		"ui_state": play_ui_state,
		"position": pos,
		"selection": selected_piece,
		"legal": legal,
		"side_to_move": side_to_move(),
		"in_check": in_check,
		"white_clock_ms": white_ms,
		"black_clock_ms": black_ms,
		"game_ended": ended,
		"end_reason": reason,
		"resign_available": not ended and play_ui_state == "S1",
		"last_reject": _last_reject,
	}


func _emit_play_screen(move: Dictionary = {}) -> void:
	var state := _shared_play_state()
	if not move.is_empty():
		state["move"] = move
	screen_requested.emit(STAGE_SHARED_PLAY, state)
	play_rendered.emit(state)


func _on_mode_pick_control(control_id: String) -> void:
	match control_id:
		"C1":
			if not _commit_last_mode(MODE_SHARED):
				return
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


func _commit_last_mode(mode: String) -> bool:
	if _persist == null:
		last_mode = mode
		return true
	if _persist.commit_last_mode(mode):
		last_mode = mode
		return true
	# Failed write leaves prior commit; EX.save-failure via write_failed → show_save_failure.
	return false


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
			_start_shared_game()
		"C6":
			_go_mode_pick("S1")


func _start_shared_game() -> void:
	options_locked = true
	last_mode = MODE_SHARED
	selected_piece = ""
	play_ui_state = "S1"
	_last_reject = ""
	_clock_accum_ms = 0.0
	shared_session = SharedGameSession.new()
	shared_session.start_shared(clock, increment)
	stage = STAGE_SHARED_PLAY
	enter_shared_play()
	_seams.emit_tel("shared.start", "ok", "UI-shared-play.US1")
	_emit_play_screen()


func _on_shared_play_control(control_id: String) -> void:
	match control_id:
		"C3":
			if play_ui_state != "S1" or shared_session == null:
				return
			if bool(shared_session.rules.game_ended_field().get("ended", false)):
				return
			# F-move-advice.R2: toggle only; no evaluation / display / blocking error.
			advice_on = not advice_on
			_seams.emit_tel("shared.advice", "toggled", "UI-shared-play.US1.4")
			_emit_play_screen()
		"C4":
			if play_ui_state != "S1" or shared_session == null:
				return
			if bool(shared_session.rules.game_ended_field().get("ended", false)):
				return
			play_ui_state = "S2"
			_seams.emit_tel("shared.resign", "confirm", "UI-shared-play.US1.1")
			_emit_play_screen()
		"confirm":
			if play_ui_state != "S2" or shared_session == null:
				return
			if shared_session.resign():
				_seams.emit_tel("shared.resign", "end", "UI-shared-play.US1.1")
				_seams.emit_tel("shared.end", SharedGameSession.END_L2, "NAV.T6")
				_go_shared_result()
		"cancel":
			if play_ui_state != "S2":
				return
			play_ui_state = "S1"
			_emit_play_screen()


func _on_shared_result_control(control_id: String) -> void:
	match control_id:
		"C1":
			# NAV.T7 — full journey owned by #59; unlock setup for a new game.
			shared_session = null
			selected_piece = ""
			play_ui_state = "S1"
			options_locked = false
			stage = STAGE_SHARED_SETUP
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C2":
			# NAV.T8
			_go_mode_pick("S1")


func _try_select(square: String) -> void:
	var piece := occupancy_at(square)
	if piece.is_empty():
		return
	var side := side_to_move()
	if str(piece.get("color", "")) != side:
		return
	if selected_piece == square:
		return
	selected_piece = square
	_last_reject = ""
	_seams.emit_tel("shared.select", square, "UI-shared-play.US1.2")
	_emit_play_screen()


func _try_place(from_square: String, to_square: String) -> void:
	_last_reject = ""
	var before_side := side_to_move()
	var ok := shared_session.try_move(from_square, to_square, "")
	if not ok:
		# Rules-level refuse: keep selection; no auto-queen (REASON_PROMOTION stays refused).
		if selected_piece.is_empty():
			var piece := occupancy_at(from_square)
			if not piece.is_empty() and str(piece.get("color", "")) == before_side:
				selected_piece = from_square
		_last_reject = "illegal"
		_seams.emit_tel("shared.move", "illegal", "UI-shared-play.US1.3")
		_emit_play_screen()
		return
	selected_piece = ""
	_seams.emit_tel("shared.move", "ok", "UI-shared-play.US1.3")
	var stm := side_to_move()
	if shared_session.rules.in_check(stm):
		_seams.emit_tel("shared.check", stm, "UI-shared-play.US2")
	var move := {"from": from_square, "to": to_square}
	_emit_play_screen(move)
	if bool(shared_session.rules.game_ended_field().get("ended", false)):
		_seams.emit_tel(
			"shared.end", str(shared_session.rules.game_ended_field().get("reason", "")), "NAV.T6"
		)
		_go_shared_result()


func _go_shared_result() -> void:
	stage = STAGE_SHARED_RESULT
	play_ui_state = "S1"
	selected_piece = ""
	var result_key := ""
	if shared_session != null:
		result_key = shared_session.result_copy_key()
	screen_requested.emit(
		STAGE_SHARED_RESULT, {"locale": locale, "result_key": result_key, "last_mode": last_mode}
	)


func _next_in(values: Array, current: String) -> String:
	var index := values.find(current)
	if index < 0:
		return str(values[0])
	return str(values[(index + 1) % values.size()])


func _end_session() -> void:
	session_ended = true
	stage = STAGE_ENDED
	shared_session = null
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
			if shared_session == null:
				shared_session = SharedGameSession.new()
				shared_session.start_shared(clock, increment)
			_emit_play_screen()
		STAGE_SHARED_RESULT:
			_go_shared_result()
		STAGE_ENDED:
			screen_requested.emit(STAGE_ENDED, {"locale": locale})
		_:
			screen_requested.emit(stage_id, {})


func _on_seed_changed(_value: int) -> void:
	stage = STAGE_LOADING
	session_ended = false
	options_locked = false
	shared_session = null
	selected_piece = ""
	play_ui_state = "S1"
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func _on_input_replayed(record: Dictionary) -> void:
	replay_pointer.emit(record)
