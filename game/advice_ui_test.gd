class_name AdviceUiTest
extends SceneTree
## UI-shared-play.R3, C3, S3 `EX.error` and UI-shared-setup.R1 / C4 (#375). The
## advice peer is simulated through AdviceClient's test seam (ADR-0002
## Testability); no Stockfish endpoint is involved.

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams
var _tel: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	_seams.tel_event.connect(_remember_tel)
	_router.advice_endpoint = "http://advice.test/advice"
	_router.advice_api_key = "test-key"
	_router.advice_on = true
	var problem := _enter_play()
	if problem.is_empty():
		problem = _eval_hidden_until_set()
	if problem.is_empty():
		problem = _marks_show_and_clear()
	if problem.is_empty():
		problem = _marks_fit_the_body_bound()
	if problem.is_empty():
		problem = _toggle_clears_at_once()
	if problem.is_empty():
		problem = _marks_clear_on_move()
	if problem.is_empty():
		problem = _offline_hides_marks()
	if problem.is_empty():
		problem = await _error_s3_dismiss()
	if problem.is_empty():
		problem = _leave_clears_marks()
	if problem.is_empty():
		problem = _setup_row_c4()
	if problem.is_empty():
		problem = _copy_is_localized()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _enter_play() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	if _router.stage != "shared-play" or _router.shared_session == null:
		return "advice UI needs a Shared game"
	if _peer() == null:
		return "the playtest build must run a simulated advice peer"
	return ""


## The simulated peer, only while the advice service is reachable (R2); after
## FAIL.T1 the browser is offline, so nothing streams until it reconnects.
func _peer() -> FakeAdviceTransport:
	if _router.shared_session == null or _router.shared_session.advice_client == null:
		return null
	var client := _router.shared_session.advice_client
	if client.sim_factory == null or not _router.shared_session.online:
		return null
	# A closed stream means the client is between requests: open a fresh peer.
	if client._transport == null:
		client.start(
			_router.shared_session.rules.position_field(),
			_router.shared_session.rules.castling_ep()
		)
	return client._transport as FakeAdviceTransport


func _marks() -> AdviceMarks:
	return _board().find_child("AdviceMarks", true, false) as AdviceMarks


func _eval_label() -> Label:
	return _play_panel().find_child("AdviceEval", true, false) as Label


func _eval_hidden_until_set() -> String:
	var eval_label := _eval_label()
	if eval_label == null:
		return "R3 eval label missing"
	return _first_fail(
		[
			[not eval_label.visible, "R3 eval must not show before values are set"],
			[_marks().last_from.is_empty(), "R3 marks must not show before values are set"],
			[
				_play_panel().find_child("AdviceToggle", true, false) != null,
				"R3 Advice toggle missing",
			],
			[AdviceMarks.COLOR_ADVICE == Color("53A2BE"), "PER.R5 marks must use PAL.C7"],
			[SharedPlayPanel.format_eval(-120) == "-1.20", "R3 eval from White's view"],
		]
	)


func _marks_show_and_clear() -> String:
	_peer().push_update({"best_move_uci": "e2e4", "eval_cp": 34})
	_router._process(0.016)
	var marks := _marks()
	var eval_label := _eval_label()
	var problem := _first_fail(
		[
			[
				marks.last_from == "e2" and marks.last_to == "e4",
				"R3 marks must show e2-e4 (got %s-%s)" % [marks.last_from, marks.last_to],
			],
			[
				marks.get_child_count() == 3,
				(
					"PER.R5 the arrow is the node's own 3 strokes; the brackets draw on the "
					+ "cream foreground (got %d)" % marks.get_child_count()
				),
			],
			[
				_board().mark_foreground().marks_on("e2").size() == 4,
				"UIS.C6 the Advice from-square carries 4 brackets on its one foreground",
			],
			[
				_board().mark_foreground().marks_on("e4").size() == 4,
				"UIS.C6 the Advice to-square carries 4 brackets on its one foreground",
			],
			[eval_label.visible, "R3 eval must show when values are set"],
			[eval_label.text == "+0.34", "R3 eval text %s" % eval_label.text],
			[
				eval_label.get_theme_font_size("font_size") >= UiChrome.BODY_PX,
				"eval text must be >= UIS.T2",
			],
			[_tel_has("advice.ready"), "advice ready must report telemetry (TEL.4/TEL.5)"],
		]
	)
	if not problem.is_empty():
		return problem
	_peer().push_update({"best_move_uci": "d2d4", "eval_cp": 12})
	_router._process(0.016)
	if eval_label.text != "+0.12":
		return "R3 eval must follow streamed updates"
	return ""


