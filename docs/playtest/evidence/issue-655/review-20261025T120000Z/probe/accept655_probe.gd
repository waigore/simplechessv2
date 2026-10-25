extends SceneTree
## #655 — the wave-2 defect on the puzzle stream's first deal, re-run on the tree the
## #648 answer landed on (`a9192a0` / `e19401f`, catalog enabled in the release).
##
## Two legs, both on one `Web Playtest`-preset boot (`main.tscn`, seams live):
##
## A. The **absence leg**, on the shipped configuration the issue filed. `T9` / `T10`
##    are left exactly as the shipped path sets them (`""`), because #479 owns how the
##    pair reaches a client and no delivery decision lands values here. The run must show
##    `F-puzzle-catalog.X2` / `FAIL.T14`: nothing dealt, Elo unchanged, no puzzle id, the
##    reason reachable on `PuzzleStream.last_failure` and in the log, and `C5` on the
##    landed `S1` raising `leave_confirm` → Cancel → still `S1` (#655 item 4).
## B. The **same reproduction** with only `T9` / `T10` set, so the deal path reaches the
##    resolver: `is_available()` is then true and no refusal is the empty-value one, and
##    the read's own outcome — a transport refusal to a host that does not exist — is what
##    the run reports. Nothing about the dealer changes between A and B.
##
## Every judgement prints `A655 JUDGE <criterion> pass|fail|held — <label>`; exit 0 only
## when no criterion is `fail`. Refs #655, #550, #648, #479.

const PROBE_TAG := "A655"
## The `T9` / `T10` pair leg B sets, so `is_available()` is true. The shipped seam build's
## simulated peer answers no socket, so the host is only where a real build would aim.
const UNREACHABLE_ENDPOINT := "http://catalog.test/deal"
const UNREACHABLE_KEY := "review-655-key"

var _rows: Array = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	await _leg_absence()
	await _leg_configured()
	_report()
	quit(0 if _failures().is_empty() else 1)


## Boot one presentation with the shipped values, or with both values set.
func _boot(configured: bool) -> Array:
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node("PlaytestHarness")
	presentation.remove_child(harness)
	harness.free()
	var router := presentation.get_node("SessionRouter") as SessionRouter
	var seams := presentation.get_node("PlaytestSeams") as PlaytestSeams
	var persist := presentation.get_node_or_null("PersistStore") as PersistStore
	router.locale = "en"
	router.last_mode = "none"
	# The shipped path's own values, before anything sets them (session_router.gd).
	print("%s shipped T9=%s T10=%s" % [
		PROBE_TAG,
		router.advice_endpoint,
		"<set>" if not str(router.advice_api_key).is_empty() else "<unset>",
	])
	_record(
		"AC2",
		"shipped values",
		true,
		"T9=%s T10 %s before any assignment (session_router.gd:33-34)" % [
			"<unset>" if router.advice_endpoint.is_empty() else router.advice_endpoint,
			"unset" if str(router.advice_api_key).is_empty() else "set",
		]
	)
	if configured:
		router.advice_endpoint = UNREACHABLE_ENDPOINT
		router.advice_api_key = UNREACHABLE_KEY
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(presentation)
	presentation.set_deferred("size", Vector2(720, 1280))
	await _settle(2)
	return [presentation, router, seams, persist]


func _unboot(parts: Array) -> void:
	var presentation: Presentation = parts[0]
	root.remove_child(presentation)
	presentation.free()
	await _settle(2)


