class_name CatalogDealClientTest
extends SceneTree
## CMP-puzzle-session C5 / CTR-puzzle-catalog-read (#528): the client deal read
## sends Elo, recent ids, and the API key, and reports either one record or a
## failed read. The peer is simulated, so nothing here touches a network.


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := _run_all()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_unavailable_without_endpoint_or_key,
		_check_request_carries_elo_recent_and_key,
		_check_recent_window_is_trimmed,
		_check_one_deal_at_a_time,
		_check_one_record_outcome,
		_check_failed_read_outcome,
		_check_cancel_drops_the_answer,
		_check_in_flight_read_never_blocks_the_caller,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	if _failure_reasons().size() != 5:
		return "every O2 failure shape must be exercised"
	return ""


func _client(peer: FakeCatalogTransport, recent: Array = ["p1", "p2"]) -> Dictionary:
	FakeCatalogTransport.all_requests.clear()
	var client := CatalogDealClient.new(func() -> RefCounted: return peer)
	client.configure("http://advice.test/catalog/deal", "test-key")
	return {"client": client, "peer": peer, "recent": recent}


func _record() -> Dictionary:
	return {
		"snapshot_id": "2026-10-05",
		"puzzle_id": "abc12",
		"fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
		"moves": ["e2e4", "e7e5"],
		"rating": 1040,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": ["fork"],
		"game_url": "https://example.test/game",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


func _check_unavailable_without_endpoint_or_key() -> String:
	var peer := FakeCatalogTransport.new()
	var client := CatalogDealClient.new(func() -> RefCounted: return peer)
	client.configure("", "test-key")
	if client.is_available() or client.request(1000.0, []):
		return "B5: no endpoint means no deal read"
	client.configure("http://advice.test/catalog/deal", "")
	if client.is_available() or client.request(1000.0, []):
		return "B5: no key means no deal read"
	if not peer.requests.is_empty():
		return "an unavailable client must not reach the peer"
	return ""


func _check_request_carries_elo_recent_and_key() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	if not client.request(1042.5, ["p1", "p2"]):
		return "an available client must start the read"
	var sent: Dictionary = peer.requests[0]
	if not is_equal_approx(float(sent.get("player_elo", 0.0)), 1042.5):
		return "O1 must carry GS.playerElo"
	if str(sent.get("api_key", "")) != "test-key":
		return "O1 must carry the configured key (G4)"
	if sent.get("recent_solved", []) != ["p1", "p2"]:
		return "O1 must carry recent solved ids (got %s)" % sent.get("recent_solved")
	return ""


func _check_recent_window_is_trimmed() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	var ids: Array = []
	for index in range(PuzzleSession.ELO_RECENT_WINDOW + 5):
		ids.append("p%d" % index)
	client.request(1000.0, ids)
	var sent: Array = peer.requests[0].get("recent_solved", [])
	if sent.size() != PuzzleSession.ELO_RECENT_WINDOW:
		return "G6: at most CFG.ELO_RECENT_WINDOW ids (got %d)" % sent.size()
	if str(sent[-1]) != "p24":
		return "G6: the newest ids are the ones sent"
	return ""


func _check_one_deal_at_a_time() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	peer.blocking = true
	if client.in_flight():
		return "a fresh client has no read in flight"
	client.request(1000.0, [])
	if client.request(1000.0, []):
		return "G6: a second deal must wait for the one in flight"
	return ""


func _check_one_record_outcome() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	client.request(1000.0, [])
	if not client.poll().is_empty():
		return "poll must not report before the peer answers"
	peer.push_record(_record())
	var outcome := client.poll()
	if not bool(outcome.get("ok", false)):
		return "a one-record answer must read (got %s)" % outcome
	if str(outcome.get("record", {}).get("puzzle_id", "")) != "abc12":
		return "the outcome must carry the one record"
	if client.in_flight():
		return "a finished read must release the client"
	return ""


func _check_failed_read_outcome() -> String:
	for reason in _failure_reasons():
		var parts := _client(FakeCatalogTransport.new())
		var client: CatalogDealClient = parts["client"]
		var peer: FakeCatalogTransport = parts["peer"]
		client.request(1000.0, [])
		peer.push_failure(reason)
		var outcome := client.poll()
		if bool(outcome.get("ok", true)) or str(outcome.get("reason", "")) != reason:
			return "a failed read must report its reason, not %s" % outcome
	return ""


## Every failed read CTR-puzzle-catalog-read O2 covers.
func _failure_reasons() -> Array:
	return [
		CatalogWireReader.REASON_ERROR,
		CatalogWireReader.REASON_TIMEOUT,
		CatalogWireReader.REASON_STATUS,
		CatalogWireReader.REASON_BULK,
		CatalogWireReader.REASON_MALFORMED,
	]


func _check_cancel_drops_the_answer() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	client.request(1000.0, [])
	client.cancel()
	if not peer.closed or client.in_flight():
		return "cancel must retire the in-flight read"
	peer.push_record(_record())
	if not client.poll().is_empty():
		return "an answer after cancel must never deal"
	return ""


## CTR-puzzle-catalog-read G3 / concurrency S3 — a read in flight never blocks the
## caller; the caller runs on between `request()` and the answer arriving.
func _check_in_flight_read_never_blocks_the_caller() -> String:
	var parts := _client(FakeCatalogTransport.new())
	var client: CatalogDealClient = parts["client"]
	var peer: FakeCatalogTransport = parts["peer"]
	peer.blocking = true
	if not client.request(1000.0, []):
		return "an available client must start the read"
	if not client.in_flight():
		return "the read must be in flight while the peer has not answered"
	if not client.poll().is_empty():
		return "G3: an unanswered read must report nothing yet, never wait"
	# The caller keeps working while the answer is outstanding.
	var session := PuzzleSession.new()
	session.player_elo = 1000.0
	if str(session.play_ui_state).is_empty():
		return "G3: the session must stay usable while a deal is in flight"
	peer.blocking = false
	peer.push_record(_record())
	var outcome := client.poll()
	if not bool(outcome.get("ok", false)):
		return "G3: the answer must arrive on a later poll (got %s)" % outcome
	return ""
