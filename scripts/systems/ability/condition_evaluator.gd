## 能力条件求值器：解析 JSON 中的 conditions 数组，全部满足才返回 true
class_name ConditionEvaluator
extends RefCounted


## 求值全部条件（空数组视为无条件，直接通过）
static func evaluate_all(conditions: Array, context: Dictionary) -> bool:
	if conditions.is_empty():
		return true
	for condition in conditions:
		if not evaluate_one(condition, context):
			return false
	return true

## 求值单个条件，op 字段决定判断类型
static func evaluate_one(condition: Dictionary, context: Dictionary) -> bool:
	var op: String = condition.get("op", "ALWAYS")
	match op:
		"ALWAYS": ## 恒为真
			return true
		"HAND_HAS_TYPE": ## 当前出牌牌型等于 hand_type
			var scoring: ScoringContext = context.get("scoring")
			if scoring == null:
				return false
			return scoring.hand_type == condition.get("hand_type", "")
		"CARD_SUIT": ## 当前计分牌花色等于 suit（如 "d" 方片）
			var card: Dictionary = context.get("card", {})
			return str(card.get("suit", "")) == str(condition.get("suit", ""))
		"STAT_COMPARE": ## 玩家属性 stat 与 value 比较（compare: ==, <=, >=, <, >）
			return _compare_stat(
				str(condition.get("stat", "")),
				str(condition.get("compare", "==")),
				int(condition.get("value", 0))
			)
		_:
			push_warning("ConditionEvaluator: 未知条件 op=%s" % op)
			return false

static func _compare_stat(stat: String, compare: String, value: int) -> bool:
	var current := _read_stat(stat)
	match compare:
		"==":
			return current == value
		"<=":
			return current <= value
		">=":
			return current >= value
		"<":
			return current < value
		">":
			return current > value
		_:
			return false

static func _read_stat(stat: String) -> int:
	match stat:
		"max_hand_count": ## 手牌上限
			return MyPlayerAssets.maxHandCount
		"discards_left": ## 剩余弃牌次数
			return MyPlayerAssets.discardCount
		"coin": ## 当前金钱
			return MyPlayerAssets.coin
		_:
			return 0
