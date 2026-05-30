extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initTurn()


signal startTurnSignal
func startTurn() -> void:
	MyPlayerAssets.turns += 1
	var needTriggerEffects = MyPlayerAssets.willEffectDict.get(Effect.EffectType.ON_START_TURN)
	for effect in needTriggerEffects:
		effect.triggerEffect()
	$handCount.text = str(MyPlayerAssets.maxHandCount)
	startTurnSignal.emit()
	

signal endTurnSignal
func endTurn() -> void:
	var blind = SelectBlind.blinds[MyPlayerAssets.currentBlindCount];
	MyPlayerAssets.coin += blind.award
	if (blind.blindType == Blind.BlindType.boss):
		MyPlayerAssets.ante += 1

	MyPlayerAssets.currentBlindCount += 1
	endTurnSignal.emit()
	get_tree().change_scene_to_file("res://scenes/SelectBlind/selectBlind.tscn")
	

func initTurn() -> void:
	var blind = SelectBlind.blinds[MyPlayerAssets.currentBlindCount];
	$score.text = str(blind.score)