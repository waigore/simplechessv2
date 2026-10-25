class_name SessionRouter
extends Node
## CMP-session-router: cold open through shared-result / J-shared-session (#59).

signal screen_requested(screen_id: String, state: Dictionary)
signal replay_pointer(record: Dictionary)
signal play_rendered(state: Dictionary)

const STAGE_LOADING := "loading"
const STAGE_MODE_PICK := "mode-pick"
const STAGE_SHARED_SETUP := "shared-setup"
const STAGE_SHARED_PLAY := "shared-play"
const STAGE_SHARED_RESULT := "shared-result"
const STAGE_PUZZLE_PLAY := "puzzle-play"
const STAGE_ENDED := "session-ended"
## Smoke alias kept for SEQ-playtest-headless-smoke / ENV.1 harness.
const STAGE_READY_ALIAS := "mode-pick-ready"

const MODE_SHARED := "shared"
const MODE_PUZZLE := "puzzle"
const MODE_NONE := "none"
const CLOCKS := ["untimed", "blitz", "rapid"]

var locale := "en"
var stage := STAGE_LOADING
var last_mode := MODE_NONE
var white_seat := "bottom"
var clock := "untimed"
var increment := 3
var advice_on := true
## T6 / T9 / T10 (configuration.md B3). Integration values, set per deployment;
## empty endpoint or key makes Advice unavailable (FAIL.T1).
var advice_endpoint := ""
var advice_api_key := ""
var advice_time_ms := AdviceClient.ADVICE_TIME_DEFAULT_MS
var options_locked := false
var session_ended := false
## UI-mode-pick states S1 / S3 / S4, as last shown. The router owns it because
## the input rail can deliver a hidden control id (#846): S3 refuses C1–C4.
var mode_pick_ui_state := "S1"
## CTR-asset-resolve E4 — Boot's unresolved count when the Boot preload failed, else 0.
var boot_failure_count := 0
## EX.error / S3 — an advice fetch failed while On; cleared by Dismiss (states.md).

var shared_session: SharedGameSession

## The puzzle-play journey: CMP-puzzle-session and its CMP-puzzle-stream deal source,
## with the UI-puzzle-play screen flow. Built on entering `puzzle-play`
## (UI-mode-pick.C2 / NAV.T2) and dropped on leave (NAV.T9).
var puzzle_flow: PuzzlePlayFlow

## Proxies onto CMP-shared-game-session (tests and presentation).
var selected_piece: String:
	get:
		return shared_session.selected_piece if shared_session != null else ""
	set(value):
		if shared_session != null:
			shared_session.selected_piece = value

var play_ui_state: String:
	get:
		if puzzle_flow != null and stage == STAGE_PUZZLE_PLAY:
			return puzzle_flow.ui_state()
		if shared_session == null:
			return SharedGameSession.UI_S1
		# Have the session tell us the state it shows (states.md S3): the advice
		# failure is S3 over its own play state, so the gate and the screen read
		# the same source instead of a second copy of that rule.
		return str(shared_session.play_state().get("ui_state", SharedGameSession.UI_S1))
	set(value):
		if puzzle_flow != null and stage == STAGE_PUZZLE_PLAY:
			puzzle_flow.session.play_ui_state = value
		elif shared_session != null:
			shared_session.play_ui_state = value

var _resolver: AssetResolver
## Playtest seams node, or null in a release export (G2).
var _seams: Variant
var _persist: PersistStore
var _ambient_started := false
var _clock_accum_ms := 0.0
var _last_clock_display := ""


func _ready() -> void:
	_resolver = get_node("../AssetResolver") as AssetResolver
	_seams = _bind_seams()
	_persist = get_node_or_null("../PersistStore") as PersistStore
	locale = StringTable.locale_from_os(OS.get_locale())
	_resolver.boot_ready.connect(_on_boot_ready)
	_resolver.boot_failed.connect(_on_boot_failed)
	_resolver.ambient_ready.connect(_on_ambient_ready)
	_resolver.must_overlay.connect(_on_unresolved_overlay)
	var host := get_parent()
	if host != null and host.has_signal("asset_needed"):
		host.asset_needed.connect(_on_asset_needed)
	if _persist != null:
		_persist.write_failed.connect(show_save_failure)


