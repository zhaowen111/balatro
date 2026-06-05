extends Node

signal allScoreChange(newAllScore: int)
@export var allScore = 0:
	set(val):
		allScoreChange.emit(val)
		allScore = val

signal subScoreChange(newSubScore: int)
@export var subScore = 0:
	set(val):
		subScoreChange.emit(val)
		subScore = val

signal magChange(newMag: int)
@export var mag = 0:
	set(val):
		magChange.emit(val)
		mag = val

signal playCountChange(newPlayCount: int)
@export var playCount = 3:
	set(val):
		playCountChange.emit(val)
		playCount = val

signal discardCountChange(newDiscardCount: int)
@export var discardCount = 3:
	set(val):
		discardCountChange.emit(val)
		discardCount = val


signal coinChange(newCoin: int)
@export var coin = 0:
	set(val):
		coinChange.emit(val)
		coin = val

signal anteChange(newAnte: int)
@export var ante = 1: # 底注
	set(val):
		anteChange.emit(val)
		ante = val

signal maxAnteChange(newMaxAnte: int)
@export var maxAnte = 8: # 底注上限
	set(val):
		maxAnteChange.emit(val)
		maxAnte = val

signal turnsChange(newTurns: int)
@export var turns = 0: # 回合数
	set(val):
		turnsChange.emit(val)
		turns = val

signal curBlindCountChange
@export var currentBlindCount = 0:
	set(val):
		curBlindCountChange.emit(val)
		currentBlindCount = val


#局内变量
signal maxHandCountChange(val: int)
@export var maxHandCount = 8: # 手牌数
	set(val):
		maxHandCountChange.emit(val)
		maxHandCount = val

signal consumedCardCountChange(newConsumedCardCount: int)
@export var consumedCardCount = 0: # 消耗牌数
	set(val):
		consumedCardCountChange.emit(val)
		consumedCardCount = val

signal maxJokerCountChange(val: int)
@export var maxJokerCount = 5: # 最大小丑牌数上限
	set(val):
		maxJokerCountChange.emit(val)
		maxJokerCount = val

# 将要执行的效果	
var willEffectDict: Dictionary[int, Array] = {}
func addWillEffect(effect: Effect) -> void:
	if (willEffectDict.has(effect.id)):
		willEffectDict[effect.id].append(effect)
	else:
		willEffectDict[effect.id] = [effect]


var curBlind: Blind = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func currentBlindChange(index: int):
	var blind = SelectBlind.blinds[index]
	if blind:
		MyPlayerAssets.curBlind = blind
		SelectBlind.curNode = blind.node
