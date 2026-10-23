extends SceneTree
## Acceptance probe for #374 — PTD-move-advice on the default branch (e022f83).
##
## Part 1 drives the shipped (production) path: no playtest seams, so the router
## builds the real `AdviceStreamTransport` and talks to a simulated
## CTR-advice-stream peer over HTTP.
## Part 2 drives the playtest build's own simulated peer (`FakeAdviceTransport`,
## ADR-0002 Testability) to judge the session lifecycle (S2–S5).
## Independent of game/advice_client_test.gd; no unit-test assertion is reused.

var _fails: Array[String] = []
var _tel: Array = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var peer := OS.get_environment("ACCEPT_PEER")
	var peer_log := OS.get_environment("ACCEPT_LOG")
	var key := OS.get_environment("ACCEPT_KEY")

	print("ACCEPT --- S1 production path (no playtest seams, real transport)")
	var prod := await _make_presentation(false)
	var prod_router := prod["router"] as SessionRouter
	_start_game(prod_router, peer, key, -1)
	var started := Time.get_ticks_msec()
	await _pump_until(
		func() -> bool: return _state(prod_router).get("advice_best_move") != null, 3000)
	var prod_state := _state(prod_router)
	print("ACCEPT prod waited_ms=", Time.get_ticks_msec() - started, " stage=", prod_router.stage,
		" best=", str(prod_state.get("advice_best_move")), " eval=", str(prod_state.get("advice_eval")),
		" online=", prod_state.get("online"), " advice=", prod_state.get("advice"))
	var requests := _requests(peer_log)
	_check(requests.size() >= 1, "production O1 reached the configured endpoint (R6)")
	if requests.size() > 0:
		var req: Dictionary = requests[0].get("request", {})
		print("ACCEPT prod o1=", JSON.stringify(req))
		_check(str(req.get("api_key", "")) == key, "production O1 carried the configured API key")
		_check(str(req.get("fen", "")).contains(" w "), "production O1 carried the current position")
		_check(int(float(req.get("time_ms", 0))) == 2000, "T6 missing: production O1 carried 2000")
	var prod_best: Variant = prod_state.get("advice_best_move")
	_check(prod_best is Dictionary and str((prod_best as Dictionary).get("to", "")) == "e4",
		"S1: the streamed best move reached GS.adviceBestMove (R3/R4)")
	_check(prod_state.get("advice_eval") != null, "S1: the streamed eval reached GS.adviceEval (R4)")
	_check(bool(prod_state.get("online", false)), "S1: GS.online stayed true against a reachable peer (X3)")
	if prod_best == null:
		_fails.append("S1 FAIL: a reachable peer produced no advice on the production path")
	await _destroy(prod)

	print("ACCEPT --- S2–S5 playtest build simulated peer (FakeAdviceTransport)")
	var play := await _make_presentation(true)
	var router := play["router"] as SessionRouter
	_tel.clear()
	var mark := _tel.size()
	_start_game(router, peer, key, 1200)
	await process_frame
	var first_peer: Variant = _last_fake()
	_check(first_peer != null, "the playtest build opened a simulated stream")
	if first_peer != null:
		var o1: Array = (first_peer as FakeAdviceTransport).requests
		if o1.size() > 0:
			print("ACCEPT play o1=", JSON.stringify(o1[0]))
			_check(str((o1[0] as Dictionary).get("api_key", "")) == key, "playtest O1 used the configured key")
			_check(int(float((o1[0] as Dictionary).get("time_ms", 0))) == 1200,
				"T6 in range is sent as O1 time_ms (R7)")
		_check(str((first_peer as FakeAdviceTransport).endpoint).is_empty() == false,
			"the simulated stream aimed at the configured endpoint")
		(first_peer as FakeAdviceTransport).push_update({"best_move_uci": "e2e4", "eval_cp": 35})
		await process_frame
		await process_frame
	var shown := _state(router)
	print("ACCEPT play shown best=", str(shown.get("advice_best_move")), " eval=", str(shown.get("advice_eval")))
	_check(shown.get("advice_best_move") != null and int(shown.get("advice_eval", 0)) == 35,
		"a simulated E1 lands in GS.adviceBestMove / GS.adviceEval (R4)")
	_check(_has_tel_since(mark, "advice.ready"), "advice ready telemetry emitted (TEL.4/TEL.5)")

	var move_started := Time.get_ticks_usec()
	var moved := router.handle_input_commit("e2", "e4")
	var move_ms := float(Time.get_ticks_usec() - move_started) / 1000.0
	print("ACCEPT play move=", moved, " move_ms=", move_ms, " side=", router.shared_session.side_to_move(),
		" best_after=", str(_state(router).get("advice_best_move")))
	_check(moved, "local move applied while a stream was in flight (R6)")
	_check(move_ms < 50.0, "move did not await advice (G1/I1)")
	_check(_state(router).get("advice_best_move") == null, "move cleared advice immediately (R8)")
	var second_peer: Variant = _last_fake()
	_check(second_peer != null and second_peer != first_peer, "a new stream started for the new position")
	if second_peer != null and second_peer != first_peer:
		var req2: Array = (second_peer as FakeAdviceTransport).requests
		_check(str((req2[0] as Dictionary).get("fen", "")).contains(" b "),
			"the new O1 asks for the Black-to-move position (R5)")
		(second_peer as FakeAdviceTransport).push_update({"best_move_uci": "e7e5", "eval_cp": -20})
		await process_frame
		await process_frame
		var re := _state(router)
		print("ACCEPT play re-eval best=", str(re.get("advice_best_move")), " eval=", str(re.get("advice_eval")))
		_check(re.get("advice_best_move") != null, "evaluation of the new position restarted (R8)")
		if first_peer != null:
			(first_peer as FakeAdviceTransport).push_update({"best_move_uci": "a2a4", "eval_cp": 999})
			await process_frame
			await process_frame
			var after_stale := _state(router)
			print("ACCEPT play stale after cancel best=", str(after_stale.get("advice_best_move")),
				" eval=", str(after_stale.get("advice_eval")))
			_check(int(after_stale.get("advice_eval", 0)) != 999,
				"a stale update from the cancelled stream is dropped (I3)")

	router.handle_control("shared-play", "C3")
	await process_frame
	print("ACCEPT play advice_off advice=", _state(router).get("advice"),
		" best=", str(_state(router).get("advice_best_move")))
	_check(_state(router).get("advice") == false, "C3 turned Advice Off")
	_check(_state(router).get("advice_best_move") == null, "Advice Off cleared advice (R9/X2)")
	var off_requests := FakeAdviceTransport.all_requests.size()
	await _pump_ms(200)
	_check(FakeAdviceTransport.all_requests.size() == off_requests, "Advice Off stopped evaluation (R9)")

	router.handle_control("shared-play", "C3")
	await process_frame
	var third_peer: Variant = _last_fake()
	var restarted := third_peer != null and FakeAdviceTransport.all_requests.size() > off_requests
	print("ACCEPT play advice_on restarted=", restarted)
	_check(restarted, "Advice On again restarted evaluation (R3/R9)")
	if third_peer != null:
		(third_peer as FakeAdviceTransport).push_update({"best_move_uci": "e2e4", "eval_cp": 20})
		await process_frame
		await process_frame
	print("ACCEPT play end_best=", str(_state(router).get("advice_best_move")))
	_check(_state(router).get("advice_best_move") != null, "advice shown again before game end")
	router.handle_control("shared-play", "C4")
	router.handle_control("shared-play", "confirm")
	print("ACCEPT play end stage=", router.stage, " best=", str(_state(router).get("advice_best_move")))
	_check(router.stage == "shared-result", "resign reached shared-result")
	_check(_state(router).get("advice_best_move") == null, "game end cleared advice (R8/X4)")
	var ended_requests := FakeAdviceTransport.all_requests.size()
	router.handle_control("shared-result", "C2")
	await _pump_ms(200)
	print("ACCEPT play leave stage=", router.stage, " requests=", ended_requests,
		"->", FakeAdviceTransport.all_requests.size())
	_check(router.stage == "mode-pick", "leaving the Shared game reached mode-pick")
	_check(FakeAdviceTransport.all_requests.size() == ended_requests, "leaving the Shared game stopped evaluation (R9)")

	print("ACCEPT --- R1 gate")
	var puzzle := PuzzleSession.new()
	var puzzle_state: Dictionary = puzzle.play_state()
	print("ACCEPT r1 puzzle_advice=", str(puzzle_state.get("advice", "<missing>")))
	_check(str(puzzle_state.get("advice", "")) == "none", "Puzzle stream play state carries no advice (R1)")
	var session := SharedGameSession.new()
	var fake := AdviceClient.new(Callable(FakeAdviceTransport, "new"))
	fake.configure(peer, key, -1)
	session.advice_client = fake
	var fake_before := FakeAdviceTransport.all_requests.size()
	session.in_shared_game = false
	session._sync_advice()
	_check(FakeAdviceTransport.all_requests.size() == fake_before, "no O1 outside a Shared game (R1)")
	session.in_shared_game = true
	session.advice_on = false
	session._sync_advice()
	_check(FakeAdviceTransport.all_requests.size() == fake_before, "no O1 with Advice Off (R2)")
	session.advice_on = true
	session.online = false
	session._sync_advice()
	_check(FakeAdviceTransport.all_requests.size() == fake_before, "no O1 while offline (R2)")

	print("ACCEPT --- telemetry")
	var advice_events: Array = []
	var missing_fields := 0
	for payload in _tel:
		var p: Dictionary = payload
		var name := str(p.get("TEL.1", ""))
		if not name.begins_with("advice."):
			continue
		advice_events.append(p)
		if str(p.get("TEL.4", "")).is_empty() or str(p.get("TEL.5", "")).is_empty():
			missing_fields += 1
	print("ACCEPT tel advice_events=", advice_events.size(), " missing_fields=", missing_fields)
	for payload in advice_events:
		print("ACCEPT tel_sample=", JSON.stringify(payload))
	_check(advice_events.size() > 0, "advice telemetry was emitted")
	_check(missing_fields == 0, "emitted advice events carry TEL.4 and TEL.5")
	await _destroy(play)

	if _fails.is_empty():
		print("ACCEPT PROBE PASS")
		quit(0)
	else:
		for failure in _fails:
			print("ACCEPT PROBE FAIL: ", failure)
		print("ACCEPT PROBE FAILED count=", _fails.size())
		quit(1)


