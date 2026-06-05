# CardResource.gd
extends Resource
class_name Card

# 奖励牌 (Bonus Card)：计分时提供+30筹码。

# 💎 倍率牌 (Mult Card)：计分时提供+4倍率。

# 🌈 万能牌 (Wild Card)：可视为任意花色，方便凑同花。

# ✨ 幸运牌 (Lucky Card)：计分时有1/5几率获得+20倍率，还有1/15几率获得$20。

# 🛡️ 玻璃牌 (Glass Card)：提供×2倍率，但计分后有1/4几率被摧毁。

# ⛓️ 钢铁牌 (Steel Card)：留在手牌中不打出时，提供×1.5倍率。

# 💰 黄金牌 (Gold Card)： 回合结束时若仍留在手牌，直接获得$3
# 
enum StrenthType {
	Bonus,
	Mult,
	Wild,
	Lucky,
	Glass,
	Steel,
	Gold,
	None
}

enum SpecialType {
	None,
	Red, # 红色蜡封
	Blue, # 蓝色蜡封
	Purple, # 紫色蜡封
	Gold, # 金色蜡封
	Foils, # 闪箔
	Holographic, # 镭射
	Polychrome, # 多彩
}
var texture: Texture2D # 牌的纹理
var rank: String # 点数 (A, 2, 3...K)
var suit: String # 花色 (spade, heart, club, diamond)
var chip_value: int # 筹码值
var strenthType: StrenthType = StrenthType.None
var specialType: SpecialType = SpecialType.None


func _pick_random_strenth_type():
	var pool: Array = StrenthType.values().filter(func(v): return v != StrenthType.None)
	strenthType = pool.pick_random() as StrenthType

func _pick_random_special_type():
	var pool: Array = SpecialType.values().filter(func(v): return v != SpecialType.None)
	specialType = pool.pick_random() as SpecialType

static func _get_all_type_size() -> int:
	return StrenthType.size() + SpecialType.size()

func random_card_type() -> void:
	var type_range = _get_all_type_size() * 2
	var random_index = randi() % type_range
	if random_index < Card.StrenthType.size():
		strenthType = _pick_random_strenth_type()
	elif random_index < Card.StrenthType.size() + Card.SpecialType.size():
		specialType = _pick_random_special_type()
	else:
		strenthType = StrenthType.None
		specialType = SpecialType.None


func _to_string() -> String:
	return "%s%s" % [rank, suit]