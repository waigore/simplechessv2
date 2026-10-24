class_name AdviceClientTest
extends SceneTree
## CMP-advice-client (#374): F-move-advice R1–R9 / X1–X4, CMP-advice-client
## R1–R7, and the ADR-0002 validation rows that belong to the client. The
## backend is a simulated peer speaking CTR-advice-stream (ADR-0002 Testability);
## no Stockfish endpoint exists here.


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := await _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_fen_orthodox,
		_check_fen_rights_and_ep,
		_check_squares_for_uci,
		_check_time_ms_reads_init,
		_check_unavailable_without_endpoint,
		_check_on_and_online_starts_stream,
		_check_updates_apply_fields,
		_check_updates_only_for_side_to_move,
		_check_move_clears_then_reevaluates,
		_check_advice_off_clears_and_stops,
		_check_offline_clears,
		_check_game_end_clears,
		_check_leave_clears_and_puzzle_never_runs,
		_check_error_clears_and_play_continues,
		_check_one_failure_reports_once,
		_check_cleared_reports_story,
		_check_stale_updates_after_cancel_dropped,
		_check_local_move_never_waits,
		_check_wire_reads_updates_and_cap,
		_check_wire_handles_partial_and_junk,
		_check_wire_close_without_end_is_error,
		_check_wire_timeout_and_errors,
		_check_terminal_status_is_a_real_close,
		_check_transport_reachable_stream,
		_check_transport_streams_updates_progressively,
		_check_transport_cancel_is_prompt,
	]
	for check in checks:
		var problem: String = await check.call()
		if not problem.is_empty():
			# Reported here so the failing check is visible in the log.
			printerr("FAIL %s: %s" % [check.get_method(), problem])
			return problem
	return ""


## Advice On and online in a Shared game, with a scripted peer.
func _shared(script: Array = []) -> Dictionary:
	FakeAdviceTransport.all_streams.clear()
	FakeAdviceTransport.all_requests.clear()
	FakeAdviceTransport.all_cancels = 0
	var fake := FakeAdviceTransport.new(script)
	# One peer per stream, like the real transport; `fake` is the first one.
	var make_stream := func() -> RefCounted: return FakeAdviceTransport.new(script)
	var client := AdviceClient.new(make_stream)
	if not FakeAdviceTransport.all_streams.has(fake):
		FakeAdviceTransport.all_streams.append(fake)
	client.configure("http://advice.test/advice", "test-key", 2000)
	var session := SharedGameSession.new()
	session.advice_client = client
	session.start_shared(SharedGameSession.CLOCK_UNTIMED, 0, true)
	return {"session": session, "fake": fake, "client": client}


## The simulated peer behind the stream the session has in flight right now.
func _stream(session: SharedGameSession) -> FakeAdviceTransport:
	var transport: Variant = session.advice_client._transport
	return transport as FakeAdviceTransport


func _check_fen_orthodox() -> String:
	var rules := ChessRules.new()
	rules.reset_opening()
	var fen := AdviceClient.fen_for(rules.position_field(), rules.castling_ep())
	var want := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
	if fen != want:
		return "orthodox FEN is %s" % fen
	return ""


func _check_fen_rights_and_ep() -> String:
	var position := {
		"occupancy":
		{
			"e1": {"color": "white", "kind": "king"},
			"e8": {"color": "black", "kind": "king"},
		},
		"side_to_move": "black",
	}
	var fen := AdviceClient.fen_for(position, {"black_kingside": true, "en_passant": "e3"})
	if fen != "4k3/8/8/8/8/8/8/4K3 b k e3 0 1":
		return "rights/EP FEN is %s" % fen
	return ""


func _check_squares_for_uci() -> String:
	var squares := AdviceClient.squares_for_uci("e2e4")
	if str(squares.get("from", "")) != "e2" or str(squares.get("to", "")) != "e4":
		return "e2e4 must map to e2/e4"
	if not AdviceClient.squares_for_uci("z9x1").is_empty():
		return "invalid UCI must map to no squares"
	var promo := AdviceClient.squares_for_uci("e7e8q")
	if str(promo.get("from", "")) != "e7" or str(promo.get("to", "")) != "e8":
		return "F1/F2 read the first four chars of best_move_uci"
	return ""


