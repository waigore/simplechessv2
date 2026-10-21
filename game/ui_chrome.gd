class_name UiChrome
extends RefCounted
## UIS color roles and control chrome for meta screens (PAL / UIS).

const COLOR_BG := Color("F7F1E8")
const COLOR_INK := Color("2C2A28")
const COLOR_ACCENT := Color("B8940C")
const COLOR_TABLE := Color("5C3A2A")
const COLOR_MUTED := Color("5c574e")
const COLOR_DANGER := Color("C28A86")
const COLOR_BORDER := Color(0.361, 0.227, 0.165, 0.28)

const MIN_TOUCH := 44.0
const BODY_PX := 16
const TITLE_PX := 28
const RADIUS := 8

const ICON_SHARED := "01a15dc4-969f-78fc-abb4-616df8fb4273"
const ICON_QUIT := "01a15dc4-969f-7176-8475-f6cd65a63925"
const ICON_ADVICE := "01a15dc4-969f-7a81-9d34-29765e8dd787"
const ICON_BACK := "01a15dc4-969f-7f48-9456-b4a7ae75565b"
const ART_PANEL := "01a15dc4-969f-7a2d-b550-db4a1ffd02c2"
const FONT_LATIN := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const FONT_CJK := "01a15215-15bd-77a5-b804-9ea4d95880a4"


static func style_button(button: Button, primary: bool = false, last_mode: bool = false) -> void:
	button.custom_minimum_size = Vector2(MIN_TOUCH, MIN_TOUCH)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", BODY_PX)
	button.add_theme_color_override("font_color", COLOR_INK)
	button.add_theme_color_override("font_disabled_color", Color(COLOR_INK, 0.4))
	var normal := StyleBoxFlat.new()
	normal.bg_color = COLOR_ACCENT if primary else COLOR_BG
	normal.border_color = COLOR_ACCENT if (primary or last_mode) else COLOR_BORDER
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(RADIUS)
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 11
	normal.content_margin_bottom = 11
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.border_color = COLOR_TABLE if not primary else COLOR_ACCENT.darkened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = COLOR_ACCENT
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(COLOR_BG, 0.7)
	disabled.border_color = COLOR_BORDER
	button.add_theme_stylebox_override("disabled", disabled)


static func style_label(label: Label, title: bool = false) -> void:
	label.add_theme_font_size_override("font_size", TITLE_PX if title else BODY_PX)
	label.add_theme_color_override("font_color", COLOR_INK if title else COLOR_MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


static func apply_font(control: Control, font: Font) -> void:
	if font == null:
		return
	control.add_theme_font_override("font", font)


static func panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = COLOR_BG
	box.border_color = COLOR_BORDER
	box.set_border_width_all(1)
	box.set_corner_radius_all(12)
	box.content_margin_left = 24
	box.content_margin_right = 24
	box.content_margin_top = 24
	box.content_margin_bottom = 24
	return box