## G2 — `main_release.tscn` carries no seam node, and this avoids naming the
## seam class so a release export never loads it.
func _bind_seams() -> Variant:
	var node := get_node_or_null("../PlaytestSeams")
	if node == null:
		return null
	node.register_stages(_known_stages())
	node.bind_state(play_snapshot)
	node.jump_requested.connect(_on_jump_requested)
	node.seed_changed.connect(_on_seed_changed)
	node.input_replayed.connect(_on_input_replayed)
	return node


func _seams_paused() -> bool:
	return _seams != null and _seams.is_paused()


func _emit_tel(event_name: String, outcome: String, story_id := "") -> void:
	if _seams != null:
		_seams.emit_tel(event_name, outcome, story_id)


func _process(delta: float) -> void:
	if stage == STAGE_PUZZLE_PLAY:
		if puzzle_flow != null and not _seams_paused():
			puzzle_flow.tick()
		return
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return
	# CTR-playtest-drive.O1 / DBG.1 — pause halts clocks and input.
	if _seams_paused():
		return
	# U3 → U2: advice updates apply on the session path (concurrency.md S1),
	# including untimed games, which have no clocks to tick.
	_poll_advice()
	if shared_session.game_ended():
		_go_shared_end()
		return
	if shared_session.white_clock_ms == null:
		return
	# Clocks keep running during resign confirm (S2); only board input is blocked.
	_clock_accum_ms += delta * 1000.0
	var whole := int(_clock_accum_ms)
	if whole <= 0:
		return
	_clock_accum_ms -= float(whole)
	shared_session.tick(whole)
	var display := shared_session._clock_display_key()
	if display != _last_clock_display:
		_last_clock_display = display
		_emit_play_screen()
	if shared_session.game_ended():
		_go_shared_end()


## Leaving the Shared game stops evaluation and clears advice (F-move-advice.R9).
func _go_shared_end() -> void:
	_leave_advice()
	var ended_field: Dictionary = shared_session.play_state().get("game_ended", {})
	var end_reason := str(ended_field.get("reason", ""))
	if _is_loss_end(end_reason):
		_play_cue(SharedAudioCues.CUE_END)
	_emit_tel("shared.end", end_reason, "NAV.T6")
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


func start_music() -> void:
	## Ambient O4 when mode pick becomes ready — never on cold open (#426 / AST.G3).
	if stage == STAGE_LOADING or _ambient_started:
		return
	if _resolver.group_loaded("ambient"):
		_on_ambient_ready()
		return
	_resolver.preload_ambient()


func handle_control(screen_id: String, control_id: String) -> void:
	if session_ended:
		return
	if screen_id == STAGE_SHARED_PLAY and _seams_paused():
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
		STAGE_PUZZLE_PLAY:
			_on_puzzle_play_control(control_id)


## CTR-presentation.E1 — select (to empty) or place (from/to + optional promotion).
func handle_input_commit(from_square: String, to_square: String, promotion: String = "") -> bool:
	if stage == STAGE_PUZZLE_PLAY:
		return puzzle_flow != null and puzzle_flow.gesture(from_square, to_square, promotion)
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return false
	if _seams_paused():
		return false
	if not play_gestures_available():
		return false
	return _apply_play_gesture(from_square, to_square, promotion)


func _apply_play_gesture(from_square: String, to_square: String, promotion: String) -> bool:
	if to_square.is_empty():
		return _apply_select(from_square)
	return _apply_place(from_square, to_square, promotion)


## IN.deselect — B8 / B9 / B11 / S4 cancel.
func handle_deselect() -> bool:
	if stage == STAGE_PUZZLE_PLAY:
		return puzzle_flow != null and puzzle_flow.deselect()
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return false
	if _seams_paused():
		return false
	var result := shared_session.clear_selection()
	if not bool(result.get("ok", false)):
		return false
	_emit_tel_result(result)
	_emit_play_screen()
	return true