func _check_time_ms_reads_init() -> String:
	var client := AdviceClient.new()
	client.configure("http://advice.test/advice", "k", -1)
	if client.request_time_ms() != 2000:
		return "missing T6 must send 2000"
	client.configure("http://advice.test/advice", "k", 3500)
	if client.request_time_ms() != 3500:
		return "T6 must be sent as time_ms"
	client.configure("http://advice.test/advice", "k", 9000)
	if client.request_time_ms() != 2000:
		return "out-of-range T6 must fall back to 2000"
	return ""


func _check_unavailable_without_endpoint() -> String:
	var client := AdviceClient.new()
	var session := SharedGameSession.new()
	session.advice_client = client
	session.start_shared(SharedGameSession.CLOCK_UNTIMED, 0, true)
	if session.advice_control("poll").get("events", []).size() != 0:
		return "no request without T9/T10"
	var c3 := session.handle_play_control("C3")
	if not bool(c3.get("ok", false)):
		return "C3 still toggles advice state"
	return ""


func _check_on_and_online_starts_stream() -> String:
	var fake := FakeAdviceTransport.new([])
	var client := AdviceClient.new(func() -> RefCounted: return fake)
	client.configure("http://advice.test/advice", "key-123", 2000)
	var session := SharedGameSession.new()
	session.advice_client = client
	session.start_shared(SharedGameSession.CLOCK_UNTIMED, 0, true)
	if FakeAdviceTransport.all_requests.size() != 1:
		return "O1 must start automatically with no ask action"
	var request: Dictionary = FakeAdviceTransport.all_requests[0]
	if str(request.get("api_key", "")) != "key-123":
		return "O1 must carry the configured API key (G4)"
	if int(request.get("time_ms", 0)) != 2000:
		return "O1 must carry T6 as time_ms"
	if not fake.endpoint.begins_with("http://advice.test"):
		return "O1 must go to the configured endpoint"
	if not str(request.get("fen", "")).ends_with(" w KQkq - 0 1"):
		return "O1 must carry the current position"
	return ""


func _check_updates_apply_fields() -> String:
	var shared := _shared([{"best_move_uci": "e2e4", "eval_cp": 34}])
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	var live := _stream(session)
	live.push_update({"best_move_uci": "e2e4", "eval_cp": 34})
	var events: Array = session.advice_control("poll").get("events", [])
	var state := session.play_state()
	var move: Dictionary = state["advice_best_move"]
	if str(move.get("from", "")) != "e2" or str(move.get("to", "")) != "e4":
		return "E1 must land in GS.adviceBestMove"
	if int(state["advice_eval"]) != 34:
		return "E1 must land in GS.adviceEval"
	if events.size() != 1 or str(events[0].get("story", "")) != "F-move-advice.R4":
		return "advice ready must be reported for TEL.4"
	return ""


func _check_updates_only_for_side_to_move() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	var state := session.play_state()
	var applied := session.advice_client.apply_update(
		state, {"best_move_uci": "e7e5", "eval_cp": -1}
	)
	if applied.is_empty():
		return "side-to-move update must apply"
	session.place("e2", "e4")
	var after := session.play_state()
	if after["advice_best_move"] != null or after["advice_eval"] != null:
		return "a black best move must not survive White's move (R5/R8)"
	if str(after["position"]["side_to_move"]) != "black":
		return "turn must change to black"
	_stream(session).push_update({"best_move_uci": "e7e5", "eval_cp": -20})
	session.advice_control("poll")
	var next: Variant = session.play_state()["advice_best_move"]
	if not (next is Dictionary) or str((next as Dictionary).get("from", "")) != "e7":
		return "advice must follow the side to move after the move"
	return ""


func _check_move_clears_then_reevaluates() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	_stream(session).push_update({"best_move_uci": "e2e4", "eval_cp": 30})
	session.advice_control("poll")
	var requests_before := FakeAdviceTransport.all_requests.size()
	session.place("g1", "f3")
	var state := session.play_state()
	if state["advice_best_move"] != null:
		return "a completed move must clear advice immediately (R8)"
	if FakeAdviceTransport.all_requests.size() != requests_before + 1:
		return "the new position must be evaluated when R2 still holds (R8)"
	return ""


func _check_advice_off_clears_and_stops() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	_stream(session).push_update({"best_move_uci": "e2e4", "eval_cp": 30})
	session.advice_control("poll")
	var cancels := FakeAdviceTransport.all_cancels
	session.handle_play_control("C3")
	var state := session.play_state()
	if bool(state["advice"]):
		return "C3 must toggle GS.advice off"
	if state["advice_best_move"] != null:
		return "Advice Off must clear advice (R9, X2)"
	if FakeAdviceTransport.all_cancels <= cancels:
		return "Advice Off must stop evaluation (O2)"
	var requests := FakeAdviceTransport.all_requests.size()
	session.advice_control("poll")
	if FakeAdviceTransport.all_requests.size() != requests:
		return "Advice Off must not start a new stream"
	return ""


