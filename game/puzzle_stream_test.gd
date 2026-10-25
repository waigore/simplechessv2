class_name PuzzleStreamTest
extends SceneTree
## CMP-puzzle-session R1 / CTR-puzzle-catalog-read (#528): the stream's deal source
## reads one record from the catalog service and deals only that record. The peer is
## simulated (FakeCatalogTransport), so nothing here touches a network.


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
		_check_read_deals_the_one_record,
		_check_request_carries_elo_recent_and_key,
		_check_in_flight_read_never_blocks,
		_check_failed_read_deals_nothing,
		_check_bulk_and_malformed_bodies,
		_check_undeliverable_record_deals_nothing,
		_check_leave_retires_the_read,
		_check_missing_peer_fails_without_dealing,
		_check_unconfigured_read_is_not_a_status_failure,
		_check_failure_leaves_the_open_puzzle_untouched,
		_check_one_deal_at_a_time,
		_check_usable,
	]
	for check in checks:
		var problem: String = check.call()
		if not problem.is_empty():
			return "%s: %s" % [check.get_method(), problem]
	return ""


func _session(elo: float = 1000.0) -> PuzzleSession:
	var session := PuzzleSession.new()
	session.player_elo = elo
	return session


func _client(peer: FakeCatalogTransport) -> CatalogDealClient:
	var client := CatalogDealClient.new(func() -> RefCounted: return peer)
	client.configure("http://advice.test/catalog/deal", "test-key")
	return client


func _record(
	id: String = "abc12", rating: int = 1040, moves: Variant = ["e2e4", "e7e5"]
) -> Dictionary:
	## SCH-puzzle-catalog F1–F13 — the one shape CTR-puzzle-catalog-read delivers.
	return {
		"snapshot_id": "2026-10-05",
		"puzzle_id": id,
		"fen": PuzzleSession.START_FEN,
		"moves": moves,
		"rating": rating,
		"rating_deviation": 80,
		"popularity": 90,
		"nb_plays": 1200,
		"themes": ["fork"],
		"game_url": "https://example.test/game",
		"opening_tags": "",
		"daily_date": "",
		"any_checkmate_wins": false,
	}


## Production shape: a session with no record asks, the peer answers one record, and
## the tick deals exactly that record (R1, G1, G2, S3).
func _check_read_deals_the_one_record() -> String:
	var peer := FakeCatalogTransport.new()
	var session := _session(1040.0)
	var stream := PuzzleStream.new(session, _client(peer))
	var dealt: Dictionary = session.deal()
	if bool(dealt.get("ok", true)) or not stream.due or session.puzzle_id != "":
		return "R1: a deal with no record must ask the catalog and deal nothing yet"
	peer.push_record(_record("one", 1040))
	var polled: Dictionary = stream.poll()
	if str(polled.get("event", "")) != "puzzle.dealt" or session.puzzle_id != "one":
		return "R1: the one record the read returned must deal (got %s)" % polled
	if session.puzzle_id != "one" or session.puzzle_elo != 1040:
		return "F2/F5: the dealt puzzle must be the record the server returned"
	if stream.due or not stream.last_failure.is_empty():
		return "a dealt record leaves no owed or failed read"
	if not stream.poll().is_empty():
		return "a finished read must not be applied twice"
	return ""


func _check_request_carries_elo_recent_and_key() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var session := _session(1310.0)
	var recent: Array = []
	for index in range(30):
		recent.append("p%d" % index)
	session.recent_solved = recent
	var stream := PuzzleStream.new(session, _client(peer))
	if not stream.request() or peer.requests.size() != 1:
		return "R1: an available peer must start exactly one read"
	var message: Dictionary = peer.requests[0]
	if float(message.get("player_elo", 0.0)) != 1310.0:
		return "G6: the request must carry GS.playerElo"
	if str(message.get("api_key", "")) != "test-key":
		return "G6: the request must carry the configured key"
	var sent: Array = message.get("recent_solved", [])
	if sent.size() != PuzzleSession.ELO_RECENT_WINDOW:
		return "G6: at most CFG.ELO_RECENT_WINDOW recent ids go on the wire"
	if str(sent[-1]) != "p29":
		return "G6: the newest recent id is the last one sent"
	return ""


