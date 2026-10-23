class_name AdviceReadinessTest
extends SceneTree
## #559 — the advice-readiness half of the Load time row
## (specs/definition/quality.md): "advice ready within 2000 ms when On and
## online, and never delays a local move".
##
## This is a headless integration run on `main` against the simulated peer
## (ADR-0002 Testability), never a Stockfish endpoint and never a playtest.
## It claims no `SIT.4` / `S11` seam: verification.md S11 captures frame times
## and `EX.loading` start-to-ready, and `I6` binds those reports to the UX
## protocols; no advice-latency step exists there.
##
## What makes the timing meaningful. `FakeAdviceTransport` delivers its script
## inside `start`, so timing it would read ~0 ms and always pass.
## `DeferredAdviceTransport` holds the E1 until the next `poll()`, so
## `elapsed_ms()` measures a real deferred delivery, and a client that awaited
## the stream inside `start` would not return. The never-delay check uses a
## peer that never answers (`blocking`), so a move that joined the stream would
## exceed this test's own ceiling.

## `CFG.ADVICE_TIME_MS` (specs/technical/configuration.md T6) in range, and not
## the default: the readiness check proves the configured cap is the one used.
const T6_MS := 1500
## T6 default when missing or out of range (B3, R7).
const T6_DEFAULT_MS := 2000
## One sample is not evidence (specs/playtest/evidence-manifest.md).
const REPEATS := 5
## The deferred E1 lands this far after O1: small, but a real wait.
const READINESS_DEFER_MS := 4
## A delivery inside `start` would read 0 ms, so the deferral must show up.
const READINESS_MIN_MS := 1
## A real deferred delivery is nowhere near the cap; sitting at the cap would
## mean the timer, not the peer, produced the number.
const READINESS_CEILING_MS := 250
## A move that awaited the silent stream would take T6 (or hang); a real local
## move takes a few ticks.
const MOVE_CEILING_MS := 40
## How long the silent peer stays silent after the moves.
const SILENT_HOLD_MS := 250
## Five legal local moves, so every repeat crosses a turn boundary.
const MOVES := [["e2", "e4"], ["e7", "e5"], ["g1", "f3"], ["b8", "c6"], ["f1", "c4"]]


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem: String = await _run_all()
	if not problem.is_empty():
		push_error(problem)
		quit(1)
		return
	print("advice readiness: %d repeats, T6 %d ms, all within the cap" % [REPEATS, T6_MS])
	quit(0)


func _run_all() -> String:
	var checks: Array[Callable] = [
		_check_time_ms_follows_t6,
		_check_readiness_within_configured_t6,
		_check_local_move_never_waits_on_silent_peer,
	]
	for check in checks:
		var problem: String = await check.call()
		if not problem.is_empty():
			# Reported here so the failing check is visible in the log.
			printerr("FAIL %s: %s" % [check.get_method(), problem])
			return problem
	return ""


## A client whose simulated peer defers its E1 to the next `poll()`.
func _deferred_client(t6: int, script: Array) -> AdviceClient:
	var client := AdviceClient.new()
	client.sim_factory = func() -> RefCounted: return DeferredAdviceTransport.new(script)
	client.configure("http://advice.test/advice", "test-key", t6)
	return client


## A client on the immediate scripted peer, for the O1 `time_ms` agreement.
func _scripted_client(t6: int) -> AdviceClient:
	FakeAdviceTransport.all_streams.clear()
	FakeAdviceTransport.all_requests.clear()
	var client := AdviceClient.new()
	client.sim_factory = func() -> RefCounted: return FakeAdviceTransport.new([])
	client.configure("http://advice.test/advice", "test-key", t6)
	return client


## An unstarted-role state the client can write advice onto.
func _state() -> Dictionary:
	return {"advice_best_move": null, "advice_eval": null}


## Wait for the clock to tick, so the window opens on a fresh millisecond and a
## rounded boundary cannot swallow the measured wait.
func _await_new_tick() -> void:
	var now := Time.get_ticks_msec()
	while Time.get_ticks_msec() == now:
		OS.delay_usec(100)


## `time_ms` of the one O1 a fresh client sent for `t6`, or -1 when the request
## count is not exactly one.
func _sent_time_ms(t6: int) -> int:
	var client := _scripted_client(t6)
	if not client.start({}) or FakeAdviceTransport.all_requests.size() != 1:
		return -1
	return int((FakeAdviceTransport.all_requests[0] as Dictionary).get("time_ms", 0))


## `""` when every T6 in range is sent as O1 `time_ms`, else the first failure.
func _t6_in_range_problem() -> String:
	for t6 in [500, 1200, T6_MS, 2000, 5000]:
		var sent := _sent_time_ms(t6)
		if sent != t6:
			return "T6 %d must be sent as O1 time_ms (R7), sent %d" % [t6, sent]
	return ""