## C6 — commit promotion type.
func handle_promotion_commit(kind: String) -> bool:
	if stage == STAGE_PUZZLE_PLAY:
		return puzzle_flow != null and puzzle_flow.promotion(kind)
	if stage != STAGE_SHARED_PLAY or shared_session == null:
		return false
	if _seams_paused():
		return false
	var result := shared_session.commit_promotion(kind)
	_emit_tel_result(result)
	if not bool(result.get("ok", false)):
		_emit_play_screen()
		return false
	_play_cue(SharedAudioCues.CUE_MOVE)
	var ended := bool(result.get("ended", false))
	var end_reason := str(result.get("end_reason", ""))
	if ended and _is_loss_end(end_reason):
		_play_cue(SharedAudioCues.CUE_END)
	elif bool(result.get("check", false)):
		_play_cue(SharedAudioCues.CUE_CHECK)
		_emit_tel("shared.check", "shown", "UI-shared-play.US2")
	var move: Dictionary = result.get("move", {}) as Dictionary
	_emit_play_screen(move)
	if ended:
		_emit_tel("shared.end", end_reason, "NAV.T6")
		_go_shared_result()
	return true


func finish_reject_flash() -> void:
	if stage == STAGE_PUZZLE_PLAY:
		if puzzle_flow != null:
			puzzle_flow.finish_reject_flash()
		return
	if shared_session == null:
		return
	if shared_session.play_ui_state != SharedGameSession.UI_S5:
		return
	shared_session.finish_reject_flash()
	_emit_play_screen()


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
		"seed": _seams.seed_value if _seams != null else 0,
		"locale": locale,
		"last_mode": last_mode,
		"white_seat": white_seat,
		"clock": clock,
		"increment": increment,
		"advice": advice_on,
		"online": true,
		"advice_available": false,
		"options_locked": options_locked,
		"selected_piece": "",
		"play_ui_state": SharedGameSession.UI_S1,
	}
	if stage == STAGE_PUZZLE_PLAY and puzzle_flow != null:
		base["mode"] = MODE_PUZZLE
		puzzle_flow.snapshot(base)
		return base
	if shared_session == null:
		return base
	var live := shared_session.play_state()
	base["position"] = live.get("position", null)
	base["castling_ep"] = live.get("castling_ep", null)
	base["clocks"] = live.get("clocks", null)
	base["game_ended"] = live.get("game_ended", base["game_ended"])
	base["mode"] = "shared"
	base["result_copy"] = live.get("result_copy", "")
	base["selected_piece"] = live.get("selected_piece", "")
	base["play_ui_state"] = live.get("play_ui_state", SharedGameSession.UI_S1)
	base["advice"] = live.get("advice", advice_on)
	base["online"] = live.get("online", true)
	base["advice_best_move"] = live.get("advice_best_move", null)
	base["advice_eval"] = live.get("advice_eval", null)
	base["advice_available"] = _advice_available()
	return base


func note_pointer(record: Dictionary) -> void:
	if _seams != null:
		_seams.note_pointer(record)


func session_is_paused() -> bool:
	return _seams_paused()


func legal_targets_for(square: String) -> PackedStringArray:
	if stage == STAGE_PUZZLE_PLAY:
		if puzzle_flow == null:
			return PackedStringArray()
		return puzzle_flow.legal_targets_for(square)
	if shared_session == null:
		return PackedStringArray()
	return shared_session.legal_targets_for(square)


func occupancy_at(square: String) -> Dictionary:
	if stage == STAGE_PUZZLE_PLAY:
		if puzzle_flow == null:
			return {}
		return puzzle_flow.occupancy_at(square)
	if shared_session == null:
		return {}
	return shared_session.occupancy_at(square)


func side_to_move() -> String:
	if stage == STAGE_PUZZLE_PLAY:
		if puzzle_flow == null:
			return ChessRules.SIDE_WHITE
		return puzzle_flow.side_to_move()
	if shared_session == null:
		return ChessRules.SIDE_WHITE
	return shared_session.side_to_move()


## R1 — board gestures are live in S1, S3 and S5 (and S6 where the screen allows
## the board); each session owns its own allow-list.
func play_gestures_available() -> bool:
	if stage == STAGE_PUZZLE_PLAY:
		return puzzle_flow != null and puzzle_flow.gestures_available()
	return (
		stage == STAGE_SHARED_PLAY
		and shared_session != null
		and shared_session.gestures_available()
	)


