extends Node

var BLINDS: Array[Dictionary] = []
var BLIND_FILE_PATH = "res://data/blind.json"
var smallBlind: Dictionary = {
	"zh_name": "小盲注",
	"en_name": "Small Blind",
	"reward_gold": 3,
	"score_multiplier": 1,
	"description": "基础关卡，无特殊效果，可以跳过。奖励金额随底注倍数递增。"
}

var largeBlind: Dictionary = {
	"zh_name": "大盲注",
	"en_name": "Big Blind",
	"reward_gold": 4,
	"score_multiplier": 1.5,
	"description": "基础关卡，无特殊效果，可以跳过。奖励金额随底注倍数递增。"
}
func _init() -> void:
	_load_blinds()

func _load_blinds() -> void:
	var file := FileAccess.open(BLIND_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("BlindManager: 无法加载 %s" % BLIND_FILE_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		BLINDS.assign(parsed)