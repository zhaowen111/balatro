extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initTurn()


signal startTurnSignal
func startTurn() -> void:
	MyPlayerAssets.turns += 1
	TagManager.on_round_start()
	startTurnSignal.emit()
	

signal endTurnSignal
func endTurn() -> void:
	TagManager.on_round_end()
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
	$handCount.text = str(MyPlayerAssets.maxHandCount)
	MyPlayerAssets.maxHandCountChange.connect(updateHandCount)
func updateHandCount(newHandCount: int) -> void:
	$handCount.text = str(newHandCount)