func _make_presentation(with_seams: bool) -> Dictionary:
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node_or_null("PlaytestHarness")
	if harness != null:
		presentation.remove_child(harness)
		harness.free()
	if not with_seams:
		var seams := presentation.get_node_or_null("PlaytestSeams")
		if seams != null:
			presentation.remove_child(seams)
			seams.free()
	var router := presentation.get_node("SessionRouter") as SessionRouter
	var persist := presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(presentation)
	await process_frame
	await process_frame
	if with_seams:
		var seams_node: Variant = presentation.get_node_or_null("PlaytestSeams")
		if seams_node != null:
			seams_node.tel_event.connect(_on_tel)
			print("ACCEPT session=", str(seams_node.session_id))
	return {"presentation": presentation, "router": router}


func _destroy(entry: Dictionary) -> void:
	var presentation := entry.get("presentation") as Presentation
	if presentation != null and is_instance_valid(presentation):
		root.remove_child(presentation)
		presentation.free()
	await process_frame


func _last_fake() -> Variant:
	if FakeAdviceTransport.all_streams.is_empty():
		return null
	return FakeAdviceTransport.all_streams[FakeAdviceTransport.all_streams.size() - 1]


func _on_tel(payload: Dictionary) -> void:
	_tel.append(payload)


func _has_tel_since(mark: int, event_name: String) -> bool:
	for index in range(mark, _tel.size()):
		if str((_tel[index] as Dictionary).get("TEL.1", "")) == event_name:
			return true
	return false