func _check_offline_clears() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	var live := _stream(session)
	live.push_update({"best_move_uci": "d2d4", "eval_cp": 12})
	session.advice_control("poll")
	if session.play_state()["advice_eval"] != 12:
		return "the update must show an eval before the failure"
	live.push_end(AdviceWireReader.REASON_ERROR)
	var events: Array = session.advice_control("poll").get("events", [])
	var state := session.play_state()
	if bool(state["online"]):
		return "a backend failure must clear GS.online (X3)"
	# R9 / X3 clear both fields: a failed search leaves no mark and no number.
	if state["advice_best_move"] != null or state["advice_eval"] != null:
		return "going offline must clear advice, both marks (R9, X3)"
	if not _has_outcome(events, "advice.error", "unavailable"):
		return "FAIL.T1 must be reported for EX.error and telemetry"
	if not session.gestures_available():
		return "play must continue after an advice failure (FAIL.T1)"
	# FAIL.T1 "Stop eval": the failed stream is over, so nothing more is delivered.
	for tick in range(5):
		var later: Array = session.advice_control("poll").get("events", [])
		if not later.is_empty():
			return "a failed stream must stop, no further delivery (FAIL.T1): %s" % [later]
	if session.play_state()["advice_best_move"] != null or session.play_state()["advice_eval"] != null:
		return "nothing may be delivered after the failure (FAIL.T1)"
	return ""


func _check_game_end_clears() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	_stream(session).push_update({"best_move_uci": "e2e4", "eval_cp": 5})
	session.advice_control("poll")
	session.resign()
	var state := session.play_state()
	if state["advice_best_move"] != null or state["advice_eval"] != null:
		return "game end must clear advice (R8, X4)"
	# The end reports the clear it caused, and the poll after it reports nothing new.
	var cleared: Array = session.advice_control("poll").get("events", [])
	if not _has_outcome(cleared, "advice.cleared", "cleared"):
		return "game end must report advice.cleared for TEL.4, got %s" % [cleared]
	if cleared.size() != 1:
		return "game end must not start or report a new stream, got %s" % [cleared]
	return ""


func _check_leave_clears_and_puzzle_never_runs() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	_stream(session).push_update({"best_move_uci": "e2e4", "eval_cp": 5})
	session.advice_control("poll")
	session.advice_control("leave")
	if session.play_state()["advice_best_move"] != null:
		return "leaving the Shared game must clear advice (R9)"
	var requests := FakeAdviceTransport.all_requests.size()
	session.in_shared_game = false
	session.advice_control("poll")
	if FakeAdviceTransport.all_requests.size() != requests:
		return "Advice must never run outside a Shared game (R1, CFG.K3)"
	return ""


func _check_error_clears_and_play_continues() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var fake: FakeAdviceTransport = shared["fake"]
	_stream(session).push_end(AdviceWireReader.REASON_TIMEOUT)
	var events: Array = session.advice_control("poll").get("events", [])
	if events.is_empty():
		return "a stream timeout must be reported (FAIL.T1)"
	if session.play_state()["advice_best_move"] != null:
		return "a timeout must leave no advice showing"
	if not session.place("e2", "e4").get("ok", false):
		return "a local move must still apply while advice is unavailable"
	return ""


## #534 — one failed stream reports one failure: the parked client keeps
## `failed()` true, so stays in `shared-play` must not re-append `advice.error`.
func _check_one_failure_reports_once() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	_stream(session).push_end(AdviceWireReader.REASON_ERROR)
	var first: Array = session.advice_control("poll").get("events", [])
	if first.is_empty():
		return "a failed stream must be reported (FAIL.T1)"
	for tick in range(5):
		var again: Array = session.advice_control("poll").get("events", [])
		if not again.is_empty():
			return "a parked failure was reported again on tick %d: %s" % [tick, again]
	if not session.advice_error:
		return "the first failure must raise EX.error"
	return ""