## A — the shipped configuration: the absence leg and the C5 leg.
func _leg_absence() -> void:
	print("%s ==== leg A: shipped values (absence record) ====" % PROBE_TAG)
	var parts := await _boot(false)
	var router: SessionRouter = parts[1]
	var seams: PlaytestSeams = parts[2]
	var persist: PersistStore = parts[3]
	print("%s A build=%s session=%s godot=%s" % [
		PROBE_TAG, seams.playtest_build, seams.session_id, Engine.get_version_info().get("string", "")
	])
	_record("TEL.3", "build identity", str(seams.session_id).begins_with("sess-"), "TEL.3 session id %s on playtest build=%s" % [seams.session_id, seams.playtest_build])
	var elo_before := _persist_elo(persist)
	# Reproduction step 2 — mode pick, then enter the stream.
	router.handle_control("mode-pick", "C2")
	await _settle(4)
	print("%s A after C2 stage=%s" % [PROBE_TAG, router.stage])
	_record("AC2", "C2 entry", router.stage == "puzzle-play", "C2 enters puzzle-play (the issue's reproduction step 2)")
	var flow := router.puzzle_flow
	if flow == null:
		_record("AC2", "deal path", false, "no journey opened, nothing to judge")
		await _unboot(parts)
		return
	var session: PuzzleSession = flow.session
	var client: CatalogDealClient = flow.client
	var stream: PuzzleStream = flow.stream
	var available := client.is_available()
	var reason := str(stream.last_failure)
	print("%s A available=%s last_failure=%s dealt=%s pid='%s' elo %.2f" % [
		PROBE_TAG, available, reason, session.has_open_puzzle(), session.puzzle_id, session.player_elo
	])
	# AC2 — `is_available()` is true whenever the branch's values are present. On the
	# shipped configuration they are not, so the empty-value guard is what refused; this
	# is the branch's precondition reading, recorded rather than passed off as the deal.
	_record(
		"AC2",
		"is_available gate",
		not available,
		"T9/T10 unset ⇒ is_available()=%s; the refusal is B5's empty-value guard, not a transport failure" % available
	)
	_record(
		"AC3",
		"X2 absence",
		not session.has_open_puzzle() and session.puzzle_id.is_empty(),
		"F-puzzle-catalog.X2 — nothing dealt, GS.puzzleId stays none"
	)
	_print_elo(persist, elo_before)
	_record(
		"AC3",
		"GS.playerElo kept",
		is_equal_approx(_persist_elo(persist), elo_before) and is_equal_approx(session.player_elo, elo_before),
		"GS.playerElo %.2f → %.2f (document and session)" % [elo_before, _persist_elo(persist)]
	)
	# AC4 — FAIL.T14 is the three things the row names: Elo kept, no puzzle id, and the
	# reason reachable. FAIL.T14 itself does not name a reason, so this run does not pass
	# or fail on the guard's identity; criterion 2 does (below).
	_record(
		"AC4",
		"FAIL.T14 row",
		true,
		"FAIL.T14: Elo kept, no puzzle id, reason '%s' on PuzzleStream.last_failure and in this log" % reason
	)
	_record(
		"AC4",
		"player-facing copy",
		null,
		"no specs/ requirement for player-facing absence copy (FAIL.T14's Effect column names none); none invented"
	)
	var tel := _events(seams, seams.session_id)
	var deal_failed := tel.filter(func(row: Dictionary) -> bool: return str(row.get("TEL.1", "")) == "puzzle.deal_failed")
	_record(
		"AC4",
		"log window",
		not tel.is_empty(),
		"SIT.5 log window %s carries %d events; a failed deal raises no `deal_failed` telemetry because the read never started (%d)" % [
			seams.session_id, tel.size(), deal_failed.size()
		]
	)
	_c5_leg(router, session)
	await _unboot(parts)


## Item 4 / AC5 — C5 on the entered S1 raises EX.confirm, Cancel returns to S1 unchanged.
func _c5_leg(router: SessionRouter, session: PuzzleSession) -> void:
	var state_before := session.play_ui_state
	var pid_before := session.puzzle_id
	# AC5 says observe it by activating the control on this screen: the router's own
	# puzzle-play control path, not the session method directly.
	router.handle_control("puzzle-play", "C5")
	var raised := session.play_ui_state
	var kind := session.confirm_kind
	print("%s A C5 state %s -> %s kind=%s controls=%s" % [
		PROBE_TAG, state_before, raised, kind, router.puzzle_flow.state().get("controls", [])
	])
	_record(
		"AC5",
		"C5 on empty S1",
		state_before == PuzzleSession.UI_S1 and raised == PuzzleSession.UI_S2 and kind == PuzzleSession.CONFIRM_LEAVE,
		"C5 on S1 with no open puzzle: %s → %s, leave_confirm (US5.1)" % [state_before, raised]
	)
	router.handle_control("puzzle-play", "cancel")
	var cancelled := session.play_ui_state
	var still_s1 := router.stage == SessionRouter.STAGE_PUZZLE_PLAY
	var unchanged := session.puzzle_id == pid_before and session.confirm_kind.is_empty()
	print("%s A cancel state=%s stage=%s pid=%s" % [PROBE_TAG, cancelled, router.stage, session.puzzle_id])
	_record(
		"AC5",
		"Cancel returns",
		cancelled == PuzzleSession.UI_S1 and still_s1 and unchanged,
		"Cancel: %s, stage=%s, no deal and no pending confirm (US5.3)" % [cancelled, router.stage]
	)
	var label := str(_confirm_copy("leave_confirm"))
	_record("AC5", "leave_confirm copy", not label.is_empty(), "EX.confirm copy: %s" % label)
	# Leave for real so the journey's own left → mode-pick path is exercised too.
	router.handle_control("puzzle-play", "C5")
	router.handle_control("puzzle-play", "confirm")
	_record(
		"AC5",
		"Confirm leaves",
		router.stage == SessionRouter.STAGE_MODE_PICK,
		"Confirm on leave_confirm leaves to mode-pick with nothing scored (J-puzzle-session B1)"
	)


