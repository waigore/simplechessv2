class_name StringTable
extends RefCounted
## S4 string tables keyed by GS.locale ([configuration.md] B4).

const LOCALES: PackedStringArray = ["en", "zh-Hant", "ja"]

## Own names for C4 — same string in every locale table (UI-mode-pick locale key).
const LOCALE_OWN_NAME := {
	"en": "English",
	"zh-Hant": "繁體中文",
	"ja": "日本語",
}

const _MODE_PICK := {
	"en":
	{
		"title": "Choose how to play",
		"last": "Last",
		"shared": "Shared game",
		"puzzle": "Puzzle stream",
		"quit": "Quit",
		"quit_confirm": "End this session?",
		"confirm": "Confirm",
		"cancel": "Cancel",
		"loading": "Loading…",
		"save_failed": "Save failed. Prior values kept.",
		"dismiss": "Dismiss",
	},
	"zh-Hant":
	{
		"title": "Choose how to play",
		"last": "Last",
		"shared": "Shared game",
		"puzzle": "Puzzle stream",
		"quit": "Quit",
		"quit_confirm": "End this session?",
		"confirm": "Confirm",
		"cancel": "Cancel",
		"loading": "載入中…",
		"save_failed": "Save failed. Prior values kept.",
		"dismiss": "Dismiss",
	},
	"ja":
	{
		"title": "Choose how to play",
		"last": "Last",
		"shared": "Shared game",
		"puzzle": "Puzzle stream",
		"quit": "Quit",
		"quit_confirm": "End this session?",
		"confirm": "Confirm",
		"cancel": "Cancel",
		"loading": "読み込み中…",
		"save_failed": "Save failed. Prior values kept.",
		"dismiss": "Dismiss",
	},
}

const _SHARED_SETUP := {
	"en":
	{
		"title": "Shared game setup",
		"white_seat": "White seat",
		"seat_top": "Top",
		"seat_bottom": "Bottom",
		"clock": "Clock",
		"clock_untimed": "Untimed",
		"clock_blitz": "Blitz",
		"clock_rapid": "Rapid",
		"increment": "Increment",
		"increment_3s": "3 s",
		"increment_5s": "5 s",
		"advice": "Advice",
		"advice_on": "On",
		"advice_off": "Off",
		"start": "Start",
		"back": "Back",
	},
}

const _SHARED_PLAY := {
	"en":
	{
		"advice_on": "Advice On",
		"advice_off": "Advice Off",
		"resign": "Resign",
		"resign_confirm": "Resign this game?",
		"confirm": "Confirm",
		"cancel": "Cancel",
		"white_to_move": "White to move",
		"black_to_move": "Black to move",
		"check": "Check",
	},
}

const _SHARED_RESULT := {
	"en":
	{
		"title": "Game over",
		"shared_game": "Shared game",
		"result_white": "White wins",
		"result_black": "Black wins",
		"result_draw": "Draw",
		"play_again": "Play again",
		"stop": "Stop",
	},
}

const _EXCEPTIONS := {
	"en":
	{
		"unsupported_input": "Touch to play",
	},
	"zh-Hant":
	{
		"unsupported_input": "Touch to play",
	},
	"ja":
	{
		"unsupported_input": "Touch to play",
	},
}


static func normalize_locale(locale: String) -> String:
	if LOCALE_OWN_NAME.has(locale):
		return locale
	return "en"


static func next_locale(locale: String) -> String:
	var current := normalize_locale(locale)
	var index := LOCALES.find(current)
	if index < 0:
		return "en"
	return str(LOCALES[(index + 1) % LOCALES.size()])


static func locale_from_os(raw: String) -> String:
	var lower := raw.to_lower().replace("_", "-")
	if lower.begins_with("zh"):
		return "zh-Hant"
	if lower.begins_with("ja"):
		return "ja"
	if lower.begins_with("en"):
		return "en"
	return "en"


static func mode_pick(key: String, locale: String) -> String:
	if key == "locale":
		return str(LOCALE_OWN_NAME[normalize_locale(locale)])
	return _lookup(_MODE_PICK, key, locale)


static func shared_setup(key: String, locale: String) -> String:
	return _lookup(_SHARED_SETUP, key, locale)


static func shared_play(key: String, locale: String) -> String:
	return _lookup(_SHARED_PLAY, key, locale)


static func shared_result(key: String, locale: String) -> String:
	return _lookup(_SHARED_RESULT, key, locale)


static func exception_text(key: String, locale: String) -> String:
	return _lookup(_EXCEPTIONS, key, locale)


static func _lookup(tables: Dictionary, key: String, locale: String) -> String:
	var normalized := normalize_locale(locale)
	var table: Variant = tables.get(normalized, tables.get("en", {}))
	if table is Dictionary and (table as Dictionary).has(key):
		return str((table as Dictionary)[key])
	var fallback: Variant = tables.get("en", {})
	if fallback is Dictionary and (fallback as Dictionary).has(key):
		return str((fallback as Dictionary)[key])
	return key
