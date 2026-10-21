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
		"title": "選擇遊玩方式",
		"last": "上次",
		"shared": "共用對局",
		"puzzle": "謎題串流",
		"quit": "結束",
		"quit_confirm": "結束本次遊玩？",
		"confirm": "確認",
		"cancel": "取消",
		"loading": "載入中…",
		"save_failed": "儲存失敗。已保留先前數值。",
		"dismiss": "關閉",
	},
	"ja":
	{
		"title": "遊び方を選ぶ",
		"last": "前回",
		"shared": "シェア対局",
		"puzzle": "パズルストリーム",
		"quit": "終了",
		"quit_confirm": "このセッションを終了しますか？",
		"confirm": "確認",
		"cancel": "キャンセル",
		"loading": "読み込み中…",
		"save_failed": "保存に失敗しました。以前の値を保持します。",
		"dismiss": "閉じる",
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
	"zh-Hant":
	{
		"title": "共用對局設定",
		"white_seat": "白方座位",
		"seat_top": "上方",
		"seat_bottom": "下方",
		"clock": "時鐘",
		"clock_untimed": "無計時",
		"clock_blitz": "快棋",
		"clock_rapid": "中速棋",
		"increment": "加秒",
		"increment_3s": "3 秒",
		"increment_5s": "5 秒",
		"advice": "建議",
		"advice_on": "開",
		"advice_off": "關",
		"start": "開始",
		"back": "返回",
	},
	"ja":
	{
		"title": "シェア対局の設定",
		"white_seat": "白の席",
		"seat_top": "上",
		"seat_bottom": "下",
		"clock": "時計",
		"clock_untimed": "時間なし",
		"clock_blitz": "ブリッツ",
		"clock_rapid": "ラピッド",
		"increment": "加算",
		"increment_3s": "3 秒",
		"increment_5s": "5 秒",
		"advice": "アドバイス",
		"advice_on": "オン",
		"advice_off": "オフ",
		"start": "開始",
		"back": "戻る",
	},
}

const _SHARED_PLAY := {
	"en":
	{
		"advice_on": "Advice On",
		"advice_off": "Advice Off",
		"resign": "Resign",
		"resign_confirm": "Resign this game?",
		"offer_draw": "Offer draw",
		"offer_confirm": "Offer a draw?",
		"accept": "Accept",
		"decline": "Decline",
		"withdraw": "Withdraw",
		"draw_offered": "Draw offered",
		"confirm": "Confirm",
		"cancel": "Cancel",
		"advice_error": "Advice unavailable. Play continues.",
		"dismiss": "Dismiss",
		"white_to_move": "White to move",
		"black_to_move": "Black to move",
		"check": "Check",
		"choose_promotion": "Choose promotion",
		"refused_place": "Refused place",
		"queen": "Queen",
		"rook": "Rook",
		"bishop": "Bishop",
		"knight": "Knight",
	},
	"zh-Hant":
	{
		"advice_on": "建議：開",
		"advice_off": "建議：關",
		"resign": "認輸",
		"resign_confirm": "確定認輸？",
		"offer_draw": "提議和棋",
		"offer_confirm": "提議和棋？",
		"accept": "接受",
		"decline": "拒絕",
		"withdraw": "撤回",
		"draw_offered": "已提議和棋",
		"confirm": "確認",
		"cancel": "取消",
		"advice_error": "建議無法使用。對局繼續。",
		"dismiss": "關閉",
		"white_to_move": "白方行棋",
		"black_to_move": "黑方行棋",
		"check": "將軍",
		"choose_promotion": "選擇升變",
		"refused_place": "無法落子",
		"queen": "后",
		"rook": "車",
		"bishop": "象",
		"knight": "馬",
	},
	"ja":
	{
		"advice_on": "アドバイス オン",
		"advice_off": "アドバイス オフ",
		"resign": "投了",
		"resign_confirm": "投了しますか？",
		"offer_draw": "引き分けを提案",
		"offer_confirm": "引き分けを提案しますか？",
		"accept": "受諾",
		"decline": "拒否",
		"withdraw": "取り消し",
		"draw_offered": "引き分け提案中",
		"confirm": "確認",
		"cancel": "キャンセル",
		"advice_error": "アドバイスを利用できません。対局は続きます。",
		"dismiss": "閉じる",
		"white_to_move": "白の手番",
		"black_to_move": "黒の手番",
		"check": "チェック",
		"choose_promotion": "プロモーションを選択",
		"refused_place": "置けません",
		"queen": "クイーン",
		"rook": "ルーク",
		"bishop": "ビショップ",
		"knight": "ナイト",
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
	"zh-Hant":
	{
		"title": "對局結束",
		"shared_game": "共用對局",
		"result_white": "白方勝",
		"result_black": "黑方勝",
		"result_draw": "和棋",
		"play_again": "再來一局",
		"stop": "停止",
	},
	"ja":
	{
		"title": "対局終了",
		"shared_game": "シェア対局",
		"result_white": "白の勝ち",
		"result_black": "黒の勝ち",
		"result_draw": "引き分け",
		"play_again": "もう一度",
		"stop": "やめる",
	},
}

const _EXCEPTIONS := {
	"en":
	{
		"unsupported_input": "Touch to play",
	},
	"zh-Hant":
	{
		"unsupported_input": "請以觸控遊玩",
	},
	"ja":
	{
		"unsupported_input": "タッチで操作してください",
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


static func mode_pick_keys() -> PackedStringArray:
	return _keys_of(_MODE_PICK)


static func shared_setup_keys() -> PackedStringArray:
	return _keys_of(_SHARED_SETUP)


static func shared_play_keys() -> PackedStringArray:
	return _keys_of(_SHARED_PLAY)


static func shared_result_keys() -> PackedStringArray:
	return _keys_of(_SHARED_RESULT)


static func exception_keys() -> PackedStringArray:
	return _keys_of(_EXCEPTIONS)


static func _keys_of(tables: Dictionary) -> PackedStringArray:
	var en: Variant = tables.get("en", {})
	if not en is Dictionary:
		return PackedStringArray()
	return PackedStringArray((en as Dictionary).keys())


static func _lookup(tables: Dictionary, key: String, locale: String) -> String:
	var normalized := normalize_locale(locale)
	var table: Variant = tables.get(normalized, tables.get("en", {}))
	if table is Dictionary and (table as Dictionary).has(key):
		return str((table as Dictionary)[key])
	var fallback: Variant = tables.get("en", {})
	if fallback is Dictionary and (fallback as Dictionary).has(key):
		return str((fallback as Dictionary)[key])
	return key
