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
## UIS.T2 project-space sizes at REFERENCE_FRAME_HEIGHT_PX (Presentation scales them).
const BODY_PX := 16
const TITLE_PX := 28
## UIS.I1 stroke floor: 1.5 screen px on every stroked icon, keyline, or chip edge.
const KEYLINE_PX := 1.5
## UIS.T2 reference frame height (SIT.6 / S13 read it, never set it).
const REFERENCE_FRAME_HEIGHT_PX := 640.0
const RADIUS := 8
## UIS.M1 screen / panel transition (0.15–0.25 s ease-out).
const M1_S := 0.2
## UIS.M2 focus / selection change (≤0.15 s ease-out).
const M2_S := 0.12
## UIS.M3 value change (≤0.2 s ease-out; no bounce).
const M3_S := 0.18

const ICON_SHARED := "01a15dc4-969f-78fc-abb4-616df8fb4273"
const ICON_QUIT := "01a15dc4-969f-7176-8475-f6cd65a63925"
const ICON_ADVICE := "01a15dc4-969f-7a81-9d34-29765e8dd787"
const ICON_BACK := "01a15dc4-969f-7f48-9456-b4a7ae75565b"
const ART_PANEL := "01a15dc4-969f-7a2d-b550-db4a1ffd02c2"
const FONT_LATIN := "01a15215-15bd-7e3f-a3f8-ffcb1333a0ab"
const FONT_CJK := "01a15215-15bd-77a5-b804-9ea4d95880a4"


static func style_button(
	button: Button, primary: bool = false, last_mode: bool = false, text_scale: float = 1.0
) -> void:
	button.custom_minimum_size = Vector2(MIN_TOUCH, MIN_TOUCH)
	button.clip_text = false
	button.focus_mode = Control.FOCUS_ALL
	add_font_size(button, BODY_PX, text_scale)
	button.add_theme_color_override("font_color", COLOR_INK)
	button.add_theme_color_override("font_disabled_color", Color(COLOR_INK, 0.4))
	# #793 — the default theme paints a focused, hovered, or pressed button's
	# label near-white, which is invisible on this cream chrome (PAL.K4: ink on
	# cream). Keep C9 ink in every state the M2 border ease already carries.
	for state in [
		"font_focus_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"
	]:
		button.add_theme_color_override(state, COLOR_INK)
	var base_border := COLOR_ACCENT if (primary or last_mode) else COLOR_BORDER
	var hover_border := COLOR_TABLE if not primary else COLOR_ACCENT.darkened(0.12)
	var normal: StyleBoxFlat
	var already_bound: bool = button.get_meta("_uis_m2_bound", false)
	if already_bound:
		normal = button.get_meta("_uis_m2_box") as StyleBoxFlat
	else:
		normal = StyleBoxFlat.new()
	normal.bg_color = COLOR_ACCENT if primary else COLOR_BG
	normal.border_color = base_border
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(RADIUS)
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 11
	normal.content_margin_bottom = 11
	# Same box for normal/hover/focus so M2 can ease border changes (no theme snap).
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("focus", normal)
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(COLOR_BG, 0.7)
	disabled.border_color = COLOR_BORDER
	button.add_theme_stylebox_override("disabled", disabled)
	if already_bound:
		button.set_meta("_uis_m2_base", base_border)
		button.set_meta("_uis_m2_hover", hover_border)
	else:
		_bind_selection_motion(button, normal, base_border, hover_border)


static func transition_in(node: CanvasItem, duration: float = M1_S) -> void:
	if node == null:
		return
	if node.has_meta("_uis_m1_tween"):
		var prior: Variant = node.get_meta("_uis_m1_tween")
		if prior is Tween:
			(prior as Tween).kill()
	node.visible = true
	node.modulate.a = 0.0
	var tw := node.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(node, "modulate:a", 1.0, duration)
	node.set_meta("_uis_m1_tween", tw)


static func tween_value_modulate(node: CanvasItem, duration: float = M3_S) -> void:
	## Brief ease-out flash for value changes (UIS.M3); no bounce.
	if node == null:
		return
	node.modulate = Color(1.08, 1.05, 0.95, 1.0)
	var tw := node.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(node, "modulate", Color.WHITE, duration)


