class_name BlindTag
extends RefCounted
var id: int
var name: String
var description: String
var texture: AtlasTexture
var effect: Effect

static var TAGS: Array[BlindTag] = [
	BlindTag.new(0, "杂耍标签", "下回合手牌上限+3", Effect.EFFECTS["AddHandCount3"]),
]
func _init(_id: int, _name: String, _description: String, _effect: Effect, _texture: AtlasTexture = null) -> void:
	self.id = _id
	self.name = _name
	self.description = _description
	self.texture = _texture
	self.effect = _effect

func triggerEffect() -> void:
	if (effect.effectType == Effect.EffectType.NOW):
		effect.triggerEffect()
	else:
		MyPlayerAssets.addWillEffect(effect)
