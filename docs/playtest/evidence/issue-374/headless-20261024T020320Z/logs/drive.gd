extends SceneTree
## #374 — `PTD-move-advice` on the SHIPPED release scene graph.
##
## Loads `res://main_release.tscn` (no PlaytestSeams, so `SessionRouter` builds
## `AdviceStreamTransport` and `AdviceClient.sim_factory` is null) and points the
## router's T9/T10 configuration at a reachable CTR-advice-stream peer. Every
## state change is driven through the real `Presentation` control paths
## (`control_activate`, `input_commit`) and read back from the session's play
## state, so the judged behaviour is the shipped one (Gate — #534).
##
## Env: R374_ENDPOINT, R374_KEY, R374_PHASE (advice | lifecycle | failure).
## Talks on stdout as `R374 {...}` JSON lines; exit code is the failed checks.

const RELEASE_SCENE := "res://main_release.tscn"

var _failures := 0
var _checks := 0
var _endpoint := ""
var _started_ms := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_endpoint = OS.get_environment("R374_ENDPOINT").strip_edges()
	var key := OS.get_environment("R374_KEY").strip_edges()
	var phase := OS.get_environment("R374_PHASE").strip_edges()
	_started_ms = Time.get_ticks_msec()
	_check("scene_is_release", ResourceLoader.exists(RELEASE_SCENE), RELEASE_SCENE)

	var root: Node = (load(RELEASE_SCENE) as PackedScene).instantiate()
	root.process_mode = Node.PROCESS_MODE_DISABLED
	get_root().add_child(root)
	root.process_mode = Node.PROCESS_MODE_INHERIT
	await _frames(2)
	_check("release_scene_has_no_seams", root.get_node_or_null("PlaytestSeams") == null)

	var router: SessionRouter = root.get_node_or_null("SessionRouter")
	var presentation: Presentation = root.get_node_or_null("Presentation")
	if presentation == null:
		presentation = root as Presentation
	_check("router_present", router != null)
	_check("presentation_present", presentation != null)
	if router == null or presentation == null:
		await _finish()
		return
	router.advice_endpoint = _endpoint
	router.advice_api_key = key

	match phase:
		"advice":
			await _phase_advice(router, presentation)
		"lifecycle":
			await _phase_lifecycle(router, presentation)
		"failure":
			await _phase_failure(router, presentation)
		_:
			_check("no_phase_selected", false, phase)
	await _finish()


