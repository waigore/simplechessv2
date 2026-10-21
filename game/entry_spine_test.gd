class_name EntrySpineTest
extends SceneTree
## Headless coverage for UI-mode-pick / UI-shared-setup (#57).

var _presentation: Presentation
var _router: SessionRouter
var _error := ""


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
	_router.last_mode = ""
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_error = _check_cold_open()
	if _error.is_empty():
		_error = _locale_cycle()
	if _error.is_empty():
		_error = _quit_confirm_cancel()
	if _error.is_empty():
		_error = _shared_path()
	if _error.is_empty():
		_error = _string_table()
	if _error.is_empty():
		quit(0)
		return
	_fail(_error)


func _check_cold_open() -> String:
	if _router.stage != "mode-pick":
		return "cold open did not reach mode-pick"
	var mode_pick := _mode_pick()
	if not mode_pick.visible or mode_pick.ui_state != "S1":
		return "mode-pick S1"
	var shared := mode_pick.find_child("SharedGame", true, false) as Button
	if shared == null or not shared.text.contains("Last"):
		return "default Last mode highlight is Shared game"
	return ""


func _locale_cycle() -> String:
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "zh-Hant":
		return "locale en→zh-Hant"
	var mode_pick := _mode_pick()
	var locale_btn := mode_pick.find_child("SwitchLocale", true, false) as Button
	if locale_btn == null or locale_btn.text != "繁體中文":
		return "R3 own-name zh-Hant"
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "ja":
		return "locale zh-Hant→ja"
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "en":
		return "locale ja→en"
	return ""


func _quit_confirm_cancel() -> String:
	_router.handle_control("mode-pick", "C3")
	var mode_pick := _mode_pick()
	if mode_pick.ui_state != "S3":
		return "quit did not raise EX.confirm"
	_router.handle_control("mode-pick", "cancel")
	if mode_pick.ui_state != "S1" or _router.stage != "mode-pick":
		return "cancel did not return to S1"
	_router.handle_control("mode-pick", "C3")
	_router.handle_control("mode-pick", "confirm")
	if _router.stage != "session-ended" or not _router.session_ended:
		return "confirm did not end sitting"
	return ""


func _shared_path() -> String:
	var seams := _presentation.get_node("PlaytestSeams") as PlaytestSeams
	seams.jump("mode-pick")
	_router.handle_control("mode-pick", "C1")
	if _router.stage != "shared-setup" or _router.last_mode != "shared":
		return "C1 → shared-setup / Last mode"
	var setup := _shared_setup()
	if not setup.visible:
		return "shared-setup visible"
	var increment := setup.find_child("Increment", true, false) as Button
	if increment == null or not increment.disabled:
		return "C3 unavailable when Untimed"
	_router.handle_control("shared-setup", "C2")
	if _router.clock != "blitz":
		return "clock cycle to Blitz"
	if increment.disabled:
		return "C3 available when Blitz"
	return _shared_path_continued(setup)


func _shared_path_continued(setup: SharedSetupPanel) -> String:
	_router.handle_control("shared-setup", "C3")
	if _router.increment != 5:
		return "increment cycle"
	_router.handle_control("shared-setup", "C1")
	if _router.white_seat != "top":
		return "white seat cycle"
	_router.handle_control("shared-setup", "C4")
	if _router.advice_on:
		return "advice toggle"
	_router.handle_control("shared-setup", "C6")
	if _router.stage != "mode-pick":
		return "Back → mode-pick"
	if setup == null:
		return "setup missing"
	return _shared_start_and_save()


func _shared_start_and_save() -> String:
	_router.handle_control("mode-pick", "C1")
	_router.handle_control("shared-setup", "C5")
	if _router.stage != "shared-play" or not _router.options_locked:
		return "Start did not lock into shared-play"
	_router.show_save_failure()
	if _mode_pick().ui_state != "S4":
		return "save-failure state S4"
	_router.handle_control("mode-pick", "dismiss")
	if _mode_pick().ui_state != "S1":
		return "dismiss save-failure"
	return ""


func _string_table() -> String:
	if StringTable.next_locale("en") != "zh-Hant":
		return "next_locale"
	if StringTable.locale_from_os("zh_TW") != "zh-Hant":
		return "os locale"
	if StringTable.mode_pick("locale", "ja") != "日本語":
		return "locale own name"
	if StringTable.shared_setup("start", "zz") != "Start":
		return "shared-setup fallback"
	if StringTable.normalize_locale("nope") != "en":
		return "normalize"
	return ""


func _mode_pick() -> ModePickPanel:
	return _presentation.get_node("ScreenHost/ModePick") as ModePickPanel


func _shared_setup() -> SharedSetupPanel:
	return _presentation.get_node("ScreenHost/SharedSetup") as SharedSetupPanel


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
