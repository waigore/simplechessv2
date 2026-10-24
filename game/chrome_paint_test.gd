class_name ChromePaintTest
extends SceneTree
## #793 — a prompt that is placed over R1 must actually paint there. Reading
## `visible`, `rect`, or the prompt's own children is not enough: the board draws
## its backdrop, pieces, and overlays in canvas layers above `z_index` 0
## (`BoardPresentation`), so a prompt left at 0 is repainted by the board on a
## display while every state and rect check still passes.
##
## This guard reads drawn-tree state for both puzzle-play prompts:
##
## 1. **Paint band** — the prompt's effective canvas z is above every visible
##    layer the board owns, so nothing the board draws can repaint over it.
## 2. **Drawn copy and controls** — the prompt draws through an opaque
##    `panel_style()` panel, its message carries text, and both controls sit
##    inside that panel with a label whose every state stays ink on cream
##    (PAL.K4): the default theme paints a focused button's label near-white,
##    which erased S2's focused Confirm (#793).
##
## Headless Godot runs the dummy renderer, so a rasterised sample is not
## available here; the drawn-order and drawn-tree invariants are what a display
## obeys. `chrome_placement_test.gd` keeps the #616 centering guard.

const REFERENCE_FRAME := Vector2(1280, 720)
const SECOND_FRAME := Vector2(390, 844)
## The copy the prompt must show (UI-puzzle-play S2 / S3).
const PROMPTS := {
	"StreamConfirm": {"panel": "PuzzlePlay", "buttons": ["ConfirmStream", "CancelStream"]},
	"SaveFailure": {"panel": "PuzzlePlay", "buttons": ["DismissSave"]},
}
## PAL.K4 — body text on panels is at least this contrast.
const MIN_TEXT_CONTRAST := 4.5
## The states a button label can paint in; every one is a draw state.
const LABEL_COLOR_STATES := [
	"font_color",
	"font_focus_color",
	"font_hover_color",
	"font_pressed_color",
	"font_hover_pressed_color",
]

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
	var problem := ""
	for frame: Vector2 in [REFERENCE_FRAME, SECOND_FRAME]:
		_presentation.size = frame
		await _settle()
		problem = await _check_stream_confirm(frame)
		if problem.is_empty():
			problem = await _check_save_failure(frame)
		if not problem.is_empty():
			break
	if problem.is_empty():
		print("chrome paint: StreamConfirm and SaveFailure draw over the board")
		quit(0)
		return
	push_error(problem)
	quit(1)


func _check_stream_confirm(frame: Vector2) -> String:
	await _enter_puzzle_play()
	_router.handle_control("puzzle-play", "C5")
	await _settle()
	return _judge("StreamConfirm", frame)


func _check_save_failure(frame: Vector2) -> String:
	await _enter_puzzle_play()
	var persist := _presentation.get_node("PersistStore") as PersistStore
	persist.force_write_failure = true
	_router.handle_input_commit("b1", "b8", "")
	await _settle()
	persist.force_write_failure = false
	return _judge("SaveFailure", frame)


func _judge(node_name: String, frame: Vector2) -> String:
	var spec: Dictionary = PROMPTS[node_name]
	var panel := _presentation.get_node("ScreenHost/" + str(spec["panel"])) as Control
	var dialog := panel.find_child(node_name, true, false) as Control
	if dialog == null:
		return "missing prompt %s" % node_name
	if not dialog.is_visible_in_tree():
		return "%s is not visible in tree at %s" % [node_name, frame]
	var band := _band_problem(dialog)
	if not band.is_empty():
		return "%s at %s: %s" % [node_name, frame, band]
	return _drawn_problem(dialog, frame)


## Nothing the board draws may sit at or above the prompt's own canvas band.
func _band_problem(dialog: Control) -> String:
	var board := _presentation.get_node("ScreenHost/BoardPresentation") as CanvasItem
	var prompt_z := _effective_z(dialog)
	var top := _top_layer(board)
	if top.is_empty():
		return ""
	if prompt_z <= int(top["z"]):
		return (
			"prompt z %d does not clear the board layer %s (z %d): the board repaints over the prompt"
			% [prompt_z, top["path"], int(top["z"])]
		)
	return ""


## The highest canvas layer under `root` that a display would paint.
func _top_layer(root_item: CanvasItem) -> Dictionary:
	var best: Dictionary = {}
	for node: Node in root_item.find_children("*", "CanvasItem", true, false):
		var item := node as CanvasItem
		if item == null or not item.is_visible_in_tree():
			continue
		var z := _effective_z(item)
		if best.is_empty() or z > int(best["z"]):
			best = {"z": z, "path": str(root_item.get_path_to(item))}
	return best


## Canvas z as a display sees it: `z_as_relative` layers on the parent's band.
func _effective_z(item: CanvasItem) -> int:
	var total := item.z_index
	if not item.z_as_relative:
		return total
	var node: Node = item.get_parent()
	while node != null:
		var parent := node as CanvasItem
		if parent != null:
			total += parent.z_index
			if not parent.z_as_relative:
				break
		node = node.get_parent()
	return total