static func _bind_selection_motion(
	button: Button, box: StyleBoxFlat, base_border: Color, hover_border: Color
) -> void:
	if button.get_meta("_uis_m2_bound", false):
		return
	button.set_meta("_uis_m2_bound", true)
	button.set_meta("_uis_m2_box", box)
	button.set_meta("_uis_m2_base", base_border)
	button.set_meta("_uis_m2_hover", hover_border)
	button.mouse_entered.connect(_on_button_emphasis.bind(button, true))
	button.mouse_exited.connect(_on_button_emphasis.bind(button, false))
	button.focus_entered.connect(_on_button_emphasis.bind(button, true))
	button.focus_exited.connect(_on_button_emphasis.bind(button, false))


static func _on_button_emphasis(button: Button, emphasized: bool) -> void:
	if button.disabled:
		return
	var box: StyleBoxFlat = button.get_meta("_uis_m2_box") as StyleBoxFlat
	if box == null:
		return
	var base_border: Color = button.get_meta("_uis_m2_base") as Color
	var hover_border: Color = button.get_meta("_uis_m2_hover") as Color
	var target_border := hover_border if emphasized else base_border
	var target_width := 2.0 if emphasized and button.has_focus() else 1.0
	if button.has_meta("_uis_m2_tween"):
		var prior: Variant = button.get_meta("_uis_m2_tween")
		if prior is Tween:
			(prior as Tween).kill()
	var tw := button.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_parallel(true)
	tw.tween_property(box, "border_color", target_border, M2_S)
	tw.tween_property(box, "border_width_left", target_width, M2_S)
	tw.tween_property(box, "border_width_top", target_width, M2_S)
	tw.tween_property(box, "border_width_right", target_width, M2_S)
	tw.tween_property(box, "border_width_bottom", target_width, M2_S)
	button.set_meta("_uis_m2_tween", tw)


static func style_label(label: Label, title: bool = false, text_scale: float = 1.0) -> void:
	add_font_size(label, TITLE_PX if title else BODY_PX, text_scale)
	label.add_theme_color_override("font_color", COLOR_INK if title else COLOR_MUTED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


static func add_body_size(control: Control, text_scale: float = 1.0) -> void:
	add_font_size(control, BODY_PX, text_scale)


static func add_title_size(control: Control, text_scale: float = 1.0) -> void:
	add_font_size(control, TITLE_PX, text_scale)


## UIS.T2 ratio to the 640 px reference frame height; Presentation reflows to it.
static func text_scale_for_frame_height(frame_height_px: float) -> float:
	if frame_height_px <= 0.0:
		return 1.0
	return frame_height_px / REFERENCE_FRAME_HEIGHT_PX


## The frame every UIS.T2 surface currently renders into: the running window, the
## same frame `S13` reports. A control's own height is never the frame — a 44 px
## button would resolve `16 * 44 / 640` and draw at 1 px (#708). A headless runner
## has no display frame (its root window stays at the 100 px placeholder), so a
## full-rect control reports the project size instead.
static func frame_height_of(control: Control) -> float:
	if not is_instance_valid(control) or not control.is_inside_tree():
		return 0.0
	var tree := control.get_tree()
	if tree != null and tree.root != null and DisplayServer.get_name() != "headless":
		return float(tree.root.size.y)
	return float(ProjectSettings.get_setting("display/window/size/viewport_height", 0))


## Fills the frame: resized controls take the ratio of the frame they render in.
## Every UIS.T2 write goes through here, so a restyle on any action keeps the
## reflowed size instead of a stale cached scale (S13 / AC4).
static func responsive_text_scale(control: Control, text_scale: float = 1.0) -> float:
	if not control.is_inside_tree():
		return text_scale
	if not control.is_visible_in_tree():
		return text_scale
	return text_scale_for_frame_height(frame_height_of(control))


## The one place UIS.T2 sizes are applied: project-space px times the frame-height factor.
static func add_font_size(control: Control, base_px: int, text_scale: float = 1.0) -> void:
	var ratio := responsive_text_scale(control, text_scale)
	control.add_theme_font_size_override("font_size", scaled_px(base_px, ratio))


static func scaled_px(base_px: int, text_scale: float) -> int:
	return int(round(float(base_px) * text_scale))


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
