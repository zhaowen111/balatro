## 一手牌的计分上下文，小丑效果在此累加筹码与倍率
class_name ScoringContext
extends RefCounted

var hand_type: String = ""   ## 牌型（如 PAIR、FLUSH）
var scored_cards: Array = [] ## 参与计分的牌列表
var discards_left: int = 0   ## 剩余弃牌次数
var chips_add: int = 0       ## 累计加筹码
var mult_add: int = 0        ## 累计加倍率
var x_mult: float = 1.0      ## 累计乘性倍率

## 最终倍率 = mult_add × x_mult
func get_total_mult() -> float:
	return float(mult_add) * x_mult

## 为单张计分牌创建独立上下文副本
func duplicate_for_card(card: Dictionary) -> ScoringContext:
	var copy := ScoringContext.new()
	copy.hand_type = hand_type
	copy.scored_cards = [card]
	copy.discards_left = discards_left
	return copy
