extends Node2D

@export var titleAnimation:AnimatedSprite2D
@export var allScoreLabel:Label
@export var subScoreLabel:Label
@export var magLabel:Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	titleAnimation.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func showMatchInfo():
	pass
func showOptions():
	pass
