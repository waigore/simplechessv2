extends SceneTree
## Second observation for #528 AC5: the S4 retire path when nothing ever calls
## `CatalogDealTransport.reap()` again — a player who leaves inside the read's cap and
## quits without starting another read. `reap()` is only reached from `start()` and
## `close()`; the only production `start()` is the next deal's `request()`.
##
## Timing and deals only: no assertions, the drive makes the judgement.

var _router: SessionRouter


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
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
	_router.advice_endpoint = "http://sim.test/catalog/deal"
	_router.advice_api_key = "sim-key"
	_router.handle_control("mode-pick", "C2")
	var flow := _router.puzzle_flow
	var started := Time.get_ticks_usec()
	flow.leave()
	var leave_ms := float(Time.get_ticks_usec() - started) / 1000.0
	print("RETIRE leave_ms=", snapped(leave_ms, 0.01), " stage=", _router.stage)
	# The read's own cap is 3000 ms; wait past it with nothing calling reap().
	var waited := 0
	while waited < 400:
		await process_frame
		waited += 1
	print("RETIRE waited_frames=", waited, " puzzle_flow=", _router.puzzle_flow != null)
	print("RETIRE retiring_held=", CatalogDealTransport._retiring.size())
	quit(0)
