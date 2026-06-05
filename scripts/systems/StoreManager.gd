## 商店管理器：管理下一商店的稀有度/特殊标记及待生效规则
extends Node


func _ready() -> void:
	_load_all_sellcards()

func _load_all_sellcards() -> void:
	load_joker_sellcards()
	load_star_sellcards()
	load_taluo_sellcards()
	load_spectral_sellcards()
	load_game_sellcards()

func load_joker_sellcards() -> void:
	var file = FileAccess.open("res://data/joker.json", FileAccess.READ)
	if file == null:
		push_error("StoreManager: 无法加载 joker.json")
		return
	var json = JSON.parse_string(file.get_as_text())
	if json is Array:
		SellableCards[SellCard.SELLCardType.JOKER].cards = json
func load_star_sellcards() -> void:
		var file = FileAccess.open("res://data/star.json", FileAccess.READ)
		if file == null:
			push_error("StoreManager: 无法加载 star.json")
			return
		var json = JSON.parse_string(file.get_as_text())
		if json is Array:
			SellableCards[SellCard.SELLCardType.STAR].cards = json

func load_taluo_sellcards() -> void:
	var file = FileAccess.open("res://data/taluo.json", FileAccess.READ)
	if file == null:
		push_error("StoreManager: 无法加载 taluo.json")
		return
	var json = JSON.parse_string(file.get_as_text())
	if json is Array:
		SellableCards[SellCard.SELLCardType.TALUO].cards = json

func load_spectral_sellcards() -> void:
	var file = FileAccess.open("res://data/spectral.json", FileAccess.READ)
	if file == null:
		push_error("StoreManager: 无法加载 spectral.json")
		return
	var json = JSON.parse_string(file.get_as_text())
	if json is Array:
		SellableCards[SellCard.SELLCardType.SPECTRAL].cards = json

func load_game_sellcards() -> void:
	var file = FileAccess.open("res://data/game.json", FileAccess.READ)
	if file == null:
		push_error("StoreManager: 无法加载 game.json")
		return
	var json = JSON.parse_string(file.get_as_text())
	if json is Array:
		SellableCards[SellCard.SELLCardType.GAME].cards = json

enum Rarity {
	COMMON = 0, ## 普通
	UNCOMMON = 1, ## 罕见
	RARE = 2, ## 稀有
	LEGENDARY = 3, ## 传奇
}

enum SpecialFlag {
	NONE = 0, ## 无特殊标记
	NEGATIVE = 1, ## 负片
	FOIL = 2, ## 闪箔
	HOLORAPHIC = 3, ## 全息
	POLYCHROME = 4, ## 多彩
}


var SellableCards: Dictionary = {
	SellCard.SELLCardType.JOKER: {
		"enable": true,
		"cards": [],
	},
	SellCard.SELLCardType.STAR: {
		"enable": true,
		"cards": [],
	},
	SellCard.SELLCardType.TALUO: {
		"enable": true,
		"cards": [],
	},
	SellCard.SELLCardType.SPECTRAL: {
		"enable": false,
		"cards": [],
	},
	SellCard.SELLCardType.GAME: {
		"enable": false,
		"cards": [],
	},
}

var next_rarity_flag: Rarity = Rarity.COMMON ## 下一商店强制出现的稀有度
var next_special_flag: SpecialFlag = SpecialFlag.NONE ## 下一商店强制出现的特殊标记
var pending_shop_rules: Array[String] = [] ## 待在下一次开店时生效的规则

## 添加待生效的商店规则（由 SET_SHOP_RULE 效果调用）
func apply_shop_rule(rule: String, _spec: Dictionary = {}) -> void:
	pending_shop_rules.append(rule)

## 取出并清空全部待生效规则（开店时调用）
func consume_shop_rules() -> Array[String]:
	var rules := pending_shop_rules.duplicate()
	pending_shop_rules.clear()
	return rules

func has_shop_rule(rule: String) -> bool:
	return pending_shop_rules.has(rule)


func random_willsell_card() -> SellCard:
	var type = SellableCards.keys().filter(func(v): return SellableCards[v].enable).pick_random()
	
	var card
	if (type == SellCard.SELLCardType.JOKER):
		var rarity = utils.weighted_random(Rarity.values(), [10, 5, 2, 1])
		var cards = SellableCards[type].cards.filter(func(v): return v.rarity == rarity)
		card = cards.pick_random()
	else:
		card = SellableCards[type].cards.pick_random()
	print(card)
	return SellCard.new(card, type)