extends SceneTree
## Acceptance mutant for #616: restore the filed defect (a fixed 40 px x written
## after a centered anchor preset) on two panels of different parent kinds — a
## screen panel on ScreenHost and a dialog on SharedPlayPanel — then quit after
## layout settles so the evidence writer can measure the drawn rects.

var _presentation: Presentation
var _router: SessionRouter


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_router.locale = "en"
	_router.last_mode = "none"
	root.add_child(_presentation)
	call_deferred("_run")


func _run() -> void:
	_presentation.size = Vector2(1280, 720)
	for _i in 4:
		await process_frame
	_router._go_mode_pick("S1")
	for _i in 4:
		await process_frame
	var mode_pick := _presentation.get_node("ScreenHost/ModePick") as Control
	mode_pick.set_anchors_preset(Control.PRESET_CENTER)
	mode_pick.position = Vector2(40, 80)
	_router.handle_control("mode-pick", "C1")
	_router.clock = "untimed"
	_router.handle_control("shared-setup", "C5")
	for _i in 4:
		await process_frame
	_router.handle_control("shared-play", "C4")
	for _i in 4:
		await process_frame
	var resign := (
		(_presentation.get_node("ScreenHost/SharedPlay") as Control).find_child("ResignConfirm", true, false)
		as Control
	)
	resign.set_anchors_preset(Control.PRESET_CENTER)
	resign.position = Vector2(40, 200)
	for _i in 4:
		await process_frame
	print("MUTANT placed: ModePick.position=%s ResignConfirm.position=%s" % [mode_pick.position, resign.position])
	quit(0)
