class_name CatalogDealTransportTest
extends SceneTree
## CTR-puzzle-catalog-read G3 / concurrency S4 (#528): leaving the stream retires an
## in-flight deal read without waiting on the host, the retired read never deals, and
## its worker is joined on a later call instead of being leaked.
##
## The peer is a local socket that accepts the connection and never answers, so the
## read is still in flight when the stream is left. No outside host is touched.

## Bound for `close()`; a frame's budget, far under the read's own cap.
const LEAVE_BUDGET_MS := 100
## Bound for the retired worker to stop and be joined.
const JOIN_BUDGET_MS := 4000
## The read's own cap, so the local peer is not fast enough to answer.
const READ_CAP_MS := 2000

var _server: TCPServer
var _peers: Array[StreamPeerTCP] = []


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var problem := _run_all()
	_server.stop()
	if not problem.is_empty():
		printerr("FAIL: %s" % problem)
		quit(1)
		return
	quit(0)


func _run_all() -> String:
	_server = TCPServer.new()
	if _server.listen(0, "127.0.0.1") != OK:
		return "the simulated host must listen"
	var transport := CatalogDealTransport.new()
	transport.start(_endpoint(), _request(), READ_CAP_MS)
	_pump_for(120)
	var problem := _check_in_flight(transport)
	if not problem.is_empty():
		return problem
	problem = _check_leave_does_not_wait(transport)
	if not problem.is_empty():
		return problem
	return _check_worker_is_joined_later()


## The peer has not answered, so the read is owed and reports nothing.
func _check_in_flight(transport: CatalogDealTransport) -> String:
	if transport.is_finished():
		return "an unanswered read must still be in flight"
	if not transport.poll().is_empty():
		return "G3: an unanswered read must report nothing, never wait"
	return ""


## S4 / G3 — retiring the read costs a frame's budget, not the host's timeout.
func _check_leave_does_not_wait(transport: CatalogDealTransport) -> String:
	var started := Time.get_ticks_msec()
	transport.close()
	var waited := Time.get_ticks_msec() - started
	if waited > LEAVE_BUDGET_MS:
		return "S4/G3: leaving must not wait on the host (waited %d ms)" % waited
	if not transport.is_finished():
		return "a retired read must report itself finished"
	if not transport.poll().is_empty():
		return "S4: a retired read must never deal, whatever its worker answered"
	return ""


## S4 — the retired worker is joined on a later call rather than leaked.
func _check_worker_is_joined_later() -> String:
	var joined := 0
	var deadline := Time.get_ticks_msec() + JOIN_BUDGET_MS
	while joined == 0 and Time.get_ticks_msec() < deadline:
		_pump_for(20)
		joined = CatalogDealTransport.reap()
	if joined == 0:
		return "S4: a retired worker must be joined on a later call, not leaked"
	return ""


func _endpoint() -> String:
	return "http://127.0.0.1:%d" % _server.get_local_port()


## O1 — player Elo, recent solved ids, and the key; the peer never reads it.
func _request() -> Dictionary:
	return {"api_key": "test-key", "player_elo": 1000.0, "recent_solved": []}


## Keep the listening socket draining for `ms` so the worker's connect succeeds.
func _pump_for(ms: int) -> void:
	var deadline := Time.get_ticks_msec() + ms
	while Time.get_ticks_msec() < deadline:
		if _server.is_connection_available():
			var peer := _server.take_connection()
			if peer != null:
				_peers.append(peer)
		OS.delay_msec(5)
