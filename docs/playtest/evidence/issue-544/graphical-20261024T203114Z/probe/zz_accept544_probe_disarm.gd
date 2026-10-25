extends Node
## D1 cancelled path: disarm an open window with measure("") and see what it returns.

var _router: Node
var _seams: Node

func _ready() -> void:
	await get_tree().process_frame
	_seams = get_node_or_null("../Presentation/PlaytestSeams")
	_router = get_node_or_null("../Presentation/SessionRouter")
	for _i in 90:
		await get_tree().process_frame
	_router.handle_control("mode-pick", "C1")
	for _i in 8:
		await get_tree().process_frame
	_router.handle_control("shared-setup", "C5")
	for _i in 8:
		await get_tree().process_frame
	_seams.start_measurement("frame_times")
	for _i in 10:
		await get_tree().process_frame
	var cancelled: Dictionary = _seams.measure("")
	print("ZZ disarm=%s" % JSON.stringify({"kind": cancelled.get("kind",""), "status": cancelled.get("status",""), "detail": cancelled.get("detail",""), "samples": int(cancelled.get("sample_count",0)), "max_ms": float(cancelled.get("max_ms",0.0))}))
	print("ZZ last=%s" % JSON.stringify({"kind": _seams.measurement.last().get("kind",""), "status": _seams.measurement.last().get("status",""), "samples": int(_seams.measurement.last().get("sample_count",0))}))
	get_tree().quit(0)
