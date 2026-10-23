extends SceneTree
## Second AC5 observation for #528: the S4 retire path with a *real* unresponsive socket
## (accepts the connection, never answers), and no later `start()`/`close()` to call
## `CatalogDealTransport.reap()`. Judged in the manifest, not asserted here.

const CAP_MS := 3000

var _router: SessionRouter
var _server: TCPServer
var _port := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_server = TCPServer.new()
	_port = 0
	for candidate in range(17400, 17430):
		if _server.listen(candidate, "127.0.0.1") == OK:
			_port = candidate
			break
	print("SOCKET port=", _port)
	if _port == 0:
		print("SOCKET unavailable")
		quit(1)
		return
	var packed := load("res://main.tscn") as PackedScene
	var presentation := packed.instantiate() as Presentation
	var harness := presentation.get_node("PlaytestHarness")
	presentation.remove_child(harness)
	harness.free()
	_router = presentation.get_node("SessionRouter") as SessionRouter
	var persist := presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(presentation)
	await process_frame
	await process_frame
	_router.advice_endpoint = "http://127.0.0.1:%d" % _port
	_router.advice_api_key = "sim-key"
	_router.handle_control("mode-pick", "C2")
	var flow := _router.puzzle_flow
	var in_flight_before := flow.client.in_flight()
	var started := Time.get_ticks_usec()
	flow.leave()
	var leave_ms := float(Time.get_ticks_usec() - started) / 1000.0
	print("SOCKET in_flight_before=", in_flight_before, " leave_ms=", snapped(leave_ms, 0.01))
	var waited := 0
	while waited < 60 * (CAP_MS / 1000.0) + 120:
		await process_frame
		waited += 1
	print(
		"SOCKET waited_frames=",
		waited,
		" retiring_held=",
		CatalogDealTransport._retiring.size(),
		" dealt=",
		_router.puzzle_flow != null
	)
	quit(0)