extends Node2D

@export var titleAnimation:AnimatedSprite2D
@export var allScoreLabel:Label
@export var subScoreLabel:Label
@export var magLabel:Label
@export var playcardLabel:Label
@export var discardLabel:Label
@export var coinLabel:Label
@export var anteLabel:Label#底注
@export var maxAnteLabel:Label#底注
@export var turnsLabel:Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerAssets.anteChange.connect(func(newAnte):
		anteLabel.text = str(newAnte)
		)
	titleAnimation.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func showMatchInfo():
	pass
func showOptions():
	pass