## PER.R5 — marks and arrow cover ≤ 10% of a piece body. FRM.P1 defines the body
## as the opaque body inside the 0.85 × 0.85 SPC.E1 box, not the square and not
## the transparent canvas. PAL.K9 gives Advice the edge-bracket form: one stroke
## per edge midpoint with the corners open, so the mark never reads as a capture
## corner pair. The brackets sit on the square rim, beyond every body half-width,
## so they cover no body; only the arrow can.
func _marks_fit_the_body_bound() -> String:
	## FRM.P1: the widest body is the knight at 0.40 of a square.
	const WIDEST_HALF_WIDTH := 0.20
	## FRM.P1: the body box is 0.85, so the tall King body reaches 0.361.
	const KING_HALF_HEIGHT := 0.85 * 0.85 * 0.5
	## The four edges: each mark is one stroke centred on an edge midpoint.
	var edge := 0.5 - AdviceMarks.ADVICE_STROKE * 0.5
	var coverage := AdviceMarks.body_coverage()
	var form_ok := AdviceMarks.EDGES.size() == 4
	for expected in [Vector2(0.0, -1.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(-1.0, 0.0)]:
		form_ok = form_ok and AdviceMarks.EDGES.has(expected)
	return _first_fail(
		[
			[form_ok, "PAL.K9 advice marks must be one stroke per edge midpoint"],
			[
				edge > WIDEST_HALF_WIDTH,
				"edge brackets must sit beyond the widest body (%.3f)" % edge,
			],
			[
				AdviceMarks.ADVICE_STROKE > 1.5 / 36.0,
				"advice strokes must clear the UIS.I1 1.5 screen px floor",
			],
			[
				AdviceMarks.ARROW_TIP_GAP >= KING_HALF_HEIGHT,
				"the arrowhead must stop short of the to-piece body",
			],
			[
				coverage <= 0.10,
				"PER.R5: marks cover %.1f%% of the King body (bound 10%%)" % [coverage * 100.0],
			],
		]
	)


func _toggle_clears_at_once() -> String:
	_router.handle_control("shared-play", "C3")
	if bool(_router.play_snapshot().get("advice", true)):
		return "C3 must toggle GS.advice off"
	if not _marks().last_from.is_empty():
		return "Advice Off must clear the marks immediately (R9, X2)"
	if _eval_label().visible:
		return "Advice Off must hide the eval"
	_router.handle_control("shared-play", "C3")
	if not bool(_router.play_snapshot().get("advice", false)):
		return "C3 must toggle GS.advice back on"
	return ""


func _marks_clear_on_move() -> String:
	_peer().push_update({"best_move_uci": "g1f3", "eval_cp": 20})
	_router._process(0.016)
	_router.handle_input_commit("e2", "e4")
	if not _marks().last_from.is_empty():
		return "a completed move must clear the marks immediately (R8, X1)"
	_peer().push_update({"best_move_uci": "e7e5", "eval_cp": -10})
	_router._process(0.016)
	if _marks().last_from != "e7":
		return "the new position must mark the side to move (R5, R8)"
	return ""


func _offline_hides_marks() -> String:
	var peer := _peer()
	peer.push_update({"best_move_uci": "b1c3", "eval_cp": 5})
	_router._process(0.016)
	if _marks().last_from != "b1":
		return "marks must show before a failed fetch"
	peer.push_end(AdviceWireReader.REASON_ERROR)
	_router._process(0.016)
	if not _marks().last_from.is_empty():
		return "a failed fetch must clear the marks (X3, FAIL.T1)"
	if not _router.shared_session.advice_error:
		return "a failed fetch must raise EX.error"
	return ""


func _error_s3_dismiss() -> String:
	var play := _play_panel()
	var box := play.find_child("AdviceError", true, false) as Control
	var msg := play.find_child("AdviceErrorMsg", true, false) as Label
	var dismiss := play.find_child("AdviceErrorDismiss", true, false) as Button
	if box == null or msg == null or dismiss == null:
		return "S3 EX.error panel missing"
	# Let the failed fetch park the client before a local move: a probe that
	# moves on the failure tick cannot tell an offline gate from no gate.
	await process_frame
	await process_frame
	var problem := _first_fail(
		[
			[
				_router.play_ui_state == SharedGameSession.UI_S3,
				"EX.error must put play in S3 (got %s)" % _router.play_ui_state,
			],
			[box.visible, "S3 must show the EX.error panel"],
			[
				msg.text == StringTable.shared_play("advice_error", "en"),
				"S3 must name what failed through its Copy key",
			],
			[
				dismiss.text == StringTable.shared_play("dismiss", "en"),
				"S3 Dismiss must use its Copy key",
			],
			[dismiss.custom_minimum_size.x >= UiChrome.MIN_TOUCH, "44px-class targets"],
			[_router.play_gestures_available(), "C1-C5 stay available as S1 in S3"],
			[
				_router.shared_session.advice_client.failed(),
				"the client must be parked before the S3 move is judged",
			],
			[
				_router.shared_session.online == false,
				"the failed fetch keeps the advice service offline (FAIL.T1)",
			],
			[
				_router.shared_session.advice_error,
				"the parked failure stays in EX.error while the board is played",
			],
			[_router.handle_input_commit("d7", "d5"), "a local move must land at once in S3"],
			[
				_router.shared_session.online == false and _router.shared_session.advice_error,
				"the move must not wait on or clear the parked advice failure",
			],
			[
				_router.handle_input_commit("e4", "e5"),
				"both sides keep playing in S3 while the advice service is offline",
			],
		]
	)
	var st := _router._shared_play_state()
	if not problem.is_empty():
		return problem
	dismiss.pressed.emit()
	await process_frame
	## Dismiss returns the session to S1; FAIL.T1 leaves the advice service
	## offline, so no new evaluation follows until the browser reconnects.
	return _first_fail(
		[
			[
				_router.shared_session.play_ui_state == SharedGameSession.UI_S1,
				"Dismiss must return the session to S1",
			],
			[not box.visible, "Dismiss must hide the EX.error panel"],
			[_tel_has("shared.advice.dismiss"), "Dismiss must report telemetry"],
			[_router.shared_session.online == false, "FAIL.T1 keeps the service offline"],
		]
	)


func _leave_clears_marks() -> String:
	# X3 recovery — the browser is back online, so advice streams again. A
	# completed move clears advice and re-evaluates the new position (R8).
	var client := _router.shared_session.advice_client
	if client == null:
		return "advice must stay live for the leave check"
	# X3 — the browser reconnects: reachable again, and the client un-parks.
	client.resume()
	_router.shared_session.online = true
	# Black is to move: the S3 leg plays both sides, so the last move was White's.
	if not _router.handle_input_commit("a7", "a6"):
		return "a completed move must land while advice is live"
	_router._process(0.016)
	_router.shared_session.advice_control("poll")
	var peer := _peer()
	if peer == null:
		return "advice must stay live after a completed move (R8)"
	# White is to move: the peer answers with White's best move (R5).
	peer.push_update({"best_move_uci": "b1c3", "eval_cp": 3})
	_router._process(0.016)
	if _marks().last_from != "b1":
		return "marks before leaving (got '%s')" % _marks().last_from
	_router.handle_control("shared-play", "C4")
	_router.handle_control("shared-play", "confirm")
	return _first_fail([[_marks().last_from.is_empty(), "leaving must clear marks (R9)"]])


func _setup_row_c4() -> String:
	_router.handle_control("shared-result", "C2")
	_router.handle_control("mode-pick", "C1")
	if _router.stage != "shared-setup":
		return "setup after a finished game"
	var setup := _presentation.get_node("ScreenHost/SharedSetup") as SharedSetupPanel
	var row := setup.find_child("Advice", true, false) as Button
	if row == null:
		return "UI-shared-setup.R1 Advice row missing"
	if row.text != _option_line("advice", "advice_on"):
		return "setup Advice row shows %s" % row.text
	var before := _router.advice_on
	_router.handle_control("shared-setup", "C4")
	if _router.advice_on == before or row.text != _option_line("advice", "advice_off"):
		return "setup C4 must toggle On / Off -> GS.advice"
	_router.handle_control("shared-setup", "C4")
	if row.text != _option_line("advice", "advice_on"):
		return "setup C4 must toggle back to On"
	_router.handle_control("shared-setup", "C6")
	return ""


func _copy_is_localized() -> String:
	## Every advice string comes from its Copy key in each shipped locale.
	for key in ["advice_error", "dismiss", "advice_on", "advice_off"]:
		for locale in StringTable.LOCALES:
			if StringTable.shared_play(key, locale).is_empty():
				return "%s missing in %s" % [key, locale]
		if StringTable.shared_play(key, "en").is_empty():
			return "%s missing in en" % key
	if StringTable.shared_setup("advice", "en") != "Advice":
		return "setup advice key"
	return ""


func _option_line(label_key: String, value_key: String) -> String:
	var label_text := StringTable.shared_setup(label_key, "en")
	var value_text := StringTable.shared_setup(value_key, "en")
	return "%s · %s" % [label_text, value_text]


func _tel_has(event_name: String) -> bool:
	for payload in _tel:
		if str((payload as Dictionary).get("TEL.1", "")) == event_name:
			return true
	return false


func _remember_tel(payload: Dictionary) -> void:
	_tel.append(payload)


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""


func _play_panel() -> SharedPlayPanel:
	return _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
