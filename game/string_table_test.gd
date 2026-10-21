class_name StringTableTest
extends SceneTree
## Wave-1 localization: Copy keys, CJK glyphs, and ~40% layout (#62).

const VIEW_SIZE := Vector2(720, 1280)
const GROWTH := 0.4

var _presentation: Presentation
var _router: SessionRouter
var _ui_font: Font


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
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	_presentation.set_deferred("size", VIEW_SIZE)
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	var problem := _all_locales_populated()
	if problem.is_empty():
		problem = _no_english_leak_in_cjk()
	if problem.is_empty():
		problem = _locale_helpers()
	if problem.is_empty():
		problem = _font_chain_and_glyphs()
	if problem.is_empty():
		problem = await _screen_layouts_at_growth()
	if problem.is_empty():
		quit(0)
		return
	push_error(problem)
	quit(1)


func _all_locales_populated() -> String:
	var suites: Array = [
		["mode-pick", StringTable.mode_pick_keys(), Callable(StringTable, "mode_pick")],
		["shared-setup", StringTable.shared_setup_keys(), Callable(StringTable, "shared_setup")],
		["shared-play", StringTable.shared_play_keys(), Callable(StringTable, "shared_play")],
		["shared-result", StringTable.shared_result_keys(), Callable(StringTable, "shared_result")],
		["exceptions", StringTable.exception_keys(), Callable(StringTable, "exception_text")],
	]
	for suite in suites:
		var label := str(suite[0])
		var keys: PackedStringArray = suite[1]
		var getter: Callable = suite[2]
		if keys.is_empty():
			return "%s has no keys" % label
		for locale in StringTable.LOCALES:
			for key in keys:
				var text := str(getter.call(key, locale))
				if text.is_empty() or text == key:
					return "%s.%s missing in %s" % [label, key, locale]
	return ""


func _no_english_leak_in_cjk() -> String:
	var samples := {
		"mode-pick.title": [Callable(StringTable, "mode_pick"), "title"],
		"shared-setup.start": [Callable(StringTable, "shared_setup"), "start"],
		"shared-play.resign": [Callable(StringTable, "shared_play"), "resign"],
		"shared-result.title": [Callable(StringTable, "shared_result"), "title"],
		"exceptions.unsupported_input":
		[Callable(StringTable, "exception_text"), "unsupported_input"],
	}
	for label in samples:
		var pair: Array = samples[label]
		var getter: Callable = pair[0]
		var key := str(pair[1])
		var en := str(getter.call(key, "en"))
		var zh := str(getter.call(key, "zh-Hant"))
		var ja := str(getter.call(key, "ja"))
		if zh == en or ja == en:
			return "%s still English in CJK" % label
	return ""


func _locale_helpers() -> String:
	var err := ""
	if StringTable.next_locale("en") != "zh-Hant":
		err = "next_locale en"
	elif StringTable.next_locale("zh-Hant") != "ja":
		err = "next_locale zh-Hant"
	elif StringTable.next_locale("ja") != "en":
		err = "next_locale ja"
	elif StringTable.locale_from_os("zh_TW") != "zh-Hant":
		err = "os zh"
	elif StringTable.locale_from_os("ja_JP") != "ja":
		err = "os ja"
	elif StringTable.mode_pick("locale", "en") != "English":
		err = "own name en"
	elif StringTable.mode_pick("locale", "zh-Hant") != "繁體中文":
		err = "own name zh"
	elif StringTable.mode_pick("locale", "ja") != "日本語":
		err = "own name ja"
	elif StringTable.shared_setup("start", "zz") != "Start":
		err = "unshipped locale falls back to en"
	return err


func _font_chain_and_glyphs() -> String:
	var resolver := _presentation.get_node_or_null("AssetResolver") as AssetResolver
	if resolver == null:
		return "AssetResolver missing"
	var latin := resolver.resolve(UiChrome.FONT_LATIN) as Font
	var cjk := resolver.resolve(UiChrome.FONT_CJK) as Font
	if latin == null or cjk == null:
		return "UI fonts did not resolve"
	if cjk.fallbacks.is_empty():
		return "CJK catalog asset missing JP fallback face"
	var faces: Array[Font] = [cjk]
	latin.fallbacks = faces
	_ui_font = latin
	var suites: Array = [
		[StringTable.mode_pick_keys(), Callable(StringTable, "mode_pick")],
		[StringTable.shared_setup_keys(), Callable(StringTable, "shared_setup")],
		[StringTable.shared_play_keys(), Callable(StringTable, "shared_play")],
		[StringTable.shared_result_keys(), Callable(StringTable, "shared_result")],
		[StringTable.exception_keys(), Callable(StringTable, "exception_text")],
	]
	for locale in StringTable.LOCALES:
		for suite in suites:
			var keys: PackedStringArray = suite[0]
			var getter: Callable = suite[1]
			for key in keys:
				var text := str(getter.call(key, locale))
				var missing := _missing_glyphs(latin, text)
				if not missing.is_empty():
					return "missing glyphs in %s/%s: %s" % [locale, key, missing]
	var clock_missing := _missing_glyphs(latin, "0:00 / 59:59")
	if not clock_missing.is_empty():
		return "clock glyphs missing: %s" % clock_missing
	return ""


