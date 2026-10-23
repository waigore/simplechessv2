extends SceneTree
## #375 AC11 — R3 advice display on the SHIPPED release scene graph.
##
## Loads `res://main_release.tscn` (no PlaytestSeams, so `SessionRouter` builds
## `AdviceStreamTransport` and `AdviceClient.sim_factory` is null) and points the
## router's T9/T10 configuration at a reachable CTR-advice-stream peer. It drives
## the real `Presentation` control paths (shared-setup C1 → C5, shared-play C3,
## input_commit) and reads what the presentation RENDERED, not the session alone.
##
## Talk on stdout as `R375 {...}` JSON lines. Exit code is the number of failed
## checks.

const RELEASE_SCENE := "res://main_release.tscn"
const BOARD_GROUP := "board_presentation"

var _failures := 0
var _checks := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(name: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("R375 ", JSON.stringify({"check": name, "ok": ok, "detail": detail}))


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


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


func _find_board(root: Node) -> Node:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is BoardPresentation:
			return node
		for child in node.get_children():
			stack.append(child)
	# Scene-tree find_child skips internal children only, so this reaches the
	# board the presentation built in code.
	return root.find_child("BoardPresentation", true, false)


func _advice_marks(board: Node) -> AdviceMarks:
	if board == null:
		return null
	var node := board.find_child("AdviceMarks", true, false)
	return node as AdviceMarks


func _run() -> void:
	var endpoint := OS.get_environment("R375_ENDPOINT").strip_edges()
	var api_key := OS.get_environment("R375_KEY").strip_edges()
	var phase := OS.get_environment("R375_PHASE").strip_edges()
	_check("scene_is_release", ResourceLoader.exists(RELEASE_SCENE), RELEASE_SCENE)

	var packed: PackedScene = load(RELEASE_SCENE)
	var root: Node = packed.instantiate()
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
	router.advice_endpoint = endpoint
	router.advice_api_key = api_key

	# Mode pick → Shared setup.
	presentation.control_activate.emit("mode-pick", "C1")
	await _frames(2)
	_check("setup_reached", router.stage == SessionRouter.STAGE_SHARED_SETUP, router.stage)

	# Setup R1 / C4: default On, one press flips to Off, another back to On.
	_check("setup_advice_default_on", router.advice_on, str(router.advice_on))
	presentation.control_activate.emit("shared-setup", "C4")
	await _frames(1)
	_check("setup_c4_off", not router.advice_on, str(router.advice_on))
	presentation.control_activate.emit("shared-setup", "C4")
	await _frames(1)
	_check("setup_c4_on", router.advice_on, str(router.advice_on))

	# The drive may hold the scene across an exit, so keep polling alive.
	root.process_mode = Node.PROCESS_MODE_ALWAYS

	# C5 starts the Shared game.
	presentation.control_activate.emit("shared-setup", "C5")
	await _frames(3)
	_check("play_reached", router.stage == SessionRouter.STAGE_SHARED_PLAY, router.stage)
	var session := router.shared_session
	_check("session_has_client", session != null and session.advice_client != null)
	_check("client_is_shipped_transport", session.advice_client.sim_factory == null)
	var board := _find_board(root)
	var marks := _advice_marks(board)
	_check("board_and_marks_present", board != null and marks != null)
	if phase == "":
		_check("no_phase_selected", false, phase)
		await _finish()
		return

	if phase == "toggle":
		# C3 Off clears immediately, On re-evaluates.
		var shown := await _wait_for(
			func() -> bool: return marks != null and not marks.last_from.is_empty(), 4000
		)
		_check("marks_appear_after_start", shown, _marks_detail(marks))
		var state: Dictionary = session.play_state()
		_check("eval_set", state.get("advice_eval") is int, str(state.get("advice_eval")))
		_check(
			"presentation_rendered_eval",
			_presentation_eval(presentation) != "",
			_presentation_eval(presentation)
		)
		print("R375 ", JSON.stringify({"marks_while_on": _marks_detail(marks)}))
		presentation.control_activate.emit("shared-play", "C3")
		await _frames(3)
		var off_state: Dictionary = session.play_state()
		_check("c3_sets_advice_off", not bool(off_state.get("advice", true)), str(off_state))
		_check(
			"c3_clears_marks_at_once",
			marks != null and marks.last_from.is_empty(),
			_marks_detail(marks)
		)
		_check(
			"c3_clears_eval_at_once",
			off_state.get("advice_eval") == null,
			str(off_state.get("advice_eval"))
		)
		presentation.control_activate.emit("shared-play", "C3")
		await _frames(3)
		var again := await _wait_for(
			func() -> bool: return marks != null and not marks.last_from.is_empty(), 4000
		)
		_check("c3_on_re_evaluates", again, _marks_detail(marks))
		await _finish()
		return

	if phase == "play":
		# R3 display + local move never waits + E4 clearing on move complete.
		var shown := await _wait_for(
			func() -> bool: return marks != null and not marks.last_from.is_empty(), 4000
		)
		_check("marks_appear_after_start", shown, _marks_detail(marks))
		var state: Dictionary = session.play_state()
		var move_variant: Variant = state.get("advice_best_move")
		_check("advice_best_move_dict", move_variant is Dictionary, str(move_variant))
		var eval_variant: Variant = state.get("advice_eval")
		_check("advice_eval_int", eval_variant is int, str(eval_variant))
		var eval_text := _presentation_eval(presentation)
		_check("presentation_rendered_eval", eval_text != "", eval_text)
		print(
			"R375 ",
			JSON.stringify(
				{
					"displayed":
					{"best_move": move_variant, "eval": eval_variant, "eval_text": eval_text}
				}
			)
		)
		# A local move must not wait on advice traffic.
		var started := Time.get_ticks_msec()
		presentation.input_commit.emit("e2", "e4", "")
		await _frames(2)
		var waited := Time.get_ticks_msec() - started
		var after: Dictionary = session.play_state()
		var side := str((after.get("position", {}) as Dictionary).get("side_to_move", ""))
		_check("local_move_applied", side == ChessRules.SIDE_BLACK, "side_to_move=%s" % side)
		_check("local_move_not_delayed", waited < 150, "waited_ms=%d" % waited)
		# R8: move complete clears advice immediately; R9/R2 re-evaluates for Black.
		var cleared_white := await _wait_for(_advice_field_is_clear.bind(session), 2000)
		_check("move_complete_clears_advice", cleared_white, _marks_detail(marks))
		var black_shown := await _wait_for(
			func() -> bool: return marks != null and not marks.last_from.is_empty(), 4000
		)
		_check("black_advice_appears", black_shown, _marks_detail(marks))
		await _finish()
		return

	if phase == "telemetry":
		# TEL.4 / TEL.5 — the judged stories carry their IDs. Telemetry is emitted
		# through the playtest seam, which the release scene graph does not carry
		# (G2), so this phase binds a recorder in its place and reads the router's
		# real emissions rather than claiming a seam-based capture.
		var recorded: Array = []
		router.set("_seams", _FakeTelRecorder.new(recorded))
		presentation.control_activate.emit("shared-play", "C3")
		await _frames(2)
		presentation.control_activate.emit("shared-play", "C3")
		await _frames(2)
		print("R375 ", JSON.stringify({"telemetry": recorded}))
		_check("tel_toggle_story_ids", _tel_has(recorded, "shared.advice", "UI-shared-play.US1.4"))
		await _finish()
		return

	if phase == "error":
		# EX.error / S3: a failed fetch while On raises the error, board stays playable.
		var errored := await _wait_for(func() -> bool: return session.advice_error, 5000)
		_check("advice_error_raised", errored, str(session.advice_error))
		_check("ui_state_s3", router.play_ui_state == SharedGameSession.UI_S3, router.play_ui_state)
		_check("board_still_renders", marks != null, _marks_detail(marks))
		presentation.input_commit.emit("e2", "e4", "")
		await _frames(2)
		var after: Dictionary = session.play_state()
		var side := str((after.get("position", {}) as Dictionary).get("side_to_move", ""))
		_check("local_move_while_s3", side == ChessRules.SIDE_BLACK, "side_to_move=%s" % side)
		var error_shown := _presentation_error(presentation)
		_check("error_dialog_visible", error_shown, str(error_shown))
		print("R375 ", JSON.stringify({"error_panel": _error_detail(presentation)}))
		var panel: Node = presentation.find_child("AdviceErrorDismiss", true, false)
		_check("dismiss_control_present", panel is Button, str(panel))
		(panel as Button).pressed.emit()
		await _frames(3)
		_check("dismiss_clears_error", not session.advice_error, str(session.advice_error))
		await _frames(2)
		_check(
			"dismiss_returns_s1",
			not _presentation_error(presentation),
			str(_error_detail(presentation))
		)
		_check(
			"ui_state_s1_after_dismiss",
			router.play_ui_state == SharedGameSession.UI_S1,
			router.play_ui_state
		)
		await _finish()
		return

	await _finish()


func _marks_detail(marks: AdviceMarks) -> String:
	if marks == null:
		return "marks=<null>"
	return "from=%s to=%s children=%d" % [marks.last_from, marks.last_to, marks.get_child_count()]


func _advice_field_is_clear(session: SharedGameSession) -> bool:
	var live: Dictionary = session.play_state()
	return not (live.get("advice_best_move") is Dictionary)


func _tel_has(recorded: Array, event_name: String, story_id: String) -> bool:
	for record in recorded:
		if (
			str((record as Dictionary).get("event", "")) == event_name
			and str((record as Dictionary).get("story", "")) == story_id
		):
			return true
	return false


## Stand-in for the seam's `emit_tel` so the release graph's real emissions are
## readable; it records the router's own (event, outcome, story) triples.
class _FakeTelRecorder:
	extends RefCounted

	var _recorded: Array

	func _init(recorded: Array) -> void:
		_recorded = recorded

	func emit_tel(event_name: String, outcome: String, story_id: String = "") -> void:
		_recorded.append({"event": event_name, "outcome": outcome, "story": story_id})

	func is_paused() -> bool:
		return false

	func note_pointer(_record: Dictionary) -> void:
		return


func _presentation_eval(presentation: Presentation) -> String:
	var label := presentation.find_child("AdviceEval", true, false)
	if label == null:
		return ""
	var eval_label := label as Label
	return eval_label.text if eval_label.visible else ""


func _presentation_error(presentation: Presentation) -> bool:
	var box := presentation.find_child("AdviceError", true, false)
	return box != null and box.visible


func _error_detail(presentation: Presentation) -> Dictionary:
	var box := presentation.find_child("AdviceError", true, false)
	if box == null:
		return {}
	var texts: Array = []
	for node in box.find_children("*", "Label", true, false):
		texts.append((node as Label).text)
	return {"visible": box.visible, "texts": texts}


func _finish() -> void:
	print("R375 ", JSON.stringify({"summary": {"checks": _checks, "failed": _failures}}))
	await _reset()
	quit(_failures)


## Join the transport worker before quit so the process exits cleanly: the
## shipped AdviceStreamTransport runs its request on a Thread, and a stream
## still open at teardown crashes the engine on exit (evidence-run harness only;
## the scene is untouched before this point).
func _reset() -> void:
	var router: Node = null
	for node in get_root().get_children():
		if node.has_method("_leave_advice"):
			router = node
			break
	if router == null:
		return
	router.call("_leave_advice")
	if router.get("shared_session") != null:
		var client: Variant = router.get("shared_session").get("advice_client")
		if client != null:
			var transport: Variant = client.get("_transport")
			if transport != null:
				if transport.get("_thread") != null:
					var worker: Thread = transport.get("_thread")
					worker.wait_to_finish()
				transport.set("_finished", true)
			client.set("_transport", null)
	for _i in 120:
		OS.delay_msec(5)
		await process_frame
	await process_frame
	await process_frame