## G3 — the read happens off the tick: an unanswered read ends nothing and the call
## returns immediately.
func _check_in_flight_read_never_blocks() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var stream := PuzzleStream.new(_session(), _client(peer))
	stream.request()
	var started := Time.get_ticks_msec()
	var polled: Dictionary = stream.poll()
	if Time.get_ticks_msec() - started > 50:
		return "G3: polling an unanswered read must not block the caller"
	if not polled.is_empty():
		return "U4->U2: an in-flight read applies nothing"
	if not stream.due:
		return "an in-flight read is still owed"
	return ""


func _check_failed_read_deals_nothing() -> String:
	for reason in [
		CatalogWireReader.REASON_ERROR,
		CatalogWireReader.REASON_STATUS,
		CatalogWireReader.REASON_TIMEOUT,
	]:
		var peer := FakeCatalogTransport.new()
		var session := _session(1180.0)
		var stream := PuzzleStream.new(session, _client(peer))
		stream.request()
		peer.push_failure(reason)
		var polled: Dictionary = stream.poll()
		if str(polled.get("event", "")) != "puzzle.read_failed":
			return "X2: %s must surface as a failed read (got %s)" % [reason, polled]
		if str(polled.get("reason", "")) != reason:
			return "X2: the failed read keeps its O2 reason (%s)" % reason
		if session.puzzle_id != "" or session.puzzle_elo != null:
			return "X2: %s must deal nothing" % reason
		if session.player_elo != 1180.0:
			return "X2: %s must leave GS.playerElo unchanged" % reason
		if stream.last_failure != reason:
			return "X2: %s must be observable to the caller" % reason
	return ""


## G1 — a body that is not exactly one SCH-puzzle-catalog record is a failed read,
## whether it is a list, a file, or an empty reply. Validation is the peer's job
## (CatalogWireReader); here the peer is told the read failed with that reason.
func _check_bulk_and_malformed_bodies() -> String:
	for reason in [CatalogWireReader.REASON_BULK, CatalogWireReader.REASON_MALFORMED]:
		var peer := FakeCatalogTransport.new()
		var session := _session()
		var stream := PuzzleStream.new(session, _client(peer))
		stream.request()
		peer.push_failure(reason)
		var polled: Dictionary = stream.poll()
		if str(polled.get("event", "")) != "puzzle.read_failed":
			return "G1: a %s body must be a failed read (got %s)" % [reason, polled]
		if session.puzzle_id != "" or session.has_open_puzzle():
			return "G1: a %s body must deal nothing" % reason
	var empty_peer := FakeCatalogTransport.new()
	var empty_session := _session()
	var empty_stream := PuzzleStream.new(empty_session, _client(empty_peer))
	empty_stream.request()
	# A finished read that produced no message at all is a failed read (X2).
	empty_peer.close()
	var empty: Dictionary = empty_stream.poll()
	if str(empty.get("event", "")) != "puzzle.read_failed" or empty_session.puzzle_id != "":
		return "X2: a reply with no record must deal nothing (got %s)" % empty
	return ""


## X1 — a record with one move cannot be presented, so it deals nothing.
func _check_undeliverable_record_deals_nothing() -> String:
	var peer := FakeCatalogTransport.new()
	var session := _session()
	var stream := PuzzleStream.new(session, _client(peer))
	stream.request()
	peer.push_record(_record("short", 1000, ["e2e4"]))
	var polled: Dictionary = stream.poll()
	if str(polled.get("event", "")) != "puzzle.read_failed":
		return "X1: a one-move record must not deal (got %s)" % polled
	if session.puzzle_id != "":
		return "X1: GS.puzzleId must stay none"
	if stream.last_failure.is_empty():
		return "X1: the undeliverable record must be observable"
	return ""


