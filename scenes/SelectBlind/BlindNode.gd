extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func skip():
	#TODO:触发标签
	#TODO:跳到下一个盲注
	MyPlayerAssets.currentBlindCount += 1

func select():
	get_tree().change_scene_to_file("res://scenes/Turn/turn.tscn")
	#TODO:开始一局游戏
	#目前先直接跳到下一局游戏