func can_place(from_square: String, to_square: String, promotion: String = "") -> bool:
	if stage == STAGE_PUZZLE_PLAY:
		return puzzle_flow != null and puzzle_flow.can_place(from_square, to_square, promotion)
	if shared_session == null:
		return false
	return shared_session.can_place(from_square, to_square, promotion)


func _known_stages() -> PackedStringArray:
	return PackedStringArray(
		[
			STAGE_LOADING,
			STAGE_MODE_PICK,
			STAGE_READY_ALIAS,
			STAGE_SHARED_SETUP,
			STAGE_SHARED_PLAY,
			STAGE_SHARED_RESULT,
			STAGE_PUZZLE_PLAY,
			STAGE_ENDED,
		]
	)


func _on_boot_ready() -> void:
	_provide_assets(_resolver.resolve_group("boot"))
	_load_persist()
	_go_mode_pick()


## CTR-asset-resolve E4 — Boot left approved IDs unresolved. The failure is
## observable here instead of the caller waiting forever on a ready that never
## comes. `EX.loading` still has no specified failure exit or copy, so this does
## not invent one: the wait stays until the UX owner specifies the surface, which
## #882 owns (filed from #647's S2 step).
func _on_boot_failed(unresolved: int) -> void:
	push_error("Boot assets failed: %d approved IDs unresolved" % unresolved)
	boot_failure_count = unresolved


func _on_asset_needed(asset_ids: PackedStringArray) -> void:
	## CTR-presentation.E3 → CTR-asset-resolve → CTR-presentation.O5.
	_provide_assets(_resolver.resolve_ids(asset_ids))


func _on_ambient_ready() -> void:
	## Ambient O4 → O5 bind → CTR-presentation.O3 with BED_M1 starts M1→M2→M1.
	if _ambient_started:
		return
	_provide_assets(_resolver.resolve_group("ambient"))
	_ambient_started = true
	_play_cue(SharedAudioCues.BED_M1)


func _provide_assets(resources_by_id: Dictionary) -> void:
	if resources_by_id.is_empty():
		return
	var host := get_parent()
	if host != null and host.has_method("provide_assets"):
		host.call("provide_assets", resources_by_id)


func _play_cue(cue_id: String) -> void:
	var host := get_parent()
	if host != null and host.has_method("play_cue"):
		host.call("play_cue", cue_id)


func _is_loss_end(reason: String) -> bool:
	return (
		reason == ChessRules.END_L1
		or reason == SharedGameSession.END_L2
		or reason == SharedGameSession.END_L3
	)


func _load_persist() -> void:
	if _persist == null:
		return
	var doc := _persist.load_document()
	last_mode = str(doc.get("last_mode", MODE_NONE))


func _go_mode_pick(ui_state: String = "S1") -> void:
	stage = STAGE_MODE_PICK
	options_locked = false
	_leave_advice()
	shared_session = null
	_last_clock_display = ""
	screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state(ui_state))
	## Mode pick is ready: preload Ambient and start BED_M1 (AST.G3 / SND.M1), #426.
	start_music()


## CMP-advice-client R1 / R6 / R7 — edge component configured from T6 / T9 / T10.
func _make_advice_client() -> AdviceClient:
	var client := AdviceClient.new()
	client.sim_factory = _advice_sim_factory()
	client.configure(advice_endpoint, advice_api_key, advice_time_ms)
	return client


## The simulated advice peer for tests and playtests (ADR-0002 Testability): the
## playtest build runs FakeAdviceTransport; the shipped export has no seam node,
## so production talks only to the configured backend. Never Stockfish.
func _advice_sim_factory() -> Variant:
	if _seams == null:
		return null
	return Callable(FakeAdviceTransport, "new")


## Drain streamed advice and report it (quality.md Observability; TEL.4 / TEL.5).
func _poll_advice() -> void:
	if shared_session == null:
		return
	var before := _advice_shown()
	_drive_advice("poll")
	if _advice_shown() != before:
		_emit_play_screen()


