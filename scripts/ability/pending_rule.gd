## 延迟生效的能力规则（等待指定 trigger 触发后执行）
class_name PendingRule
extends RefCounted

var source_kind: AbilityDefs.SourceKind = AbilityDefs.SourceKind.TAG ## 规则来源类型
var source_id: String = ""       ## 来源标识（标签/小丑英文名）
var trigger: int = -1            ## 等待触发的时机
var conditions: Array = []       ## 触发时需满足的条件
var effects: Array = []          ## 触发后执行的效果
var consume: bool = true         ## 触发后是否移除该规则
var can_be_doubled: bool = true  ## 是否可被「双倍」标签复制

## 从 JSON rule 字典构造 PendingRule
static func from_dict(
	source_kind: AbilityDefs.SourceKind,
	source_id: String,
	rule: Dictionary,
	can_be_doubled: bool = true
) -> PendingRule:
	var pending := PendingRule.new()
	pending.source_kind = source_kind
	pending.source_id = source_id
	pending.trigger = AbilityDefs.parse_trigger(rule.get("trigger", ""))
	pending.conditions = rule.get("conditions", [])
	pending.effects = rule.get("effects", [])
	pending.consume = rule.get("consume", true)
	pending.can_be_doubled = can_be_doubled
	return pending