## S4 — leaving retires the read; the answer that lands later never deals.
func _check_leave_retires_the_read() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var session := _session()
	var stream := PuzzleStream.new(session, _client(peer))
	stream.request()
	stream.leave()
	if stream.due or not peer.closed:
		return "S4: leaving drops the owed deal and retires the read"
	peer.push_record(_record())
	if not stream.poll().is_empty():
		return "S4: a record fetched for a stream the player left never deals"
	if session.puzzle_id != "":
		return "S4: leaving keeps GS.puzzleId none"
	return ""


## B5 / X2 — no peer and an unconfigured `T9` / `T10` are both failed reads: nothing is
## dealt, the open puzzle is untouched, and Elo stays where it was.
func _check_missing_peer_fails_without_dealing() -> String:
	var session := _session(1180.0)
	session.deal([_record("open", 1000)])
	var stream := PuzzleStream.new(session, null)
	if stream.request():
		return "no peer means no read can start"
	if session.puzzle_id != "open" or session.player_elo != 1180.0:
		return "X2: a failed read must not leave a puzzle open or scored"
	if stream.last_failure != CatalogWireReader.REASON_ERROR:
		return "X2: the failure must be observable to the caller"
	return ""


## B5 — an unset `T9` / `T10` is refused before any request is attempted, and it is not
## reported with the same reason a sent-but-unsuccessful read reports.
func _check_unconfigured_read_is_not_a_status_failure() -> String:
	var peer := FakeCatalogTransport.new()
	var session := _session()
	var stream := PuzzleStream.new(session, CatalogDealClient.new())
	if stream.request() or peer.requests.size() != 0:
		return "B5: T9 / T10 unset is a failed read, not a request"
	if stream.last_failure != CatalogWireReader.REASON_UNCONFIGURED:
		return (
			"B5: an unset T9 / T10 must not read as a status failure (got %s)" % stream.last_failure
		)
	if session.player_elo != 1000.0:
		return "B5: a failed read leaves Elo unchanged"
	return ""


## CTR-puzzle-catalog-read Errors — "any failure leaves the prior open puzzle's state
## untouched". A read that fails never reaches the deal, so the attempt the player is on
## keeps its puzzle, its sequence progress, and its Elo.
func _check_failure_leaves_the_open_puzzle_untouched() -> String:
	var peer := FakeCatalogTransport.new()
	var session := _session(1100.0)
	var stream := PuzzleStream.new(session, _client(peer))
	var dealt: Dictionary = session.deal([_record("open", 1100)])
	if not bool(dealt.get("ok", false)):
		return "the fixture must open a puzzle (got %s)" % dealt
	var before := session.play_state()
	stream.request()
	peer.push_failure(CatalogWireReader.REASON_TIMEOUT)
	var polled: Dictionary = stream.poll()
	if str(polled.get("event", "")) != "puzzle.read_failed":
		return "X2: a failed read must surface as one failed read (got %s)" % polled
	var after := session.play_state()
	if session.puzzle_id != "open" or after != before:
		return "X2: a failed read must leave the open puzzle's state untouched"
	return ""


func _check_one_deal_at_a_time() -> String:
	var peer := FakeCatalogTransport.new()
	peer.blocking = true
	var stream := PuzzleStream.new(_session(), _client(peer))
	if not stream.request() or stream.request():
		return "O5: at most one read at a time"
	if peer.requests.size() != 1:
		return "O5: a second request must not reach the peer"
	return ""


func _check_usable() -> String:
	if not PuzzleStream.usable(_record()):
		return "I2: two moves are dealable"
	if PuzzleStream.usable(_record("x", 1000, ["e2e4"])):
		return "X1: one move is not dealable"
	if not PuzzleStream.usable(_record("y", 1000, "e2e4 e7e5")):
		return "I2: CSV-style moves are dealable"
	return ""
