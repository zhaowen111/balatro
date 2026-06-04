class_name Blind
enum BlindType {
	small = 1,
	large = 2,
	boss = 3
}

var score: int
var award: int
var blindType: BlindType = BlindType.small
var tag: Dictionary
var texture: AtlasTexture
var index: int
var node: Node = null
var mangzhu: Dictionary = {}
func _init(_index: int, _blindType: BlindType, _tag: Dictionary) -> void:
	if (_blindType == BlindType.small):
		self.mangzhu = BlindManager.smallBlind
	elif (_blindType == BlindType.large):
		self.mangzhu = BlindManager.largeBlind
	elif (_blindType == BlindType.boss):
		self.mangzhu = BlindManager.BLINDS.pick_random()
	self.index = _index
	self.score = SelectBlind.blindScoresDeck[MyPlayerAssets.ante] * self.mangzhu['score_multiplier']
	self.award = self.mangzhu['reward_gold']
	self.blindType = _blindType
	self.tag = _tag
