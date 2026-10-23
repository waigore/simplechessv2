extends SceneTree
## Cross-check for #550 — the same C2 entry with a simulated catalog peer and the
## T9/T10 pair set, proving the probe's `fail` rows are the shipped-path absence
## (`#648` / `#479`), not a driver mistake. Not the evidence verdict; this run is
## the seam build that #648 describes as the only one that can deal today.

var _p: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_p = packed.instantiate() as Presentation
	var harness := _p.get_node("PlaytestHarness")
	_p.remove_child(harness)
	harness.free()
	_router = _p.get_node("SessionRouter") as SessionRouter
	_seams = _p.get_node("PlaytestSeams") as PlaytestSeams
	_router.locale = "en"
	_router.last_mode = "none"
	# The two values B5 requires; the shipped path never sets them (#648).
	_router.advice_endpoint = "http://catalog.test/deal"
	_router.advice_api_key = "probe-key"
	var persist := _p.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_p)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_p.set_deferred("size", Vector2(720, 1280))
	await process_frame
	await process_frame
	_router.handle_control("mode-pick", "C2")
	print("X550 after-enter in_flight=%s" % _router.puzzle_flow.client.in_flight())
	# Drop one catalog record onto the peer the seam factory builds next.
	var peer := FakeCatalogTransport.new()
	peer.push_record(_record())
	_router.puzzle_flow.client.cancel()
	_router.puzzle_flow.stream.due = false
	FakeCatalogTransport.all_requests.clear()
	_router.puzzle_flow.client.sim_factory = func() -> Variant: return peer
	_router.puzzle_flow.stream.request()
	for _i in 6:
		await process_frame
	var flow := _router.puzzle_flow
	print("X550 flow=%s stream=%s client=%s in_flight=%s due=%s peer_requests=%d" % [
		flow != null,
		flow.stream != null if flow != null else false,
		flow.client != null if flow != null else false,
		flow.client.in_flight() if flow != null and flow.client != null else false,
		flow.stream.due if flow != null and flow.stream != null else false,
		FakeCatalogTransport.all_requests.size(),
	])
	var dealt := false
	var session: PuzzleSession = null
	if flow != null and flow.session != null:
		session = flow.session
		dealt = not session.puzzle_id.is_empty()
	print("X550 seams=%s dealt=%s pid=%s elo=%s last_failure=%s" % [
		_seams.playtest_build,
		dealt,
		session.puzzle_id if session != null else "none",
		session.puzzle_elo if session != null else -1,
		flow.stream.last_failure if flow != null and flow.stream != null else "n/a",
	])
	if dealt:
		var before := session.player_elo
		print("X550 seq=%s side=%s" % [[session.required_sequence], session.solving_side])
		for step in session.required_sequence.duplicate():
			var from_sq := str(step["from"])
			var to_sq := str(step["to"])
			var sel := flow.gesture(from_sq, "")
			var placed := flow.gesture(from_sq, to_sq, str(step.get("promotion", "")))
			print("X550 step %s%s sel=%s placed=%s idx=%d outcome=%s wrong=%s" % [
				from_sq, to_sq, sel, placed, session.sequence_index, session.outcome, session.wrong_move_on_puzzle
			])
			if not placed:
				break
		print("X550 solve outcome=%s elo %.2f -> %.2f ok=%s" % [
			session.outcome, before, session.player_elo, session.outcome == "win"
		])
		# A second record so the post-solve deal has something to open.
		var next_peer := FakeCatalogTransport.new()
		next_peer.push_record(_record())
		flow.client.sim_factory = func() -> Variant: return next_peer
		flow.stream.request()
		for _i in 4:
			await process_frame
		print("X550 next pid=%s elo=%s" % [session.puzzle_id, session.puzzle_elo])
	print("X550 RESULT deal=%s solve=%s" % [dealt, session.outcome == "win" if session != null else false])
	print("X550_PROBE %s" % ("pass" if dealt else "fail"))
	quit(0 if dealt else 1)


## One `SCH-puzzle-catalog` record in the snapshot format (SCH-puzzle-catalog F1–F13).
func _record() -> Dictionary:
	return {
		"snapshot_id": "2026-10-05",
		"puzzle_id": "probe550a",
		"fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
		"moves": ["e2e4", "e7e5"],
		"rating": 1040,
		"themes": ["fork"],
		"any_checkmate_wins": false,
	}