## AC 15 / TEL.4 / TEL.5 — the clear path reports `advice.cleared` with the story
## that required it, on every rule that closes evaluation (R8, R9/X2, X3).
func _check_cleared_reports_story() -> String:
	var cases := [
		["move", "F-move-advice.R8"],
		["game_end", "F-move-advice.R8"],
		["advice_off", "F-move-advice.R9"],
		["leave", "F-move-advice.R9"],
		["offline", "F-move-advice.R9"],
		["loss", "F-move-advice.X3"],
	]
	for entry in cases:
		var case_id := str(entry[0])
		var story := str(entry[1])
		var shared := _shared()
		var session: SharedGameSession = shared["session"]
		var live := _stream(session)
		live.push_update({"best_move_uci": "e2e4", "eval_cp": 21})
		session.advice_control("poll")
		var cleared := ""
		match case_id:
			"move":
				session.place("g1", "f3")
				cleared = _cleared_in(session.advice_control("poll").get("events", []))
			"game_end":
				session.resign()
				cleared = _cleared_in(session.advice_control("poll").get("events", []))
			"advice_off":
				session.handle_play_control("C3")
				cleared = _cleared_in(session.advice_control("poll").get("events", []))
			"leave":
				cleared = _cleared_in(session.advice_control("leave").get("events", []))
			"offline":
				cleared = _cleared_in(session.advice_control("offline").get("events", []))
			"loss":
				# FAIL.T1 supersedes a tick's ready; the clear is still reported.
				_stream(session).push_update({"best_move_uci": "d2d4", "eval_cp": 12})
				session.advice_control("poll")
				_stream(session).push_end(AdviceWireReader.REASON_ERROR)
				cleared = _cleared_in(session.advice_control("poll").get("events", []))
		if cleared != story:
			return "%s must report advice.cleared for %s, got %s" % [case_id, story, cleared]
		if session.play_state()["advice_best_move"] != null:
			return "%s must clear the advice fields" % case_id
	# A rule firing with nothing showing is not an outcome, so it reports nothing.
	var idle := _shared()
	var session: SharedGameSession = idle["session"]
	var events: Array = session.advice_control("leave").get("events", [])
	if not events.is_empty():
		return "clearing with nothing showing must report no cleared event, got %s" % events
	return ""


## True when `events` carries `name` with `outcome` — an error now rides with a clear.
func _has_outcome(events: Array, name: String, outcome: String) -> bool:
	for event in events:
		var row: Dictionary = event as Dictionary
		if str(row.get("event", "")) == name and str(row.get("outcome", "")) == outcome:
			return true
	return false


## The story of the first `advice.cleared` in `events`, or "" when absent.
func _cleared_in(events: Array) -> String:
	for event in events:
		if str((event as Dictionary).get("event", "")) == "advice.cleared":
			return str((event as Dictionary).get("story", ""))
	return ""


func _check_stale_updates_after_cancel_dropped() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var cancelled := _stream(session)
	cancelled.push_update({"best_move_uci": "e2e4", "eval_cp": 50})
	session.advice_control("poll")
	session.place("g1", "f3")
	if FakeAdviceTransport.all_cancels == 0:
		return "the move must issue O2 on the stream in flight"
	# The cancelled peer keeps delivering (contract Errors: drop), and so does the
	# live one with a legitimate new-position update.
	cancelled.push_update({"best_move_uci": "a2a4", "eval_cp": 900})
	_stream(session).push_update({"best_move_uci": "e7e5", "eval_cp": -10})
	session.advice_control("poll")
	var shown: Variant = session.play_state()["advice_best_move"]
	if not (shown is Dictionary):
		return "the live stream's update must still apply after a cancel"
	if str((shown as Dictionary).get("from", "")) == "a2":
		return "an update from a cancelled stream must be dropped (I3)"
	return ""


## R6 / I1 / CTR-advice-stream.G1 — the move completes on-device while a stream
## is in flight; it neither awaits the peer nor blocks on a cancel.
func _check_local_move_never_waits() -> String:
	var shared := _shared()
	var session: SharedGameSession = shared["session"]
	var peer := _stream(session)
	peer.blocking = true
	var restarted := peer.requests.size()
	var started := Time.get_ticks_msec()
	session.place("e2", "e4")
	# The move opened a stream for the new position without waiting for any answer.
	if FakeAdviceTransport.all_requests.size() != restarted + 1:
		return "the move must reissue O1 at once while the old stream is silent"
	var took := Time.get_ticks_msec() - started
	if took > 1000:
		return "a local move waited %d ms on advice" % took
	if str(session.play_state()["position"]["side_to_move"]) != "black":
		return "the turn must change without waiting on advice (R6, I1)"
	return ""


