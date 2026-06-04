## 全局事件总线：统一广播能力触发时机，并通知各管理器
extends Node

signal trigger_fired(trigger: int, context: Dictionary) ## 任意 trigger 触发时发出

## 广播 trigger，依次通知 EffectExecutor、TagManager、JokerManager
func emit_trigger(trigger: int, context: Dictionary = {}) -> void:
	trigger_fired.emit(trigger, context)
	EffectExecutor.on_trigger(trigger)
	TagManager.on_trigger(trigger, context)
	JokerManager.on_trigger(trigger, context)
