## 能力系统常量定义：触发时机、效果类型、属性范围及 JSON 解析
class_name AbilityDefs
extends RefCounted

enum TriggerType {
	ON_TAG_SELECTED,       ## 选择标签时立即触发
	ON_NEXT_SHOP_OPEN,     ## 下一次打开商店时触发
	ON_NEXT_ROUND_START,   ## 下一轮开始时触发
	ON_ROUND_END,          ## 回合结束时触发
	ON_NEXT_BOSS_DEFEATED, ## 击败下一个 Boss 盲注时触发
	ON_BLIND_SKIPPED,      ## 跳过盲注时触发
	ON_HAND_PLAYED,        ## 打出一手牌时触发（计分流程开始）
	ON_EACH_SCORED_CARD,   ## 每张计分牌时触发
	ON_ROUND_START,        ## 回合开始时触发
	PASSIVE_STAT,          ## 装备/应用时立即生效的被动属性，卸下时撤销
}

enum EffectType {
	ADD_MONEY,       ## 增加金钱
	MULTIPLY_MONEY,  ## 金钱翻倍（可设上限 cap）
	MODIFY_STAT,     ## 修改玩家属性（如手牌上限、弃牌次数）
	ADD_MULT,        ## 加分倍率
	ADD_CHIPS,       ## 加筹码
	ADD_XMULT,       ## 乘性倍率（xmult）
	SET_SHOP_RULE,   ## 设置下一商店的特殊规则
}

enum StatScope {
	WHILE_EQUIPPED, ## 仅装备期间生效，卸下时撤销
	RUN,            ## 整局游戏持续（不追踪撤销）
	ROUND,          ## 本回合有效，在 expires_on 时机到期撤销
}

enum SourceKind {
	TAG,   ## 来自标签
	JOKER, ## 来自小丑牌
}

## JSON 字符串 → TriggerType 映射
const TRIGGER_NAMES: Dictionary = {
	"ON_TAG_SELECTED": TriggerType.ON_TAG_SELECTED,
	"ON_NEXT_SHOP_OPEN": TriggerType.ON_NEXT_SHOP_OPEN,
	"ON_NEXT_ROUND_START": TriggerType.ON_NEXT_ROUND_START,
	"ON_ROUND_END": TriggerType.ON_ROUND_END,
	"ON_NEXT_BOSS_DEFEATED": TriggerType.ON_NEXT_BOSS_DEFEATED,
	"ON_BLIND_SKIPPED": TriggerType.ON_BLIND_SKIPPED,
	"ON_HAND_PLAYED": TriggerType.ON_HAND_PLAYED,
	"ON_EACH_SCORED_CARD": TriggerType.ON_EACH_SCORED_CARD,
	"ON_ROUND_START": TriggerType.ON_ROUND_START,
	"PASSIVE_STAT": TriggerType.PASSIVE_STAT,
}

## JSON 字符串 → EffectType 映射
const EFFECT_NAMES: Dictionary = {
	"ADD_MONEY": EffectType.ADD_MONEY,
	"MULTIPLY_MONEY": EffectType.MULTIPLY_MONEY,
	"MODIFY_STAT": EffectType.MODIFY_STAT,
	"ADD_MULT": EffectType.ADD_MULT,
	"ADD_CHIPS": EffectType.ADD_CHIPS,
	"ADD_XMULT": EffectType.ADD_XMULT,
	"SET_SHOP_RULE": EffectType.SET_SHOP_RULE,
}

## JSON 字符串 → StatScope 映射
const SCOPE_NAMES: Dictionary = {
	"WHILE_EQUIPPED": StatScope.WHILE_EQUIPPED,
	"RUN": StatScope.RUN,
	"ROUND": StatScope.ROUND,
}

## 解析 trigger 字符串，未知值返回 -1
static func parse_trigger(value: String) -> int:
	return TRIGGER_NAMES.get(value, -1)

## 解析 effect 字符串，未知值返回 -1
static func parse_effect(value: String) -> int:
	return EFFECT_NAMES.get(value, -1)

## 解析 scope 字符串，未知值默认 RUN
static func parse_scope(value: String) -> int:
	return SCOPE_NAMES.get(value, StatScope.RUN)
