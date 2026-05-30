extends Node2D

@export var titleAnimation: AnimatedSprite2D
@export var allScoreLabel: Label
@export var subScoreLabel: Label
@export var magLabel: Label
@export var playcardLabel: Label
@export var discardLabel: Label
@export var coinLabel: Label
@export var anteLabel: Label # 底注
@export var maxAnteLabel: Label # 底注
@export var turnsLabel: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	allScoreLabel.text = str(MyPlayerAssets.allScore)
	subScoreLabel.text = str(MyPlayerAssets.subScore)
	magLabel.text = str(MyPlayerAssets.mag)
	playcardLabel.text = str(MyPlayerAssets.playCount)
	discardLabel.text = str(MyPlayerAssets.discardCount)
	coinLabel.text = str(MyPlayerAssets.coin)
	anteLabel.text = str(MyPlayerAssets.ante)
	maxAnteLabel.text = str(MyPlayerAssets.maxAnte)
	turnsLabel.text = str(MyPlayerAssets.turns)
	
	MyPlayerAssets.anteChange.connect(func(newAnte):
		anteLabel.text = str(newAnte)
	)
	MyPlayerAssets.maxAnteChange.connect(func(newMaxAnte):
		maxAnteLabel.text = str(newMaxAnte)
	)
	MyPlayerAssets.turnsChange.connect(func(newTurns):
		turnsLabel.text = str(newTurns)
	)
	MyPlayerAssets.allScoreChange.connect(func(newAllScore):
		allScoreLabel.text = str(newAllScore)
	)
	MyPlayerAssets.subScoreChange.connect(func(newSubScore):
		subScoreLabel.text = str(newSubScore)
	)
	MyPlayerAssets.magChange.connect(func(newMag):
		magLabel.text = str(newMag)
	)
	MyPlayerAssets.playCountChange.connect(func(newPlayCount):
		playcardLabel.text = str(newPlayCount)
	)
	MyPlayerAssets.discardCountChange.connect(func(newDiscardCount):
		discardLabel.text = str(newDiscardCount)
	)
	MyPlayerAssets.coinChange.connect(func(newCoin):
		coinLabel.text = str(newCoin)
	)
	titleAnimation.play()


func showMatchInfo():
	pass
func showOptions():
	pass
