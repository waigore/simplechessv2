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
	_router.last_mode = "none"
	## Isolate persist for this suite so cold open is Last mode none.
	var persist := _presentation.get_node_or_null("PersistStore") as PersistStore
	if persist != null:
		persist.memory_backend = {}
		persist.clear_storage()
	root.add_child(_presentation)
	call_deferred("_after_boot")


func _after_boot() -> void:
	_error = _check_cold_open()
	if _error.is_empty():
		_error = _locale_cycle()
	if _error.is_empty():
		_error = _exception_point_hover()
	if _error.is_empty():
		_error = _quit_confirm_cancel()
	if _error.is_empty():
		_error = _shared_path()
	if _error.is_empty():
		_error = _string_table()
	if _error.is_empty():
		_error = _uis_motion_present()
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
	var mode_pick := _mode_pick()
	var title := mode_pick.find_child("Title", true, false) as Label
	var en_title := StringTable.mode_pick("title", "en")
	if title == null or title.text != en_title:
		return "mode-pick title before locale switch"
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "zh-Hant":
		return "locale en→zh-Hant"
	mode_pick = _mode_pick()
	title = mode_pick.find_child("Title", true, false) as Label
	var locale_btn := mode_pick.find_child("SwitchLocale", true, false) as Button
	if locale_btn == null or locale_btn.text != "繁體中文":
		return "R3 own-name zh-Hant"
	if title == null or title.text != StringTable.mode_pick("title", "zh-Hant"):
		return "mode-pick copy did not switch to zh-Hant"
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "ja":
		return "locale zh-Hant→ja"
	mode_pick = _mode_pick()
	title = mode_pick.find_child("Title", true, false) as Label
	locale_btn = mode_pick.find_child("SwitchLocale", true, false) as Button
	if locale_btn == null or locale_btn.text != "日本語":
		return "R3 own-name ja"
	if title == null or title.text != StringTable.mode_pick("title", "ja"):
		return "mode-pick copy did not switch to ja"
	_router.handle_control("mode-pick", "C4")
	if _router.locale != "en":
		return "locale ja→en"
	return ""


func _exception_point_hover() -> String:
	## B7: pointer moved over Confirm / Cancel / Dismiss emits IN.point.
	_router.handle_control("mode-pick", "C3")
	var mode_pick := _mode_pick()
	var err := _assert_hover(mode_pick, "S3", "ConfirmQuit", "confirm")
	if not err.is_empty():
		return err
	err = _assert_hover(mode_pick, "S3", "CancelQuit", "cancel")
	if not err.is_empty():
		return err
	_router.handle_control("mode-pick", "cancel")
	_router.show_save_failure()
	err = _assert_hover(mode_pick, "S4", "DismissSave", "dismiss")
	if not err.is_empty():
		return err
	_router.handle_control("mode-pick", "dismiss")
	return ""


func _assert_hover(
	mode_pick: ModePickPanel, expect_state: String, node_name: String, control_id: String
) -> String:
	if mode_pick.ui_state != expect_state:
		return "point hover setup: need %s" % expect_state
	var button := mode_pick.find_child(node_name, true, false) as Button
	if button == null:
		return "%s missing" % node_name
	button.mouse_entered.emit()
	if _presentation.last_point_control != control_id:
		return "B7 hover %s did not set last_point_control" % node_name
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


func _uis_motion_present() -> String:
	if UiChrome.M1_S < 0.15 or UiChrome.M1_S > 0.25:
		return "UIS.M1 duration out of range"
	if UiChrome.M2_S > 0.15:
		return "UIS.M2 duration over 0.15"
	if UiChrome.M3_S > 0.2:
		return "UIS.M3 duration over 0.2"
	var mode_pick := _mode_pick()
	if not mode_pick.has_meta("_uis_m1_tween") and mode_pick.modulate.a < 1.0:
		return "mode-pick missing M1 transition path"
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
	var err := _cycle_setup_options(setup)
	if not err.is_empty():
		return err
	_router.handle_control("shared-setup", "C6")
	if _router.stage != "mode-pick":
		return "Back → mode-pick"
	if setup == null:
		return "setup missing"
	return _shared_start_and_save()


func _cycle_setup_options(setup: SharedSetupPanel) -> String:
	_router.handle_control("shared-setup", "C3")
	if _router.increment != 5:
		return "increment cycle"
	_router.handle_control("shared-setup", "C1")
	if _router.white_seat != "top":
		return "white seat cycle"
	_router.handle_control("shared-setup", "C4")
	if _router.advice_on:
		return "advice toggle"
	## Unavailable C3 when Untimed must not activate.
	_router.handle_control("shared-setup", "C2")
	_router.handle_control("shared-setup", "C2")
	if _router.clock != "untimed":
		return "clock back to Untimed"
	var before_inc := _router.increment
	setup._on_activate("C3")
	if _router.increment != before_inc:
		return "unavailable C3 activated"
	return ""


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