func _missing_glyphs(font: Font, text: String) -> String:
	var missing := ""
	for index in text.length():
		var code := text.unicode_at(index)
		if code <= 0x20:
			continue
		if _chain_has_char(font, code):
			continue
		var ch := String.chr(code)
		if not missing.contains(ch):
			missing += ch
	return missing


func _chain_has_char(font: Font, code: int) -> bool:
	if font == null:
		return false
	if font.has_char(code):
		return true
	for fallback in font.fallbacks:
		if fallback is Font and _chain_has_char(fallback as Font, code):
			return true
	return false


func _screen_layouts_at_growth() -> String:
	_presentation.size = VIEW_SIZE
	await process_frame
	await process_frame
	var err := await _check_mode_pick_layouts()
	if err.is_empty():
		err = await _check_shared_setup_layout()
	if err.is_empty():
		err = await _check_shared_play_layouts()
	if err.is_empty():
		err = await _check_shared_result_layout()
	return err


func _check_mode_pick_layouts() -> String:
	if _router.stage != "mode-pick":
		return "expected mode-pick"
	for locale in StringTable.LOCALES:
		_router.locale = locale
		_router._go_mode_pick("S1")
		await process_frame
		var panel := _mode_pick()
		for state_id in ["S1", "S3", "S4"]:
			panel.set_ui_state(state_id)
			await process_frame
			var err := await _assert_readable(panel, "mode-pick %s %s" % [locale, state_id])
			if not err.is_empty():
				return err
	_router.locale = "en"
	_router._go_mode_pick("S1")
	await process_frame
	return ""


func _check_shared_setup_layout() -> String:
	_router.handle_control("mode-pick", "C1")
	await process_frame
	if _router.stage != "shared-setup":
		return "expected shared-setup"
	for locale in StringTable.LOCALES:
		_router.locale = locale
		_router.screen_requested.emit("shared-setup", _router._shared_setup_state())
		await process_frame
		var err := await _assert_readable(_shared_setup(), "shared-setup %s" % locale)
		if not err.is_empty():
			return err
	_router.locale = "en"
	_router.handle_control("shared-setup", "C6")
	await process_frame
	return ""


func _check_shared_play_layouts() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	await process_frame
	if _router.stage != "shared-play" or _router.shared_session == null:
		return "expected shared-play"
	var board := _board()
	var err := ""
	for locale in StringTable.LOCALES:
		_router.locale = locale
		err = await _drive_play_locale(locale)
		if not err.is_empty():
			break
		if board.offset_top < Presentation.PLAY_CHROME_TOP_PX - 0.5:
			err = "shared-play %s cropped board under chrome" % locale
			break
	_router.locale = "en"
	_router.shared_session.play_ui_state = SharedGameSession.UI_S1
	_router.shared_session.confirm_kind = ""
	_router.shared_session.draw_offer = ""
	_router._emit_play_screen()
	await process_frame
	return err


func _drive_play_locale(locale: String) -> String:
	var states: Array = [
		["S1", SharedGameSession.UI_S1, ""],
		["S2-resign", SharedGameSession.UI_S2, SharedGameSession.CONFIRM_RESIGN],
		["S4", SharedGameSession.UI_S4, ""],
		["S5", SharedGameSession.UI_S5, ""],
		["S6", SharedGameSession.UI_S6, ""],
	]
	for entry in states:
		var err := await _drive_play_chrome(locale, str(entry[0]), str(entry[1]), str(entry[2]))
		if not err.is_empty():
			return err
	return ""


func _drive_play_chrome(locale: String, label: String, ui_state: String, confirm: String) -> String:
	var session := _router.shared_session
	session.play_ui_state = ui_state
	session.confirm_kind = confirm
	session.draw_offer = "white" if ui_state == SharedGameSession.UI_S6 else ""
	_router._emit_play_screen()
	await process_frame
	return await _assert_readable(_play_panel(), "shared-play %s %s" % [locale, label])