## Run one advice lifecycle step on the session and report its telemetry.
func _drive_advice(control_id: String) -> void:
	if shared_session == null:
		return
	var events: Array = shared_session.advice_control(control_id).get("events", [])
	for event in events:
		_emit_tel(
			str(event.get("event", "")), str(event.get("outcome", "")), str(event.get("story", ""))
		)


## S3 Dismiss — back to S1 with C1–C5 as S1; FAIL.T1 leaves the service offline.
## The session owns EX.error; this only reports the dismissal and re-renders.
func dismiss_advice_error() -> void:
	if shared_session == null or not shared_session.advice_error:
		return
	shared_session.advice_control("dismiss")
	_emit_tel("shared.advice.dismiss", "ok", "UI-shared-play.S3")
	_emit_play_screen()


## What L1 can show for advice; only an E1 update changes it.
func _advice_shown() -> String:
	if shared_session == null:
		return ""
	var state := shared_session.play_state()
	# S3 `EX.error` is advice chrome too: entering or leaving it must re-render
	# the play screen, or the panel never appears and Dismiss leaves it up.
	return (
		"%s|%s|%s"
		% [
			str(state.get("advice_best_move", null)),
			str(state.get("advice_eval", null)),
			str(shared_session.advice_error),
		]
	)


## R9 — leaving the Shared game clears advice and stops evaluation. The S3 error
## panel goes with the game (it belongs to the shared-play screen).
func _leave_advice() -> void:
	_drive_advice("leave")


## B3: both T9 and T10 must be set before Advice can fetch anything.
func _advice_available() -> bool:
	return not advice_endpoint.is_empty() and not advice_api_key.is_empty()


func _mode_pick_state(ui_state: String) -> Dictionary:
	mode_pick_ui_state = ui_state
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
	if shared_session == null:
		return {
			"locale": locale,
			"white_seat": white_seat,
			"clock": clock,
			"increment": increment,
			"advice": advice_on,
			"online": true,
			"advice_available": false,
			"options_locked": options_locked,
			"ui_state": SharedGameSession.UI_S1,
			"position": {},
			"selection": "",
			"legal": PackedStringArray(),
			"side_to_move": ChessRules.SIDE_WHITE,
			"in_check": false,
			"white_clock_ms": null,
			"black_clock_ms": null,
			"game_ended": false,
			"end_reason": "",
			"resign_available": false,
			"board_unavailable": false,
			"last_reject": "",
		}
	return shared_session.chrome_state(locale, white_seat)


func _emit_play_screen(move: Dictionary = {}) -> void:
	var state := _shared_play_state()
	if not move.is_empty():
		state["move"] = move
	screen_requested.emit(STAGE_SHARED_PLAY, state)
	play_rendered.emit(state)


func _on_mode_pick_control(control_id: String) -> void:
	# UI-mode-pick Controls table: C1–C4 are available when S1 or S4; S3 offers
	# only Confirm and Cancel. The input rail can still deliver a hidden id (#846),
	# so S3 refuses here as well as in the panel.
	if mode_pick_ui_state == "S3":
		_on_mode_pick_confirm_control(control_id)
	else:
		_on_mode_pick_choice_control(control_id)


## S3 (quit confirm) — only Confirm ends the session; Cancel returns to S1.
func _on_mode_pick_confirm_control(control_id: String) -> void:
	match control_id:
		"confirm":
			_end_session()
		"cancel":
			_go_mode_pick("S1")


## S1 / S4 — C1–C4, plus Dismiss returning to S1 from S4.
func _on_mode_pick_choice_control(control_id: String) -> void:
	match control_id:
		"C1":
			if _commit_last_mode(MODE_SHARED):
				last_mode = MODE_SHARED
				stage = STAGE_SHARED_SETUP
				screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C2":
			# UI-mode-pick.C2 / NAV.T2 / J-puzzle-session.S1 — enter the puzzle stream.
			if _commit_last_mode(MODE_PUZZLE):
				last_mode = MODE_PUZZLE
				_enter_puzzle_play()
		"C3":
			## Only the panel state moves: C3 opens the quit confirm, it does not
			## re-enter mode pick (which would reset options and restart the bed).
			screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S3"))
		"C4":
			locale = StringTable.next_locale(locale)
			screen_requested.emit(STAGE_MODE_PICK, _mode_pick_state("S1"))
		"dismiss":
			if mode_pick_ui_state == "S4":
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
	_clock_accum_ms = 0.0
	_last_clock_display = ""
	shared_session = SharedGameSession.new()
	shared_session.advice_client = _make_advice_client()
	shared_session.start_shared(clock, increment, advice_on)
	stage = STAGE_SHARED_PLAY
	enter_shared_play()
	_emit_tel("shared.start", "ok", "UI-shared-play.US1")
	_emit_play_screen()