func _drawn_problem(dialog: Control, frame: Vector2) -> String:
	var panel := _painted_panel(dialog)
	if panel.is_empty():
		return "no opaque panel_style() panel under %s at %s" % [dialog.name, frame]
	var problem := _copy_problem(dialog, panel, frame)
	if problem.is_empty():
		problem = _controls_problem(dialog, panel, frame)
	return problem


func _copy_problem(dialog: Control, panel: Dictionary, frame: Vector2) -> String:
	var copy := dialog.find_child("*Msg", true, false) as Label
	if copy == null or copy.text.strip_edges().is_empty():
		return "%s draws no message copy at %s" % [dialog.name, frame]
	return _inside(copy, panel["rect"], dialog.name, frame)


func _controls_problem(dialog: Control, panel: Dictionary, frame: Vector2) -> String:
	for button_name: String in PROMPTS[dialog.name]["buttons"]:
		var button := dialog.find_child(button_name, true, false) as Button
		if button == null:
			return "%s has no %s control at %s" % [dialog.name, button_name, frame]
		if not button.is_visible_in_tree() or button.text.strip_edges().is_empty():
			return "%s draws no label on %s at %s" % [dialog.name, button_name, frame]
		var problem := _inside(button, panel["rect"], dialog.name, frame)
		if problem.is_empty():
			problem = _legible(button, panel, dialog.name, frame)
		if not problem.is_empty():
			return problem
	return ""


## The panel the prompt draws through, as a display sees it.
func _painted_panel(dialog: Control) -> Dictionary:
	for node: Node in dialog.find_children("*", "PanelContainer", true, false):
		var box := node as PanelContainer
		if box == null or not box.is_visible_in_tree():
			continue
		var style := box.get_theme_stylebox("panel")
		if style == null:
			continue
		var fill := _style_fill(style)
		if fill.a > 0.9:
			return {"rect": box.get_global_rect(), "fill": fill}
	return {}


func _style_fill(style: StyleBox) -> Color:
	if style is StyleBoxFlat:
		return (style as StyleBoxFlat).bg_color
	if style is StyleBoxTexture:
		return Color.WHITE
	var drawn := style.get_minimum_size()
	if drawn.x <= 0.0 or drawn.y <= 0.0:
		return Color(0, 0, 0, 0)
	return Color.WHITE


func _inside(child: Control, panel_rect: Rect2, dialog_name: String, frame: Vector2) -> String:
	var rect := child.get_global_rect()
	if not panel_rect.encloses(rect):
		return (
			"%s draws %s outside its panel at %s (child %s, panel %s)"
			% [dialog_name, child.name, frame, rect, panel_rect]
		)
	return ""


## PAL.K4 — the control's label reads on the panel in every state it draws in.
func _legible(button: Button, panel: Dictionary, dialog_name: String, frame: Vector2) -> String:
	var button_box := button.get_theme_stylebox("normal")
	var background: Color = panel["fill"]
	if button_box != null and _style_fill(button_box).a > 0.9:
		background = _style_fill(button_box)
	for state: String in LABEL_COLOR_STATES:
		var ink := button.get_theme_color(state)
		var ratio := _contrast(ink, background)
		if ratio < MIN_TEXT_CONTRAST:
			return (
				"%s draws %s's label as %s in %s at %s: %s contrast on its panel (%s)"
				% [
					dialog_name,
					button.name,
					ink.to_html(false),
					state,
					frame,
					"%.1f" % ratio,
					background.to_html(false)
				]
			)
	return ""


static func _contrast(a: Color, b: Color) -> float:
	var la := _luminance(a)
	var lb := _luminance(b)
	var lighter := maxf(la, lb)
	var darker := minf(la, lb)
	return (lighter + 0.05) / (darker + 0.05)


static func _luminance(color: Color) -> float:
	var c := color
	c.r = _channel(c.r)
	c.g = _channel(c.g)
	c.b = _channel(c.b)
	return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b


static func _channel(value: float) -> float:
	if value <= 0.03928:
		return value / 12.92
	return pow((value + 0.055) / 1.055, 2.4)


func _enter_puzzle_play() -> void:
	_router._go_mode_pick("S1")
	await _settle()
	_router.handle_control("mode-pick", "C2")
	await _settle()
	_deal_fixture()
	await _settle()


## C5 only needs an open puzzle, so seed one directly (the fixture
## `PuzzlePlayTest` and `chrome_placement_test.gd` deal).
func _deal_fixture() -> void:
	var flow := _router.puzzle_flow
	if flow == null or flow.session == null:
		return
	(
		flow
		. session
		. deal(
			[
				{
					"snapshot_id": PuzzleSession.SNAPSHOT_ID,
					"puzzle_id": "mate1",
					"fen": "6k1/5ppp/8/8/8/8/5PPP/1R4K1 b - - 0 1",
					"moves": ["g8h8", "b1b8"],
					"rating": 1000,
					"rating_deviation": 80,
					"popularity": 90,
					"nb_plays": 1200,
					"themes": [],
					"game_url": "",
					"opening_tags": "",
					"daily_date": "",
					"any_checkmate_wins": false,
				}
			]
		)
	)


func _settle() -> void:
	for _i in 4:
		await process_frame
