## 效果执行器：解析并执行 JSON 中定义的 effects，管理可撤销的属性修改
extends Node

## 追踪 MODIFY_STAT 产生的属性变更，用于到期或卸下时回滚
class StatModifier extends RefCounted:
	var stat: String       ## 属性名（如 max_hand_count）
	var delta: int         ## 变更量
	var expires_on: int = -1 ## 到期触发时机（-1 表示仅按 source_id 撤销）
	var source_id: String = "" ## 来源标识，用于卸下时撤销

var _modifiers: Array[StatModifier] = []

## 依次执行效果列表
func execute_all(effects: Array, context: Dictionary) -> void:
	for effect_spec in effects:
		execute_one(effect_spec, context)

## 执行单个效果，type 字段对应 AbilityDefs.EffectType
func execute_one(spec: Dictionary, context: Dictionary) -> void:
	var effect_type := AbilityDefs.parse_effect(spec.get("type", ""))
	match effect_type:
		AbilityDefs.EffectType.ADD_MONEY:
			MyPlayerAssets.coin += int(spec.get("amount", 0))
		AbilityDefs.EffectType.MULTIPLY_MONEY:
			var cap := int(spec.get("cap", 999999))
			var multiplier := int(spec.get("multiplier", 2))
			MyPlayerAssets.coin = mini(MyPlayerAssets.coin * multiplier, cap)
		AbilityDefs.EffectType.MODIFY_STAT:
			_apply_modify_stat(spec, context)
		AbilityDefs.EffectType.ADD_MULT:
			_apply_scoring(spec, context, "mult")
		AbilityDefs.EffectType.ADD_CHIPS:
			_apply_scoring(spec, context, "chips")
		AbilityDefs.EffectType.ADD_XMULT:
			_apply_scoring(spec, context, "xmult")
		AbilityDefs.EffectType.SET_SHOP_RULE:
			StoreManager.apply_shop_rule(str(spec.get("rule", "")), spec)
		_:
			push_warning("EffectExecutor: 未实现 effect type=%s" % spec.get("type", ""))

## 触发时机到达时，撤销 expires_on 匹配的临时属性修改
func on_trigger(trigger: int) -> void:
	var remaining: Array[StatModifier] = []
	for modifier in _modifiers:
		if modifier.expires_on == trigger:
			_apply_stat_delta(modifier.stat, -modifier.delta)
		else:
			remaining.append(modifier)
	_modifiers = remaining

## 撤销指定来源（如卸下小丑）产生的全部属性修改
func revert_source(source_id: String) -> void:
	var remaining: Array[StatModifier] = []
	for modifier in _modifiers:
		if modifier.source_id == source_id:
			_apply_stat_delta(modifier.stat, -modifier.delta)
		else:
			remaining.append(modifier)
	_modifiers = remaining

func _apply_modify_stat(spec: Dictionary, context: Dictionary) -> void:
	var stat := str(spec.get("stat", ""))
	var delta := int(spec.get("delta", 0))
	var scope := AbilityDefs.parse_scope(spec.get("scope", "RUN"))
	var source_id := str(context.get("source_id", ""))
	_apply_stat_delta(stat, delta)
	if scope == AbilityDefs.StatScope.ROUND:
		var modifier := StatModifier.new()
		modifier.stat = stat
		modifier.delta = delta
		modifier.source_id = source_id
		modifier.expires_on = AbilityDefs.parse_trigger(spec.get("expires_on", "ON_ROUND_END"))
		_modifiers.append(modifier)
	elif scope == AbilityDefs.StatScope.WHILE_EQUIPPED:
		var modifier := StatModifier.new()
		modifier.stat = stat
		modifier.delta = delta
		modifier.source_id = source_id
		modifier.expires_on = -1
		_modifiers.append(modifier)

func _apply_stat_delta(stat: String, delta: int) -> void:
	match stat:
		"max_hand_count": ## 手牌上限
			MyPlayerAssets.maxHandCount += delta
		"discard_count": ## 每回合弃牌次数
			MyPlayerAssets.discardCount += delta
		_:
			push_warning("EffectExecutor: 未知 stat=%s" % stat)

func _apply_scoring(spec: Dictionary, context: Dictionary, kind: String) -> void:
	var scoring: ScoringContext = context.get("scoring")
	if scoring == null:
		return
	match kind:
		"mult":
			scoring.mult_add += int(spec.get("value", 0))
		"chips":
			scoring.chips_add += int(spec.get("value", 0))
		"xmult":
			scoring.x_mult *= float(spec.get("value", 1.0))