func _on_shared_play_control(control_id: String) -> void:
	if shared_session == null:
		return
	# C10 / C6 focus activations reuse the board-gesture entrypoints.
	if control_id == "C10":
		handle_deselect()
		return
	if control_id.begins_with("C6:"):
		handle_promotion_commit(control_id.get_slice(":", 1))
		return
	var result := shared_session.handle_play_control(control_id)
	if not bool(result.get("ok", false)):
		return
	if control_id == "C3":
		advice_on = shared_session.advice_on
	if result.has("event"):
		_emit_tel_result(result)
	if bool(result.get("ended", false)):
		var end_reason := str(result.get("end_reason", ""))
		## Spec: draws play no end cue (SND, D1–D5); losses keep X4.
		if _is_loss_end(end_reason):
			_play_cue(SharedAudioCues.CUE_END)
		_emit_tel("shared.end", end_reason, "NAV.T6")
		_go_shared_result()
	else:
		_emit_play_screen()


func _on_shared_result_control(control_id: String) -> void:
	match control_id:
		"C1":
			# NAV.T7 / J-shared-session.B1 / L-two-player-game.K3 / PRG.F1 —
			# unlock setup; nothing from the finished game carries into the next.
			_emit_tel("shared.again", "ok", "NAV.T7")
			_reset_after_shared_end()
			stage = STAGE_SHARED_SETUP
			screen_requested.emit(STAGE_SHARED_SETUP, _shared_setup_state())
		"C2":
			# NAV.T8 / J-shared-session.S4 / FL-mode-pick.T3
			_emit_tel("shared.stop", "ok", "NAV.T8")
			_go_mode_pick("S1")


## ---------------------------------------------------------------------------
## UI-puzzle-play / J-puzzle-session — C2 entry (NAV.T2), the screen flow, and
## leave (NAV.T9). PuzzlePlayFlow owns the session, stream, cues and states.
## ---------------------------------------------------------------------------


## NAV.T2 — open `puzzle-play` on a fresh journey and ask the stream for its first deal.
func _enter_puzzle_play() -> void:
	stage = STAGE_PUZZLE_PLAY
	shared_session = null
	_leave_advice()
	options_locked = false
	_last_clock_display = ""
	start_music()
	# SND.X5 is the wrong-puzzle-move tap (sound.md X5); it loads with the Play group's
	# SFX, so the stream binds it before the first judged place.
	if not _resolver.group_loaded("play"):
		_resolver.preload_play()
	_provide_assets(_resolver.resolve_group("play"))
	puzzle_flow = PuzzlePlayFlow.new()
	puzzle_flow.locale = locale
	puzzle_flow.screen.connect(_on_puzzle_screen)
	puzzle_flow.cue.connect(_play_cue)
	puzzle_flow.telemetry.connect(_on_puzzle_telemetry)
	puzzle_flow.left.connect(_on_puzzle_left)
	puzzle_flow.enter(_persist, advice_endpoint, advice_api_key, _puzzle_sim_factory())


## The simulated catalog peer for tests and playtests (ADR-0013 Testability).
func _puzzle_sim_factory() -> Variant:
	if _seams == null:
		return null
	return Callable(FakeCatalogTransport, "new")


## CTR-presentation.E1 — the journey's screen state goes up to the presentation.
func _on_puzzle_screen(state: Dictionary) -> void:
	screen_requested.emit(STAGE_PUZZLE_PLAY, state)
	play_rendered.emit(state)


## TEL.1–TEL.5 — forward the journey's telemetry through the seams.
func _on_puzzle_telemetry(event_name: String, outcome: String, story_id: String) -> void:
	_emit_tel(event_name, outcome, story_id)