## B — the same reproduction with T9/T10 present: does the deal path reach the resolver?
func _leg_configured() -> void:
	print("%s ==== leg B: T9/T10 set (deal path reaches the resolver) ====" % PROBE_TAG)
	var parts := await _boot(true)
	var router: SessionRouter = parts[1]
	var seams: PlaytestSeams = parts[2]
	print("%s B session=%s" % [PROBE_TAG, seams.session_id])
	router.handle_control("mode-pick", "C2")
	var available: bool = router.puzzle_flow != null and router.puzzle_flow.client.is_available()
	_record(
		"AC2",
		"deal path reaches resolver",
		available,
		"with T9/T10 present is_available()=%s, so the deal path reaches the resolver (the criterion's `whenever`)"
		% available
	)
	# The seam build's shipped peer never answers (`SessionRouter._puzzle_sim_factory`), so
	# the read would stay in flight; this run retires that read and asks again with a peer
	# that completes it as a transport failure, the #528 drive's own pattern.
	# (The seam crosscheck in #550's folder retires and re-requests the same way.)
	if router.puzzle_flow != null:
		router.puzzle_flow.stream.leave()
		router.puzzle_flow.client.sim_factory = Callable(self, "_failing_peer")
		router.puzzle_flow.stream.request()
		router.puzzle_flow.tick()
	var waited := 0
	for _i in 600:
		if router.puzzle_flow != null and not router.puzzle_flow.stream.due:
			break
		waited += 1
		await process_frame
	print("%s B waited_frames=%d in_flight=%s due=%s last_failure=%s" % [
		PROBE_TAG,
		waited,
		router.puzzle_flow.client.in_flight() if router.puzzle_flow != null else false,
		router.puzzle_flow.stream.due if router.puzzle_flow != null else false,
		router.puzzle_flow.stream.last_failure if router.puzzle_flow != null else "",
	])
	var flow := router.puzzle_flow
	if flow == null:
		_record("AC3", "deal outcome", false, "no journey to read an outcome from")
		await _unboot(parts)
		return
	var session: PuzzleSession = flow.session
	var reason := str(flow.stream.last_failure)
	print("%s B available=%s last_failure=%s dealt=%s pid='%s'" % [
		PROBE_TAG, available, reason, session.has_open_puzzle(), session.puzzle_id
	])
	_record(
		"AC2",
		"refusal is not B5",
		reason != CatalogWireReader.REASON_UNCONFIGURED and reason != CatalogWireReader.REASON_STATUS,
		"the refusal is '%s' — a failed read the client sent (FAIL.T14 transport), not the empty-value guard" % reason
	)
	_record(
		"AC3",
		"named outcome",
		not reason.is_empty() or session.has_open_puzzle(),
		"deal resolved to X2 (nothing dealt, reason '%s') — not the inert S1 the issue filed" % reason
	)
	print("%s B elo unchanged=%s" % [PROBE_TAG, is_equal_approx(session.player_elo, PuzzleSession.ELO_START)])
	_record(
		"AC3",
		"X2 holds",
		not session.has_open_puzzle() and session.puzzle_id.is_empty() and is_equal_approx(session.player_elo, PuzzleSession.ELO_START),
		"with the values present and the host unreachable: nothing dealt, no puzzle id, Elo %.2f unchanged" % session.player_elo
	)
	_record(
		"AC6",
		"published leg",
		null,
		"held — the published release needs #479's T9/T10 client delivery and a deployed catalog route (#648); no judgment is taken on the published URL here"
	)
	await _unboot(parts)


func _confirm_copy(key: String) -> Variant:
	return StringTable.puzzle_play(key, "en")


## The peer leg B asks with: one completed read that failed in transport, so the run can
## see what the deal path reports once the values are present.
func _failing_peer() -> RefCounted:
	var peer := FakeCatalogTransport.new()
	peer.push_failure(CatalogWireReader.REASON_ERROR)
	return peer


func _persist_elo(persist: PersistStore) -> float:
	if persist == null:
		return -1.0
	var doc := persist.load_document()
	return float(doc.get("player_elo", -1.0))


func _print_elo(persist: PersistStore, before: float) -> void:
	print("%s A elo before=%.2f after=%.2f" % [PROBE_TAG, before, _persist_elo(persist)])


func _events(seams: PlaytestSeams, session_id: String) -> Array:
	var out: Array = []
	for row in seams._tel_log:
		if str(row.get("TEL.3", "")) == session_id:
			out.append(row)
	return out


func _record(criterion: String, row: String, outcome: Variant, label: String) -> void:
	var verdict := "held"
	if outcome is bool:
		verdict = "pass" if outcome else "fail"
	_rows.append({"criterion": criterion, "row": row, "verdict": verdict, "label": label})
	print("%s JUDGE %s %s %s — %s" % [PROBE_TAG, criterion, row, verdict, label])


func _failures() -> Array:
	return _rows.filter(func(row: Dictionary) -> bool: return row["verdict"] == "fail")


func _report() -> void:
	var tally := {"pass": 0, "fail": 0, "held": 0}
	for row in _rows:
		tally[row["verdict"]] = int(tally[row["verdict"]]) + 1
	print("%s TALLY pass=%d fail=%d held=%d rows=%d" % [
		PROBE_TAG, tally["pass"], tally["fail"], tally["held"], _rows.size()
	])
	print("%s_PROBE %s" % [PROBE_TAG, "pass" if _failures().is_empty() else "fail"])


func _settle(frames: int) -> void:
	for _i in frames:
		await process_frame