## `""` when every missing or out-of-range T6 sends the default, else the first
## failure.
func _t6_default_problem() -> String:
	for t6 in [-1, 0, 499, 5001, 9999]:
		var sent := _sent_time_ms(t6)
		if sent != T6_DEFAULT_MS:
			return (
				"T6 %d must fall back to %d on the wire (B3), sent %d" % [t6, T6_DEFAULT_MS, sent]
			)
	return ""


## R7 / B3 — the O1 `time_ms` is T6 in range and the 2000 default when T6 is
## missing or out of range, read off the recorded request rather than the
## client's own answer, so the measurement and the cap cannot drift apart.
func _check_time_ms_follows_t6() -> String:
	var problem := _t6_in_range_problem()
	if problem.is_empty():
		problem = _t6_default_problem()
	return problem


## `""` when `start` returned before the client had read anything, so the
## deferred timing below is a delivery the client had to poll for.
func _start_returned_early(peer: DeferredAdviceTransport, state: Dictionary) -> String:
	if peer.polls != 0 or peer.delivered != 0 or state["advice_best_move"] != null:
		return "start must return before any update exists (anti-tautology)"
	return ""


## `""` when the first `poll()` after `start` delivered and applied the E1.
func _first_poll_landed(
	client: AdviceClient, peer: DeferredAdviceTransport, state: Dictionary
) -> String:
	var result: Dictionary = client.poll(state)
	if peer.polls != 1 or peer.delivered != 1 or result.is_empty():
		return "the E1 must arrive and apply on the first poll"
	var move: Variant = state["advice_best_move"]
	if not (move is Dictionary) or str((move as Dictionary).get("to", "")) != "e4":
		return "the released update must land in GS.adviceBestMove"
	# A later poll changes nothing: the advice stays on until O2 or a move.
	if not client.poll(state).is_empty() or state["advice_best_move"] == null:
		return "a second poll must leave the ready advice on"
	return ""


## AC1 — one deferred-delivery sample: `start` returns before the client has
## read anything, the E1 lands on the next `poll()`, and readiness is the
## client-reported `elapsed_ms()` at that moment against the configured `T6`.
## Returns `{"problem", "elapsed"}`, with `elapsed` -1 when the sample failed.
func _readiness_sample() -> Dictionary:
	var client := _deferred_client(T6_MS, [{"best_move_uci": "e2e4", "eval_cp": 21}])
	var state := _state()
	if not client.start({}):
		return {"problem": "advice On and online must start a stream (R2)", "elapsed": -1}
	var peer := client._transport as DeferredAdviceTransport
	var sent := int((peer.requests[0] as Dictionary).get("time_ms", 0))
	if sent != T6_MS:
		return {"problem": "O1 must carry T6 %d, sent %d" % [T6_MS, sent], "elapsed": -1}
	var early := _start_returned_early(peer, state)
	if not early.is_empty():
		return {"problem": early, "elapsed": -1}
	await _await_new_tick()
	await create_timer(float(READINESS_DEFER_MS) / 1000.0).timeout
	var elapsed := client.elapsed_ms()
	var landed := _first_poll_landed(client, peer, state)
	client.cancel(state)
	if landed.is_empty() and not peer.endpoint.is_empty():
		landed = "O2 must retire the deferred stream"
	return {"problem": landed, "elapsed": elapsed if landed.is_empty() else -1}


## One verdict for the stated numbers against the bounds.
func _readiness_verdict(elapsed: int) -> String:
	if elapsed < READINESS_MIN_MS:
		return "%d ms is too quick to be the deferred delivery" % elapsed
	if elapsed > T6_MS:
		return "advice ready after %d ms, beyond T6 %d" % [elapsed, T6_MS]
	if elapsed > READINESS_CEILING_MS:
		return "readiness %d ms sits at the cap, not a real timing" % elapsed
	return ""


## AC1 over `REPEATS` examples, each one a fresh stream.
func _check_readiness_within_configured_t6() -> String:
	var worst := 0
	for repeat in range(REPEATS):
		var sample: Dictionary = await _readiness_sample()
		var problem := str(sample["problem"])
		var elapsed := int(sample["elapsed"])
		if problem.is_empty():
			problem = _readiness_verdict(elapsed)
		if not problem.is_empty():
			return "repeat %d: %s" % [repeat, problem]
		worst = max(worst, elapsed)
		print(
			(
				"advice readiness: repeat %d ready after %d ms (T6 %d ms)"
				% [repeat + 1, elapsed, T6_MS]
			)
		)
	print(
		(
			"advice readiness: worst of %d = %d ms against T6 %d ms (ceiling %d ms)"
			% [REPEATS, worst, T6_MS, READINESS_CEILING_MS]
		)
	)
	return ""