## NAV.T9 / J-puzzle-session.S2 + N2 — the journey left; mode pick returns.
func _on_puzzle_left() -> void:
	puzzle_flow = null
	_go_mode_pick("S1")


## UI-puzzle-play C3–C5 / S2 + S3 — one stream control tap.
func _on_puzzle_play_control(control_id: String) -> void:
	if puzzle_flow == null or _seams_paused():
		return
	puzzle_flow.control(control_id)


func _reset_after_shared_end() -> void:
	## PRG.F1 / K3: drop live game so the next Start is orthodox opening + fresh clocks.
	_leave_advice()
	shared_session = null
	_clock_accum_ms = 0.0
	_last_clock_display = ""
	options_locked = false


func _apply_select(square: String) -> bool:
	var result := shared_session.select_own(square)
	if not bool(result.get("ok", false)):
		return false
	_play_cue(SharedAudioCues.CUE_SELECT)
	_emit_tel_result(result)
	_emit_play_screen()
	return true


func _apply_place(from_square: String, to_square: String, promotion: String = "") -> bool:
	var result := shared_session.place(from_square, to_square, promotion)
	_emit_tel_result(result)
	if str(result.get("event", "")) == "shared.deselect":
		_emit_play_screen()
		return true
	if bool(result.get("promote", false)):
		_emit_play_screen()
		return true
	if bool(result.get("illegal", false)):
		_emit_play_screen()
		return false
	if not bool(result.get("ok", false)):
		return false
	## SEQ-apply-local-move S4 — move settle cue with travel; check / loss end after.
	_play_cue(SharedAudioCues.CUE_MOVE)
	var ended := bool(result.get("ended", false))
	var end_reason := str(result.get("end_reason", ""))
	if ended and _is_loss_end(end_reason):
		_play_cue(SharedAudioCues.CUE_END)
	elif bool(result.get("check", false)):
		_play_cue(SharedAudioCues.CUE_CHECK)
		_emit_tel("shared.check", "shown", "UI-shared-play.US2")
	var move: Dictionary = result.get("move", {}) as Dictionary
	_emit_play_screen(move)
	if ended:
		_emit_tel("shared.end", end_reason, "NAV.T6")
		_go_shared_result()
	return true


func _emit_tel_result(result: Dictionary) -> void:
	var event := str(result.get("event", ""))
	if event.is_empty():
		return
	_emit_tel(event, str(result.get("outcome", "ok")), str(result.get("story", "")))


func _go_shared_result() -> void:
	## NAV.T6 — clocks already stopped by SharedGameSession._finish (K3); router
	## _process only ticks on shared-play, so they stay stopped on this screen.
	stage = STAGE_SHARED_RESULT
	_clock_accum_ms = 0.0
	_last_clock_display = ""
	var result_key := ""
	var clocks_stopped := true
	if shared_session != null:
		result_key = shared_session.result_copy_key()
		shared_session.play_ui_state = SharedGameSession.UI_S1
		shared_session.selected_piece = ""
		clocks_stopped = bool(shared_session.play_state().get("clocks_stopped", true))
	(
		screen_requested
		. emit(
			STAGE_SHARED_RESULT,
			{
				"locale": locale,
				"result_key": result_key,
				"last_mode": last_mode,
				"game_ended": true,
				"clocks_stopped": clocks_stopped,
			}
		)
	)


func _next_in(values: Array, current: String) -> String:
	var index := values.find(current)
	if index < 0:
		return str(values[0])
	return str(values[(index + 1) % values.size()])


func _end_session() -> void:
	session_ended = true
	stage = STAGE_ENDED
	_leave_advice()
	shared_session = null
	screen_requested.emit(STAGE_ENDED, {"locale": locale, "last_mode": last_mode})


func _on_unresolved_overlay(asset_id: String) -> void:
	if _seams != null:
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
				shared_session.advice_client = _make_advice_client()
				shared_session.start_shared(clock, increment, advice_on)
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
	_last_clock_display = ""
	screen_requested.emit(STAGE_LOADING, {})
	_resolver.preload_boot()


func _on_input_replayed(record: Dictionary) -> void:
	replay_pointer.emit(record)
