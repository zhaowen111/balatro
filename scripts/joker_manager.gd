## 小丑管理器：加载小丑定义、装备/卸下、响应触发时机并计分
extends Node

const JOKER_JSON_PATH := "res://scripts/joker.json"

## 已装备的小丑实例
class JokerInstance extends RefCounted:
	var en_name: String           ## 英文名（唯一标识）
	var definition: Dictionary    ## 来自 joker.json 的完整定义
	var state: Dictionary = {}    ## 运行时状态（可扩展）

var joker_definitions: Array[Dictionary] = [] ## 从 joker.json 加载的全部小丑
var equipped_jokers: Array[JokerInstance] = [] ## 当前装备的小丑列表

func _ready() -> void:
	_load_jokers()

func _load_jokers() -> void:
	joker_definitions.clear()
	var file := FileAccess.open(JOKER_JSON_PATH, FileAccess.READ)
	if file == null:
		push_error("JokerManager: 无法加载 %s" % JOKER_JSON_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Array:
		joker_definitions.assign(parsed)

func get_definition_by_en_name(en_name: String) -> Dictionary:
	for definition in joker_definitions:
		if definition.get("en_name", "") == en_name:
			return definition
	return {}

## 装备小丑并应用 PASSIVE_STAT 被动效果
func equip_joker(en_name: String) -> JokerInstance:
	var definition := get_definition_by_en_name(en_name)
	if definition.is_empty():
		push_warning("JokerManager: 未找到小丑 %s" % en_name)
		return null
	var instance := JokerInstance.new()
	instance.en_name = en_name
	instance.definition = definition
	equipped_jokers.append(instance)
	_apply_passive_abilities(instance)
	return instance

## 卸下小丑并撤销其产生的属性修改
func unequip_joker(instance: JokerInstance) -> void:
	if instance == null:
		return
	EffectExecutor.revert_source(instance.en_name)
	equipped_jokers.erase(instance)

## 遍历已装备小丑，执行匹配 trigger 的能力
func on_trigger(trigger: int, context: Dictionary = {}) -> void:
	for instance in equipped_jokers:
		_apply_instance_for_trigger(instance, trigger, context)

## 计分入口：先触发 ON_HAND_PLAYED，再逐张触发 ON_EACH_SCORED_CARD
func score_hand(hand_type: String, scored_cards: Array, discards_left: int = 0) -> ScoringContext:
	var scoring := ScoringContext.new()
	scoring.hand_type = hand_type
	scoring.scored_cards = scored_cards
	scoring.discards_left = discards_left
	var hand_context := {"scoring": scoring}
	on_trigger(AbilityDefs.TriggerType.ON_HAND_PLAYED, hand_context)
	for card in scored_cards:
		if card is Dictionary:
			var card_context := {
				"scoring": scoring,
				"card": card,
			}
			on_trigger(AbilityDefs.TriggerType.ON_EACH_SCORED_CARD, card_context)
	return scoring

func _apply_passive_abilities(instance: JokerInstance) -> void:
	for ability in instance.definition.get("abilities", []):
		var trigger := AbilityDefs.parse_trigger(ability.get("trigger", ""))
		if trigger != AbilityDefs.TriggerType.PASSIVE_STAT:
			continue
		var context := {
			"source_kind": AbilityDefs.SourceKind.JOKER,
			"source_id": instance.en_name,
		}
		if ConditionEvaluator.evaluate_all(ability.get("conditions", []), context):
			EffectExecutor.execute_all(ability.get("effects", []), context)

func _apply_instance_for_trigger(instance: JokerInstance, trigger: int, context: Dictionary) -> void:
	for ability in instance.definition.get("abilities", []):
		if AbilityDefs.parse_trigger(ability.get("trigger", "")) != trigger:
			continue
		var exec_context := context.duplicate(true)
		exec_context["source_kind"] = AbilityDefs.SourceKind.JOKER
		exec_context["source_id"] = instance.en_name
		if ConditionEvaluator.evaluate_all(ability.get("conditions", []), exec_context):
			EffectExecutor.execute_all(ability.get("effects", []), exec_context)
