## 商店管理器：管理下一商店的稀有度/特殊标记及待生效规则
extends Node

enum Rarity {
	COMMON = 0,    ## 普通
	UNCOMMON = 1,  ## 罕见
	RARE = 2,      ## 稀有
	LEGENDARY = 3, ## 传奇
}

enum SpecialFlag {
	NONE = 0,       ## 无特殊标记
	NEGATIVE = 1,   ## 负片
	FOIL = 2,       ## 闪箔
	HOLORAPHIC = 3, ## 全息
	POLYCHROME = 4, ## 多彩
}

var next_rarity_flag: Rarity = Rarity.COMMON       ## 下一商店强制出现的稀有度
var next_special_flag: SpecialFlag = SpecialFlag.NONE ## 下一商店强制出现的特殊标记
var pending_shop_rules: Array[String] = []         ## 待在下一次开店时生效的规则

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
