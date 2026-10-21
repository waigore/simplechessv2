class_name StringTableTest
extends SceneTree
## Wave-1 localization: every Copy key in en / zh-Hant / ja (#62).


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var problem := _all_locales_populated()
	if problem.is_empty():
		problem = _no_english_leak_in_cjk()
	if problem.is_empty():
		problem = _locale_helpers()
	if problem.is_empty():
		problem = _layout_growth_chrome()
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
	## Spot-check that CJK tables are not English copies for player-facing titles.
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


func _layout_growth_chrome() -> String:
	## quality.md Localization: tolerate ~40% growth; chrome must not clip labels.
	var button := Button.new()
	root.add_child(button)
	UiChrome.style_button(button, true)
	if button.clip_text:
		return "style_button clips text"
	var en := "Save failed. Prior values kept."
	button.text = en
	var grown := en + en.substr(0, int(ceili(en.length() * 0.4)))
	button.text = grown
	if button.clip_text:
		return "clip_text enabled after longer copy"
	if button.custom_minimum_size.x < UiChrome.MIN_TOUCH:
		return "touch target below 44 after growth"
	if button.custom_minimum_size.y < UiChrome.MIN_TOUCH:
		return "touch height below 44 after growth"
	button.queue_free()
	## Catalog font ids used for CJK fallback stay wired.
	if UiChrome.FONT_LATIN.is_empty() or UiChrome.FONT_CJK.is_empty():
		return "font catalog ids missing"
	return ""
