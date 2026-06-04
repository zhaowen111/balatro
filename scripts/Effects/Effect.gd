@abstract class_name Effect
extends RefCounted

enum EffectType {
	NOW = 1,
	ON_START_TURN = 2,
	ON_END_TURN = 3
}

# 所有的效果
static var EFFECTS: Dictionary[String, Effect] = {
	"AddHandCount3": AddHandCount.new(1, "加手牌上限", "加手牌上限", EffectType.ON_START_TURN, [3, 1])
}

var id: int
var name: String
var description: String
var effectType: EffectType = EffectType.NOW
var params: Array = []
var temporaryRounds: int = -10 # 临时回合数，-10表示永久

func _init(_id: int, _name: String, _description: String, _effectType: EffectType, _params: Array = [], _temporaryRounds: int = -10) -> void:
	self.id = _id
	self.name = _name
	self.description = _description
	self.effectType = _effectType
	self.params = _params
	self.temporaryRounds = _temporaryRounds
@abstract func triggerEffect(context: Dictionary = {})