func _check_wire_reads_updates_and_cap() -> String:
	var reader := AdviceWireReader.new()
	var updates := []
	reader.feed(('{"best_move_uci":"e2e4","eval_cp":31}\n').to_utf8_buffer(), updates)
	if updates.size() != 1:
		return "one E1 line must become one update"
	var update: Dictionary = updates[0]
	if str(update.get("best_move_uci", "")) != "e2e4" or int(update.get("eval_cp", 0)) != 31:
		return "E1 fields must survive the wire unchanged"
	if not reader.feed(('{"reason":"cap"}\n').to_utf8_buffer(), updates):
		return "E2 must end the reader"
	if not reader.capped() or reader.ended != AdviceWireReader.REASON_CAP:
		return "E2 cap must be reported as the cap"
	return ""


## A line split across chunks is one message; junk and unknown keys are ignored.
func _check_wire_handles_partial_and_junk() -> String:
	var reader := AdviceWireReader.new()
	var updates := []
	reader.feed(("not json\n\n").to_utf8_buffer(), updates)
	reader.feed(('{"depth":4}\n').to_utf8_buffer(), updates)
	reader.feed(('{"best_move_uci":"d2d4",').to_utf8_buffer(), updates)
	reader.feed(('"eval_cp":9}\n').to_utf8_buffer(), updates)
	if updates.size() != 1:
		return "only a complete E1 line with a best move becomes an update"
	if str((updates[0] as Dictionary).get("best_move_uci", "")) != "d2d4":
		return "a line split across chunks must still be read whole"
	return ""


## A closed stream that never sent E2 is an advice failure (FAIL.T1).
func _check_wire_close_without_end_is_error() -> String:
	var reader := AdviceWireReader.new()
	var updates := []
	reader.closed(updates)
	if reader.ended != AdviceWireReader.REASON_ERROR:
		return "a close without E2 must end with error"
	var buffered := AdviceWireReader.new()
	var late := []
	buffered.feed(('{"best_move_uci":"a2a4","eval_cp":3}').to_utf8_buffer(), late)
	buffered.closed(late)
	if late.size() != 1:
		return "a final line without its newline must still be read on close"
	return ""


## Client-side deadline (a backend that never ends) is reported as a timeout.
func _check_wire_timeout_and_errors() -> String:
	var reader := AdviceWireReader.new()
	var updates := []
	if not reader.step(OK, false, true):
		return "the deadline must stop the reader"
	if reader.ended != AdviceWireReader.REASON_TIMEOUT:
		return "a deadline must end with timeout"
	var broken := AdviceWireReader.new()
	if not broken.step(ERR_CANT_CONNECT, false, false):
		return "a poll error must stop the reader"
	if broken.ended != AdviceWireReader.REASON_ERROR:
		return "a poll error must end with error"
	var cancelled := AdviceWireReader.new()
	cancelled.cancelled()
	if not cancelled.is_open() and cancelled.ended == AdviceWireReader.REASON_ERROR:
		return "O2 is not a backend failure"
	return ""


## The request is in flight on the first poll, so only a real close ends it
## (#534): `STATUS_REQUESTING` must never be read as `STATUS_DISCONNECTED`.
func _check_terminal_status_is_a_real_close() -> String:
	for status in [
		HTTPClient.STATUS_REQUESTING,
		HTTPClient.STATUS_CONNECTED,
		HTTPClient.STATUS_RESOLVING,
		HTTPClient.STATUS_BODY,
	]:
		if AdviceWireReader.is_terminal_status(status):
			return "status %d is in flight, not a close" % status
	for status in [
		HTTPClient.STATUS_DISCONNECTED,
		HTTPClient.STATUS_CANT_CONNECT,
		HTTPClient.STATUS_CANT_RESOLVE,
		HTTPClient.STATUS_CONNECTION_ERROR,
		HTTPClient.STATUS_TLS_HANDSHAKE_ERROR,
	]:
		if not AdviceWireReader.is_terminal_status(status):
			return "status %d ends the exchange and must be terminal" % status
	return ""