## AC2 — a permanently silent peer: the local move path completes without
## waiting on the stream (I1, CTR-local-move.G1, F-move-advice.R6), and `poll()`
## returns with no advice. The timing window runs with the coverage probe off:
## an instrumented statement rewrites the whole hit file, which costs far more
## than the move and would hide the property under test.
func _check_local_move_never_waits_on_silent_peer() -> String:
	var probe := OS.get_environment("CI_COV_OUT")
	OS.set_environment("CI_COV_OUT", "")
	var problem: String = await _measure_local_move_never_waits()
	OS.set_environment("CI_COV_OUT", probe)
	return problem


## A session in a Shared game whose advice stream never answers.
func _silent_session() -> Dictionary:
	var silent := FakeAdviceTransport.new([])
	silent.blocking = true
	var client := AdviceClient.new()
	client.sim_factory = func() -> RefCounted: return silent
	client.configure("http://advice.test/advice", "test-key", T6_DEFAULT_MS)
	var session := SharedGameSession.new()
	session.advice_client = client
	session.start_shared(SharedGameSession.CLOCK_UNTIMED, 0, true)
	return {"session": session, "silent": silent}


## One move of the window: `""` and its duration when it applied at once and
## reissued O1, else the problem.
func _move_sample(session: SharedGameSession, move: Array, repeat: int) -> Dictionary:
	var requests := FakeAdviceTransport.all_requests.size()
	await _await_new_tick()
	var started := Time.get_ticks_msec()
	var applied := session.place(str(move[0]), str(move[1]))
	var took := Time.get_ticks_msec() - started
	var problem := ""
	if not bool(applied.get("ok", false)):
		problem = "the move must apply while the stream is silent"
	elif took > MOVE_CEILING_MS:
		problem = "a local move waited %d ms on advice (ceiling %d, I1)" % [took, MOVE_CEILING_MS]
	elif FakeAdviceTransport.all_requests.size() != requests + 1:
		problem = "the move must reissue O1 at once while the old stream is silent"
	elif (
		str(session.play_state()["position"]["side_to_move"])
		!= ("black" if repeat % 2 == 0 else "white")
	):
		problem = "the turn must change without waiting on advice (R6, I1)"
	return {"problem": problem, "took": took}


## `""` when `poll()` returns without waiting for the silent stream and writes
## nothing; the stream must still be silent after `SILENT_HOLD_MS`.
func _poll_problem(session: SharedGameSession) -> String:
	await _await_new_tick()
	var started := Time.get_ticks_msec()
	var events: Array = session.advice_control("poll").get("events", [])
	var polled := Time.get_ticks_msec() - started
	if polled > MOVE_CEILING_MS:
		return "poll() waited %d ms on a silent stream (ceiling %d, I1)" % [polled, MOVE_CEILING_MS]
	if not events.is_empty():
		return "a silent peer must not report advice readiness"
	if session.play_state()["advice_best_move"] != null:
		return "a silent peer must leave no advice showing"
	# The stream stays silent; nothing appears later either.
	await create_timer(float(SILENT_HOLD_MS) / 1000.0).timeout
	if not session.advice_control("poll").get("events", []).is_empty():
		return "the silent stream must not answer after %d ms" % SILENT_HOLD_MS
	if not session.gestures_available():
		return "play must continue while the advice stream is silent (I1)"
	return ""


## The bounded measurements themselves; see the caller for the probe window.
func _measure_local_move_never_waits() -> String:
	var setup := _silent_session()
	var session: SharedGameSession = setup["session"]
	if not (setup["silent"] as FakeAdviceTransport).is_live():
		return "the shared game must open an advice stream (R2)"
	var worst := 0
	for repeat in range(REPEATS):
		var sample: Dictionary = await _move_sample(session, MOVES[repeat], repeat)
		if not str(sample["problem"]).is_empty():
			return "repeat %d: %s" % [repeat, sample["problem"]]
		worst = max(worst, int(sample["took"]))
		print(
			(
				"advice never-delay: repeat %d move applied in %d ms with a silent peer"
				% [repeat + 1, int(sample["took"])]
			)
		)
	var poll_problem: String = await _poll_problem(session)
	if not poll_problem.is_empty():
		return poll_problem
	print(
		(
			"advice never-delay: worst of %d moves = %d ms (ceiling %d ms), %d ms silent"
			% [REPEATS, worst, MOVE_CEILING_MS, SILENT_HOLD_MS]
		)
	)
	return ""
