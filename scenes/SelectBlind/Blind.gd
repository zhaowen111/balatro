class_name Blind
enum BlindType {
	small = 1,
	large = 2,
	boss = 3
}

var score: int
var award: int
var blindType: BlindType = BlindType.small
var tag: BlindTag
var texture: AtlasTexture
var index: int
var node: Node = null
func _init(_index: int, _score: int, _award: int, _blindType: BlindType, _tag: BlindTag, _node: Node, _texture: AtlasTexture = null) -> void:
	self.index = _index
	self.score = _score
	self.award = _award
	self.blindType = _blindType
	self.tag = _tag
	self.texture = _texture
	self.node = _node