## A reachable peer streams E1 then E2 cap: the transport must deliver at least
## one update and end on the cap, never close because the request is in flight.
## The peer is an outside process (``ADVICE_STREAM_PEER``, e.g. loopback:port):
## an in-process TCPServer cannot see an HTTPClient connection in the same tree.
func _check_transport_reachable_stream() -> String:
	var peer := OS.get_environment("ADVICE_STREAM_PEER").strip_edges()
	if peer.is_empty():
		print("skip reachable-stream peer: ADVICE_STREAM_PEER unset")
		return ""
	var transport := AdviceStreamTransport.new()
	transport.start("http://%s/advice" % peer, _message(), 4000)
	var updates: Array = []
	var ended := ""
	var deadline := Time.get_ticks_msec() + 4000
	while Time.get_ticks_msec() < deadline:
		await create_timer(0.02).timeout
		for message in transport.poll():
			var kind := str((message as Dictionary).get("kind", ""))
			if kind == "update":
				updates.append((message as Dictionary)["value"])
			elif kind == "end":
				ended = str((message as Dictionary)["value"].get("reason", ""))
		if not ended.is_empty():
			break
	transport.close()
	if ended != AdviceWireReader.REASON_CAP:
		return "a reachable stream must end on the cap, saw '%s' (#534)" % ended
	if updates.is_empty():
		return "a reachable stream must deliver its E1 update (#534)"
	if str((updates[0] as Dictionary).get("best_move_uci", "")) != "e2e4":
		return "the E1 update must survive the wire"
	return ""


## E1 is a stream tick (CTR-advice-stream E1; concurrency.md U3 → U2): updates
## must reach the caller while the peer is still streaming, not all at once when
## the stream ends. The peer (``ADVICE_STREAM_PEER``) keeps sending deepening
## updates until its cap; the first update must arrive well before the end.
func _check_transport_streams_updates_progressively() -> String:
	var peer := OS.get_environment("ADVICE_STREAM_PEER").strip_edges()
	if peer.is_empty():
		print("skip progressive-stream peer: ADVICE_STREAM_PEER unset")
		return ""
	var transport := AdviceStreamTransport.new()
	var started := Time.get_ticks_msec()
	transport.start("http://%s/advice" % peer, _message(), 2000)
	var first_update_at := -1
	var ended := ""
	var deadline := started + 4000
	while Time.get_ticks_msec() < deadline:
		await create_timer(0.01).timeout
		for message in transport.poll():
			var kind := str((message as Dictionary).get("kind", ""))
			if kind == "update" and first_update_at < 0:
				first_update_at = Time.get_ticks_msec() - started
			elif kind == "end":
				ended = str((message as Dictionary)["value"].get("reason", ""))
		if not ended.is_empty():
			break
	var ended_at := Time.get_ticks_msec() - started
	transport.close()
	if first_update_at < 0:
		return "a stream must deliver its first E1 before it ends"
	if ended_at - first_update_at < 200:
		return (
			"E1 must arrive while the stream is live, not in one batch at the end "
			+ "(first=%d ended=%d)" % [first_update_at, ended_at]
		)
	return ""


## An unreachable endpoint fails the stream as an advice error, not a hang.
func _check_transport_unreachable_is_error() -> String:
	var transport := AdviceStreamTransport.new()
	transport.start(_endpoint(), _message(), 2000)
	var ended := ""
	var deadline := Time.get_ticks_msec() + 3000
	while Time.get_ticks_msec() < deadline:
		await create_timer(0.02).timeout
		await process_frame
		var messages := _of_kind(transport.poll(), "end")
		if not messages.is_empty():
			ended = str((messages[0] as Dictionary)["value"].get("reason", ""))
			break
	transport.close()
	if ended != AdviceWireReader.REASON_ERROR:
		return "an unreachable endpoint must end with error, saw '%s'" % ended
	if not transport.is_finished():
		return "a failed stream must finish"
	return ""


## O2 releases the client at once, whatever the worker is doing.
func _check_transport_cancel_is_prompt() -> String:
	var transport := AdviceStreamTransport.new()
	transport.start(_endpoint(), _message(), 2000)
	transport.cancel()
	transport.close()
	if not transport.is_finished():
		return "O2 must stop the stream without waiting for the cap"
	# A transport that never started must answer a close harmlessly.
	var idle := AdviceStreamTransport.new()
	idle.close()
	if not idle.is_finished() or not idle.poll().is_empty():
		return "closing an idle transport must be harmless"
	return ""


## O1 wire message for a position with nothing on it.
func _message() -> Dictionary:
	return {"api_key": "k", "fen": "8/8/8/8/8/8/8/8 w - - 0 1", "time_ms": 2000}


## Port 1 of loopback refuses every connection: a backend that is simply down.
func _endpoint() -> String:
	return "http://127.0.0.1:1/advice"


func _of_kind(messages: Array, kind: String) -> Array:
	var picked := []
	for message in messages:
		if str((message as Dictionary).get("kind", "")) == kind:
			picked.append(message)
	return picked
