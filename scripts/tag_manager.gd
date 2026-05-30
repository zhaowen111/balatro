## 标签管理器：加载标签定义、应用标签效果、管理延迟规则
extends Node

const TAG_JSON_PATH := "res://scripts/tag.json"

signal tag_applied(tag: Dictionary) ## 标签应用完成时发出

var tag_definitions: Array[Dictionary] = [] ## 从 tag.json 加载的全部标签
var pending_rules: Array[PendingRule] = []  ## 等待未来 trigger 触发的规则
var double_next_tag: bool = false           ## 「双倍」标签：下一次非 Double 标签生效两次

func _ready() -> void:
	_load_tags()

func _load_tags() -> void:
	tag_definitions.clear()
	var file := FileAccess.open(TAG_JSON_PATH, FileAccess.READ)
	if file == null:
		push_error("TagManager: 无法加载 %s" % TAG_JSON_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		tag_definitions.assign(parsed)

func get_tag_by_en_name(en_name: String) -> Dictionary:
	for tag in tag_definitions:
		if tag.get("en_name", "") == en_name:
			return tag
	return {}

func get_tag_by_index(index: int) -> Dictionary:
	if index < 0 or index >= tag_definitions.size():
		return {}
	return tag_definitions[index]

func pick_random_tag() -> Dictionary:
	if tag_definitions.is_empty():
		return {}
	return tag_definitions.pick_random()

func apply_tag_by_en_name(en_name: String) -> void:
	var tag := get_tag_by_en_name(en_name)
	if tag.is_empty():
		push_warning("TagManager: 未找到标签 %s" % en_name)
		return
	apply_tag(tag)

## 应用标签：处理「双倍」复制，立即规则与延迟规则
func apply_tag(tag: Dictionary) -> void:
	var en_name := str(tag.get("en_name", ""))
	var can_be_doubled := en_name != "Double"
	var apply_times := 2 if double_next_tag and can_be_doubled else 1
	if double_next_tag and can_be_doubled:
		double_next_tag = false
	for _i in apply_times:
		_apply_tag_once(tag)
	if en_name == "Double":
		double_next_tag = true
	tag_applied.emit(tag)

func _apply_tag_once(tag: Dictionary) -> void:
	var en_name := str(tag.get("en_name", ""))
	var rules: Array = tag.get("rules", [])
	for rule in rules:
		var trigger := AbilityDefs.parse_trigger(rule.get("trigger", ""))
		if trigger == AbilityDefs.TriggerType.ON_TAG_SELECTED:
			var context := {
				"source_kind": AbilityDefs.SourceKind.TAG,
				"source_id": en_name,
			}
			if ConditionEvaluator.evaluate_all(rule.get("conditions", []), context):
				EffectExecutor.execute_all(rule.get("effects", []), context)
		else:
			pending_rules.append(
				PendingRule.from_dict(AbilityDefs.SourceKind.TAG, en_name, rule, en_name != "Double")
			)

## 响应 trigger，执行匹配的 pending_rules
func on_trigger(trigger: int, context: Dictionary = {}) -> void:
	var index := pending_rules.size() - 1
	while index >= 0:
		var rule := pending_rules[index]
		if rule.trigger != trigger:
			index -= 1
			continue
		var exec_context := context.duplicate(true)
		exec_context["source_kind"] = rule.source_kind
		exec_context["source_id"] = rule.source_id
		if ConditionEvaluator.evaluate_all(rule.conditions, exec_context):
			EffectExecutor.execute_all(rule.effects, exec_context)
		if rule.consume:
			pending_rules.remove_at(index)
		index -= 1

## ON_NEXT_ROUND_START 与 ON_ROUND_START 在本原型中视为同一时机
func on_round_start() -> void:
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_NEXT_ROUND_START)
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_ROUND_START)

func on_round_end() -> void:
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_ROUND_END)

func on_boss_defeated() -> void:
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_NEXT_BOSS_DEFEATED)

func on_blind_skipped() -> void:
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_BLIND_SKIPPED)

func on_shop_open() -> void:
	EventBus.emit_trigger(AbilityDefs.TriggerType.ON_NEXT_SHOP_OPEN)