func _check_shared_result_layout() -> String:
	if _router.stage == "shared-play":
		_router.handle_control("shared-play", "C4")
		_router.handle_control("shared-play", "confirm")
		await process_frame
	if _router.stage != "shared-result":
		_presentation.show_screen(
			Presentation.SHARED_RESULT, {"locale": "en", "result_key": "result_draw"}
		)
		await process_frame
	for locale in StringTable.LOCALES:
		_shared_result().configure(locale, "result_draw", _ui_font)
		await process_frame
		var err := await _assert_readable(_shared_result(), "shared-result %s" % locale)
		if not err.is_empty():
			return err
	return ""


func _assert_readable(panel: Control, tag: String) -> String:
	if panel == null or not panel.visible:
		return "%s panel hidden" % tag
	## Finish UIS.M1 so asserts see settled chrome, not a mid-fade panel.
	_settle_motion(panel)
	await process_frame
	var err := _assert_visible_copy(panel, tag)
	if not err.is_empty():
		return err
	return await _assert_grown_copy(panel, tag)


func _settle_motion(node: Node) -> void:
	## Only finish UIS.M1 fades; leave intentional a=0 focus sentinels alone.
	if node.has_meta("_uis_m1_tween"):
		var prior: Variant = node.get_meta("_uis_m1_tween")
		if prior is Tween:
			(prior as Tween).kill()
		if node is CanvasItem:
			(node as CanvasItem).modulate.a = 1.0
	for child in node.get_children():
		_settle_motion(child)


func _assert_visible_copy(panel: Control, tag: String) -> String:
	var frame := Rect2(Vector2.ZERO, VIEW_SIZE)
	var saw_text := false
	for node in _player_facing_text(panel):
		saw_text = true
		if node is Button and (node as Button).clip_text:
			return "%s clips text on %s" % [tag, node.name]
		var text := _control_text(node)
		if text.is_empty():
			return "%s empty copy on %s" % [tag, node.name]
		var rect := node.get_global_rect()
		if rect.size.x <= 1.0 or rect.size.y <= 1.0:
			continue
		if not frame.intersects(rect):
			return "%s %s outside frame at %s" % [tag, node.name, str(rect)]
		if node is Button:
			if node.size.y + 0.5 < UiChrome.MIN_TOUCH:
				return "%s touch height on %s" % [tag, node.name]
	if not saw_text:
		return "%s no player-facing text" % tag
	return ""


func _assert_grown_copy(panel: Control, tag: String) -> String:
	## quality.md Localization: tolerate ~40% length growth versus English.
	var originals: Dictionary = {}
	for node in _player_facing_text(panel):
		var current := _control_text(node)
		originals[node] = current
		_set_control_text(node, _grow(current))
	await process_frame
	var err := _assert_visible_copy(panel, "%s +40%%" % tag)
	for node in originals.keys():
		_set_control_text(node as Control, str(originals[node]))
	return err


func _grow(text: String) -> String:
	var extra := int(ceili(float(text.length()) * GROWTH))
	if extra <= 0:
		return text
	return text + text.substr(0, mini(extra, text.length()))


func _player_facing_text(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	_collect_facing(root, out)
	return out


func _collect_facing(node: Node, out: Array[Control]) -> void:
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is Label or node is Button:
		var control := node as Control
		## Skip focus-only sentinels (promote / select / place ghosts).
		if control.modulate.a >= 0.05 and not _control_text(control).is_empty():
			out.append(control)
		return
	for child in node.get_children():
		_collect_facing(child, out)


func _control_text(node: Control) -> String:
	if node is Label:
		return (node as Label).text
	if node is Button:
		return (node as Button).text
	return ""


func _set_control_text(node: Control, text: String) -> void:
	if node is Label:
		(node as Label).text = text
	elif node is Button:
		(node as Button).text = text


func _mode_pick() -> ModePickPanel:
	return _presentation.get_node("ScreenHost/ModePick") as ModePickPanel


func _shared_setup() -> SharedSetupPanel:
	return _presentation.get_node("ScreenHost/SharedSetup") as SharedSetupPanel


func _play_panel() -> SharedPlayPanel:
	return _presentation.get_node("ScreenHost/SharedPlay") as SharedPlayPanel


func _shared_result() -> SharedResultPanel:
	return _presentation.get_node("ScreenHost/SharedResult") as SharedResultPanel


func _board() -> BoardPresentation:
	return _presentation.get_node("ScreenHost/BoardPresentation") as BoardPresentation