## AC 1 / AC 2 / AC 12 — advice arrives on its own and keeps deepening until the cap.
func _phase_advice(router: SessionRouter, presentation: Presentation) -> void:
	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(2)
	_check("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)
	var session := router.shared_session
	_check("client_is_shipped_transport", session.advice_client.sim_factory == null)

	var first_at: Array = [-1]
	var seen: Array = []
	var watch := func() -> bool:
		var live: Dictionary = session.play_state()
		if live.get("advice_best_move") is Dictionary:
			if int(first_at[0]) < 0:
				first_at[0] = Time.get_ticks_msec() - _started_ms
			var move: Dictionary = live["advice_best_move"]
			var mark := (
				"%s->%s/%s"
				% [move.get("from", ""), move.get("to", ""), str(live.get("advice_eval"))]
			)
			if not seen.has(mark):
				seen.append(mark)
			return str(live.get("advice_eval")) == "41"
		return false
	var finished := await _watch_until(watch, 2000)
	_check("advice_stream_reached_cap", finished, "first_update_ms=%s" % str(first_at[0]))
	var state: Dictionary = session.play_state()
	print(
		"R374 ",
		(
			JSON
			. stringify(
				{
					"advice":
					{
						"first_update_ms": first_at[0],
						"updates_seen": seen,
						"best_move": state.get("advice_best_move"),
						"eval": state.get("advice_eval"),
						"online": state.get("online"),
						"advice": state.get("advice"),
					}
				}
			)
		)
	)
	_check(
		"advice_arrived_without_asking", int(first_at[0]) >= 0, "first_update_ms=%s" % first_at[0]
	)
	_check("updates_deepened", seen.size() >= 2, "updates=%s" % [seen])
	_check(
		"final_eval_at_cap", str(state.get("advice_eval")) == "41", str(state.get("advice_eval"))
	)
	var move: Variant = state.get("advice_best_move")
	_check(
		"best_move_for_side_to_move",
		(
			move is Dictionary
			and str((move as Dictionary).get("from")) == "e2"
			and str((move as Dictionary).get("to")) == "e4"
		),
		str(move)
	)
	_check("advice_on", bool(state.get("advice", false)), str(state.get("advice")))
	_check("online_after_stream", bool(state.get("online", false)), str(state.get("online")))
	_check(
		"no_principal_line",
		not state.has("advice_pv") and not state.has("advice_line"),
		str(state.keys())
	)
	_check(
		"first_update_before_cap",
		int(first_at[0]) >= 0 and int(first_at[0]) < 600,
		"first_update_ms=%s" % first_at[0]
	)
	_check(
		"eval_rendered", _presentation_eval(presentation) != "", _presentation_eval(presentation)
	)
	await _settle(session)
	await _frames(120)


## AC 3–AC 7 — never-delay, clear + re-evaluate, Off/end/leave, Puzzle stream.
func _phase_lifecycle(router: SessionRouter, presentation: Presentation) -> void:
	var origin: Variant = _board_target(presentation)
	_check("board_transform_found", origin != null, str(origin))
	if origin == null:
		return
	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(2)
	var session := router.shared_session
	_check("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)

	var shown := await _wait_for(
		func() -> bool: return session.play_state().get("advice_best_move") is Dictionary, 2000
	)
	_check("advice_shown_before_move", shown, _detail(session))
	var requests_before := _streams(session)

	# AC 3 — HUD click-to-move while a stream is in flight.
	var hud_started := Time.get_ticks_msec()
	var clicked := await _click(presentation, origin, "e2", "e4")
	await _frames(2)
	var hud_ms := Time.get_ticks_msec() - hud_started
	var after_hud: Dictionary = session.play_state()
	print("R374 ", JSON.stringify({"hud": {"waited_ms": hud_ms, "detail": _detail(session)}}))
	_check(
		"hud_move_not_delayed",
		clicked and _side(after_hud) == ChessRules.SIDE_BLACK,
		"waited_ms=%d detail=%s" % [hud_ms, _detail(session)]
	)
	# R8 — move complete clears, then the new position is evaluated.
	_check("hud_move_cleared_advice", after_hud.get("advice_best_move") == null, _detail(session))
	await _wait_for(
		func() -> bool:
			var live: Dictionary = session.play_state()
			return (
				live.get("advice_best_move") is Dictionary and str(live.get("advice_eval")) == "-14"
			),
		2000
	)
	var black_state: Dictionary = session.play_state()
	var black_shown: bool = black_state.get("advice_best_move") is Dictionary
	var black_move: Variant = black_state.get("advice_best_move")
	print(
		"R374 ",
		(
			JSON
			. stringify(
				{
					"re_evaluated":
					{
						"best_move": black_move,
						"eval": black_state.get("advice_eval"),
						"streams_started": _streams(session),
					}
				}
			)
		)
	)
	_check(
		"black_position_evaluated",
		black_move is Dictionary and str((black_move as Dictionary).get("to")) == "e5",
		_detail(session)
	)
	_check("re_evaluated_after_move", _streams(session) > requests_before, str(_streams(session)))
	_check(
		"re_evaluation_asks_black", _side(black_state) == ChessRules.SIDE_BLACK and black_shown, ""
	)

	# AC 3 — drag path (press, motion, release) while a stream is in flight.
	var drag_started := Time.get_ticks_msec()
	await _drag(presentation, origin, "e7", "e5")
	await _frames(2)
	var after_drag: Dictionary = session.play_state()
	print(
		"R374 ",
		JSON.stringify(
			{
				"drag":
				{"waited_ms": Time.get_ticks_msec() - drag_started, "detail": _detail(session)}
			}
		)
	)
	_check("drag_move_applied", _side(after_drag) == ChessRules.SIDE_WHITE, _detail(session))
	_check("drag_move_not_delayed", after_drag.get("advice_best_move") == null, _detail(session))
	var white_shown := await _wait_for(
		func() -> bool: return session.play_state().get("advice_best_move") is Dictionary, 2000
	)
	_check("white_position_re_evaluated", white_shown, _detail(session))

	# AC 5 — Advice Off clears at once and stops evaluation.
	presentation.control_activate.emit("shared-play", "C3")
	await _frames(2)
	var off_state: Dictionary = session.play_state()
	_check("c3_advice_off", not bool(off_state.get("advice", true)), str(off_state.get("advice")))
	_check("c3_clears_advice", off_state.get("advice_best_move") == null, _detail(session))
	var off_requests := _streams(session)
	await _wait_ms(500)
	_check("c3_stops_evaluation", _streams(session) == off_requests, str(_streams(session)))
	presentation.control_activate.emit("shared-play", "C3")
	await _frames(2)
	var back_on := await _wait_for(
		func() -> bool: return session.play_state().get("advice_best_move") is Dictionary, 2000
	)
	_check("c3_on_restarts", back_on and _streams(session) > off_requests, _detail(session))

	# AC 4 — game end clears advice.
	presentation.control_activate.emit("shared-play", "C4")
	presentation.control_activate.emit("shared-play", "confirm")
	await _frames(3)
	_check("resign_reached_result", router.stage == SessionRouter.STAGE_SHARED_RESULT, router.stage)
	_check(
		"game_end_cleared_advice",
		session.play_state().get("advice_best_move") == null,
		_detail(session)
	)
	var ended_requests := _requests().size()
	await _wait_ms(300)
	_check(
		"game_end_stopped_evaluation", _requests().size() == ended_requests, str(_requests().size())
	)
	# R9 — leaving the Shared game clears and stops.
	presentation.control_activate.emit("shared-result", "C2")
	await _frames(3)
	_check("left_shared_game", router.stage == SessionRouter.STAGE_MODE_PICK, router.stage)

	# AC 7 — Puzzle stream carries no advice.
	await _enter_puzzle(presentation)
	var puzzle: Dictionary = router.play_snapshot()
	print("R374 ", JSON.stringify({"puzzle": puzzle}))
	_check("puzzle_reached", router.stage == SessionRouter.STAGE_PUZZLE_PLAY, router.stage)
	# Puzzle is judged on the snapshot the puzzle screen renders: it must carry
	# no advice and no advice capability (the puzzle session's own `play_state`
	# still reports `advice: "none"`; this is what the player is shown).
	_check(
		"puzzle_screen_mode",
		str(puzzle.get("mode", "")) == "puzzle" and router.stage == SessionRouter.STAGE_PUZZLE_PLAY,
		str(puzzle.get("mode"))
	)
	_check(
		# The router advertises no advice to the puzzle screen: B3's endpoint/key
		# gate reports false there, so nothing on that screen can fetch advice.
		"puzzle_no_advice_request",
		not bool(puzzle.get("advice_available", true)),
		str(puzzle.get("advice_available"))
	)
	_check(
		"puzzle_no_advice_fields",
		puzzle.get("advice_best_move") == null and puzzle.get("advice_eval") == null,
		"best=%s eval=%s" % [str(puzzle.get("advice_best_move")), str(puzzle.get("advice_eval"))]
	)
	await _wait_ms(400)
	var later: Dictionary = router.play_snapshot()
	_check(
		"puzzle_advice_still_none",
		later.get("advice_best_move") == null and later.get("advice_eval") == null,
		"best=%s" % str(later.get("advice_best_move"))
	)
	await _settle(router.shared_session)


## AC 10 / AC 12 — a connection loss mid-evaluation clears advice and reports once.
func _phase_failure(router: SessionRouter, presentation: Presentation) -> void:
	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(2)
	var session := router.shared_session
	_check("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)
	var lost := await _wait_for(
		func() -> bool: return not bool(session.play_state().get("online", true)), 3000
	)
	await _wait_ms(1200)
	var state: Dictionary = session.play_state()
	print(
		"R374 ",
		(
			JSON
			. stringify(
				{
					"failure":
					{
						"online": state.get("online"),
						"best_move": state.get("advice_best_move"),
						"eval": state.get("advice_eval"),
						"error": session.advice_error,
						"streams_started": _streams(session),
					}
				}
			)
		)
	)
	_check(
		"connection_loss_marks_offline",
		lost and not bool(state.get("online", true)),
		str(state.get("online"))
	)
	_check("loss_clears_advice", state.get("advice_best_move") == null, _detail(session))
	# Play continues: the local move still applies while the service is offline.
	presentation.input_commit.emit("e2", "e4", "")
	await _frames(2)
	var after: Dictionary = session.play_state()
	_check("play_continues_offline", _side(after) == ChessRules.SIDE_BLACK, _detail(session))
	var serialized := JSON.stringify(session.advice_control("poll"))
	_check("one_error_not_per_poll", serialized == '{"events":[]}', serialized)
	await _settle(session)


# --- helpers ---------------------------------------------------------------


func _click(
	presentation: Presentation, origin: Dictionary, from_square: String, to_square: String
) -> bool:
	var from_point := _board_point(origin, from_square)
	var to_point := _board_point(origin, to_square)
	_touch(presentation, true, 0, from_point)
	_touch(presentation, false, 0, from_point)
	await process_frame
	await process_frame
	_touch(presentation, true, 0, to_point)
	_touch(presentation, false, 0, to_point)
	return true


func _drag(
	presentation: Presentation, origin: Dictionary, from_square: String, to_square: String
) -> void:
	var from_point := _board_point(origin, from_square)
	var to_point := _board_point(origin, to_square)
	_touch(presentation, true, 0, from_point)
	var steps := 8
	for step in range(1, steps + 1):
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = from_point.lerp(to_point, float(step) / float(steps))
		drag.relative = (to_point - from_point) / float(steps)
		presentation.handle_gui_input(drag)
	_touch(presentation, false, 0, to_point)


func _touch(presentation: Presentation, pressed: bool, index: int, point: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.pressed = pressed
	event.index = index
	event.position = point
	presentation.handle_gui_input(event)


## The board control plus its own world-to-screen mapping: the board projects
## through `BoardPresentation.world_to_screen`, so a probe that wants the real
## HUD hit-test goes through the same call rather than re-deriving a transform.
func _board_target(presentation: Presentation) -> Variant:
	var board: Node = presentation.find_child("BoardPresentation", true, false)
	if not (board is BoardPresentation):
		return null
	var control := board as BoardPresentation
	print(
		"R374 ",
		(
			JSON
			. stringify(
				{
					"board":
					{
						"size": [control.size.x, control.size.y],
						"seat": control.white_seat,
						"e2": _vec(control.world_to_screen(BoardGeometry.square_center("e2"))),
						"e4": _vec(control.world_to_screen(BoardGeometry.square_center("e4"))),
					}
				}
			)
		)
	)
	return {"board": control}


func _vec(point: Vector2) -> Array:
	return [point.x, point.y]


func _board_point(origin: Dictionary, square: String) -> Vector2:
	var board := origin["board"] as BoardPresentation
	return board.world_to_screen(BoardGeometry.square_center(square))


func _enter_puzzle(presentation: Presentation) -> void:
	presentation.control_activate.emit("mode-pick", "C2")
	await _frames(3)


func _requests() -> Array:
	var out: Array = []
	var path := OS.get_environment("R374_PEER_LOG")
	if path.is_empty() or not FileAccess.file_exists(path):
		return out
	for line in FileAccess.get_file_as_string(path).split("\n", false):
		var parsed: Variant = JSON.parse_string(line)
		if parsed is Dictionary:
			out.append(parsed)
	return out


## Streams the client actually opened: the client's own counter, not the peer
## process's log (which is written by another process and lags a running run).
func _streams(session: SharedGameSession) -> int:
	if session == null or session.advice_client == null:
		return -1
	return int(session.advice_client.get("_stream_id"))


func _side(state: Dictionary) -> String:
	return str((state.get("position", {}) as Dictionary).get("side_to_move", ""))


func _detail(session: SharedGameSession) -> String:
	if session == null:
		return "session=<null>"
	var state := session.play_state()
	return (
		"side=%s best=%s eval=%s online=%s advice=%s stage=%s"
		% [
			_side(state),
			str(state.get("advice_best_move")),
			str(state.get("advice_eval")),
			str(state.get("online")),
			str(state.get("advice")),
			str(state.get("play_ui_state")),
		]
	)


func _presentation_eval(presentation: Presentation) -> String:
	var node := presentation.find_child("AdviceEval", true, false)
	if node == null:
		return ""
	var label := node as Label
	return label.text if label.visible else ""


func _check(name: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("R374 ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


## Poll a predicate on a real timer, so the frame keeps turning while network
## messages arrive (a tight `await process_frame` loop starves the patch).
func _watch_until(predicate: Callable, timeout_ms: int) -> bool:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < timeout_ms:
		if predicate.call():
			return true
		await create_timer(0.01).timeout
	return false


func _wait_ms(ms: int) -> void:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < ms:
		await process_frame


func _wait_for(callable: Callable, timeout_ms: int) -> bool:
	var started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - started < timeout_ms:
		if callable.call():
			return true
		await process_frame
	return false


## Join the transport worker before quitting: a stream still open at teardown
## crashes the engine on exit (evidence harness only; the scene is untouched).
func _settle(session: SharedGameSession) -> void:
	if session == null or session.advice_client == null:
		return
	session.advice_control("leave")
	var transport: Variant = session.advice_client.get("_transport")
	if transport != null:
		var worker: Variant = transport.get("_thread")
		if worker != null:
			(worker as Thread).wait_to_finish()
		transport.set("_thread", null)
		transport.set("_finished", true)
	session.advice_client.set("_transport", null)
	# Let the worker thread finish before the tree is freed at quit.
	await create_timer(0.3).timeout


func _finish() -> void:
	print("R374 ", JSON.stringify({"summary": {"checks": _checks, "failed": _failures}}))
	# Clear the scene before quitting, so no node outlives the tree it belonged to.
	for node in get_root().get_children():
		get_root().remove_child(node)
		node.free()
	await create_timer(0.2).timeout
	quit(_failures)
