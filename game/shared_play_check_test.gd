class_name SharedPlayCheckTest
extends SceneTree
## PER.R6 / UI-shared-play.US2.7 — the check cue end to end: the PAL.C8 mark on
## the checked King and on the R2 chip, beside the localized word, no audio.

var _presentation: Presentation
var _router: SessionRouter
var _seams: PlaytestSeams


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	var packed := load("res://main.tscn") as PackedScene
	_presentation = packed.instantiate() as Presentation
	var harness := _presentation.get_node("PlaytestHarness")
	_presentation.remove_child(harness)
	harness.free()
	_router = _presentation.get_node("SessionRouter") as SessionRouter
	_seams = _presentation.get_node("PlaytestSeams") as PlaytestSeams
	_router.locale = "en"
	_router.last_mode = "none"
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_presentation.set_deferred("size", Vector2(720, 1280))
	await process_frame
	await process_frame
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")  # untimed
	if _router.stage != "shared-play":
		_fail("check cue play stage")
		return
	var error := await _check_cue()
	if not error.is_empty():
		_fail(error)
		return
	quit(0)


func _check_cue() -> String:
	var play := _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel
	var board := _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
	var chip := play.find_child("CheckChip", true, false) as PanelContainer
	var label := play.find_child("CheckCue", true, false) as Label
	var marks := board.get_node_or_null("World/Seat/Content/Overlays/CheckMarks") as CheckMarks
	if chip == null or label == null or marks == null:
		return "PER.R6 check indicator missing"
	var quiet := _first_fail(
		[
			[not chip.visible and not label.visible, "PER.R6 chip shown out of check"],
			[marks.get_child_count() == 0, "PER.R6 board mark shown out of check"],
		]
	)
	if not quiet.is_empty():
		return quiet
	for move in [["e2", "e4"], ["e7", "e5"], ["d1", "h5"], ["b8", "c6"]]:
		_router.handle_input_commit(str(move[0]), str(move[1]))
	# Qxf7+ — the checking capture that drives both cues.
	_router.handle_input_commit("h5", "f7")
	await process_frame
	var style := chip.get_theme_stylebox("panel") as StyleBoxFlat
	var chip_bg := style.bg_color if style != null else Color.TRANSPARENT
	var rose := style != null and style.border_color == UiChrome.COLOR_DANGER
	var wide := style != null and style.border_width_left >= 1.5
	var checked := _first_fail(
		[
			[_router.shared_session._in_check_now(), "check cue fixture is not check"],
			[chip.visible and label.visible, "PER.R6 chip hidden while in check"],
			[
				label.text == StringTable.shared_play("check", "en"),
				"PER.R6 check word must stay the localized copy"
			],
			[rose, "PER.R6 check indicator must carry the PAL.C8 mark"],
			[wide, "UIS.I1 check indicator border under 1.5 px"],
			[
				_contrast_ratio(label.get_theme_color("font_color"), chip_bg) >= 4.5,
				"PER.R6 check word under 4.5:1 on its chip"
			],
			[_readable(chip, label), "PER.R6 check word must draw on one unwrapped line"],
			[marks.get_child_count() == 2, "PER.R6 checked King must carry the board mark"],
			[marks.marked_square == "e8", "PER.R6 board mark must sit on the checked King"],
			[
				str(_seams.assert_telemetry([_check_row()]).get("verdict", "")) == "pass",
				"TEL shared.check row missing"
			],
		]
	)
	if not checked.is_empty():
		return checked
	_router.handle_input_commit("e8", "f7")  # Kxf7 — the King is no longer in check.
	await process_frame
	return _first_fail(
		[
			[not chip.visible and not label.visible, "PER.R6 chip must clear with the check"],
			[marks.get_child_count() == 0, "PER.R6 board mark must clear with the check"],
		]
	)


## PER.R6 — a legible word cue: the label must get at least its own text width,
## so the chip cannot collapse to its padding and wrap the word letter by letter.
func _readable(chip: PanelContainer, label: Label) -> bool:
	var floor_px := label.get_combined_minimum_size().x
	if label.size.x + 0.5 < floor_px or chip.size.x + 0.5 < floor_px:
		return false
	return label.get_line_count() == 1


func _check_row() -> Dictionary:
	return {"event": "shared.check", "outcome": "shown", "story_id": "UI-shared-play.US2"}


## WCAG relative-luminance ratio of two drawn sRGB colors (PAL method).
static func _contrast_ratio(fg: Color, bg: Color) -> float:
	var a := _relative_luminance(fg)
	var b := _relative_luminance(bg)
	return (maxf(a, b) + 0.05) / (minf(a, b) + 0.05)


static func _relative_luminance(color: Color) -> float:
	return 0.2126 * _linear(color.r) + 0.7152 * _linear(color.g) + 0.0722 * _linear(color.b)


static func _linear(channel: float) -> float:
	if channel <= 0.03928:
		return channel / 12.92
	return pow((channel + 0.055) / 1.055, 2.4)


func _first_fail(checks: Array) -> String:
	for item in checks:
		if not bool(item[0]):
			return str(item[1])
	return ""


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