func _start_game(router: SessionRouter, endpoint: String, key: String, t6: int) -> void:
	router.advice_endpoint = endpoint
	router.advice_api_key = key
	router.advice_time_ms = t6
	router.handle_control("mode-pick", "C1")
	router.handle_control("shared-setup", "C5")


func _state(router: SessionRouter) -> Dictionary:
	if router == null or router.shared_session == null:
		return {}
	return router.shared_session.play_state()


func _check(ok: bool, message: String) -> void:
	print("ACCEPT ", "PASS " if ok else "FAIL ", message)
	if not ok:
		_fails.append(message)


func _pump_ms(ms: int) -> void:
	var deadline := Time.get_ticks_msec() + ms
	while Time.get_ticks_msec() < deadline:
		await process_frame


func _pump_until(predicate: Callable, timeout_ms: int) -> void:
	var deadline := Time.get_ticks_msec() + timeout_ms
	while Time.get_ticks_msec() < deadline:
		if bool(predicate.call()):
			return
		await process_frame


func _requests(path: String) -> Array:
	var out: Array = []
	if path.is_empty() or not FileAccess.file_exists(path):
		return out
	for line in FileAccess.get_file_as_string(path).split("\n", false):
		var parsed: Variant = JSON.parse_string(line)
		if parsed is Dictionary:
			out.append(parsed)
	return out
