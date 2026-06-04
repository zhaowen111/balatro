extends Viewer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refreshBlindState(MyPlayerAssets.currentBlindCount)
	MyPlayerAssets.curBlindCountChange.connect(refreshBlindState)

func refreshBlindState(index):
	if index == model.index:
		$select.visible = true
		if model.blindType != Blind.BlindType.boss:
			$skip.visible = true
	else:
		$select.visible = false
		$skip.visible = false

func skip():
	TagManager.apply_tag(model.tag)
	TagManager.on_blind_skipped()
	#TODO:跳到下一个盲注
	MyPlayerAssets.currentBlindCount += 1

func select():
	get_tree().change_scene_to_file("res://scenes/Turn/turn.tscn")
	#TODO:开始一局游戏
	#目前先直接跳到下一局游戏


func _on_tag_mouse_entered() -> void:
	ToolTip.showToolTip(model.tag['description'], $tag.global_position + $tag.size / 2)


func _on_tag_mouse_exited() -> void:
	ToolTip.hideToolTip()
